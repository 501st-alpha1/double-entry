import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
import '../../services/settings_service.dart';
import 'ynab_client.dart';
import 'ynab_models.dart';

/// Result of a sync attempt for a single transaction.
class YnabSyncResult {
  final String transactionId;
  final bool success;
  final String? ynabTransactionId;
  final String? error;

  const YnabSyncResult({
    required this.transactionId,
    required this.success,
    this.ynabTransactionId,
    this.error,
  });
}

/// Translates queued transactions into YNAB API calls.
class YnabSyncRepository {
  final YnabClient _client;
  final String _budgetId;
  final TransactionDao _transactionDao;
  final AccountDao _accountDao;

  YnabSyncRepository({
    required YnabClient client,
    required String budgetId,
    required TransactionDao transactionDao,
    required AccountDao accountDao,
  })  : _client = client,
        _budgetId = budgetId,
        _transactionDao = transactionDao,
        _accountDao = accountDao;

  /// Syncs all pending transactions to YNAB.
  /// Updates sync status in the DB for each transaction.
  Future<List<YnabSyncResult>> syncPending() async {
    final pending = await _transactionDao.pendingTransactions();
    final toSync = pending
        .where((t) =>
            t.ynabSyncStatus == 'pending' || t.ynabSyncStatus == 'failed')
        .toList();

    if (toSync.isEmpty) return [];

    final results = <YnabSyncResult>[];

    for (final tx in toSync) {
      try {
        // Budget moves are handled differently — PATCH category budgeted amounts
        if (tx.type == 'budgetMove') {
          final result = await _syncBudgetMove(tx);
          results.add(result);
          continue;
        }

        final ynabTx = await _buildYnabTransaction(tx);
        if (ynabTx == null) {
          // No source account found — mark as failed
          await _transactionDao.updateSyncStatus(
            transactionId: tx.id,
            ynabStatus: 'failed',
          );
          results.add(YnabSyncResult(
            transactionId: tx.id,
            success: false,
            error: 'No source account (isSource) found for transaction',
          ));
          continue;
        }

        final ids = await _client.postTransactions(_budgetId, [ynabTx]);
        final ynabId = ids.isNotEmpty ? ids.first : null;

        await _transactionDao.updateSyncStatus(
          transactionId: tx.id,
          ynabStatus: 'synced',
          ynabTransactionId: ynabId,
        );

        results.add(YnabSyncResult(
          transactionId: tx.id,
          success: true,
          ynabTransactionId: ynabId,
        ));
      } catch (e, st) {
        debugPrint('YNAB sync error for transaction ${tx.id}: $e');
        debugPrint('Stack trace: $st');
        await _transactionDao.updateSyncStatus(
          transactionId: tx.id,
          ynabStatus: 'failed',
        );
        results.add(YnabSyncResult(
          transactionId: tx.id,
          success: false,
          error: e.toString(),
        ));
      }
    }

    return results;
  }

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  Future<YnabSaveTransaction?> _buildYnabTransaction(
      TransactionRow tx) async {
    final postings =
        await _transactionDao.postingsForTransaction(tx.id);
    final realPostings = postings.where((p) => !p.isBudgetMirror).toList();

    // Find the source posting — the one designated as the YNAB account
    final sourcePosting =
        realPostings.where((p) => p.isSource).firstOrNull;
    if (sourcePosting == null) return null;

    // Resolve the source account's YNAB ID
    final sourceAccount = await _accountDao.findById(sourcePosting.accountId);
    final ynabAccountId = sourceAccount?.ynabId;
    if (ynabAccountId == null) return null;

    final date = _formatDate(tx.date);
    final memo = tx.note;

    // Single posting — simple transaction
    final nonSourcePostings =
        realPostings.where((p) => !p.isSource).toList();

    if (nonSourcePostings.isEmpty) {
      // Budget move or single-posting transaction
      return YnabSaveTransaction(
        accountId: ynabAccountId,
        date: date,
        amount: sourcePosting.amountMilliunits,
        payeeName: tx.payeeName,
        memo: memo,
      );
    }

    // Multiple real postings — build a split transaction.
    // For a single non-source posting, use categoryId directly (no subtransactions).
    // For multiple, use subtransactions where amounts are from the source's perspective.
    if (nonSourcePostings.length == 1) {
      final posting = nonSourcePostings.first;
      final account = await _accountDao.findById(posting.accountId);
      final isTransfer = account?.ynabTransferPayeeId != null;

      return YnabSaveTransaction(
        accountId: ynabAccountId,
        date: date,
        amount: sourcePosting.amountMilliunits,
        payeeName: isTransfer ? null : tx.payeeName,
        payeeId: isTransfer ? account!.ynabTransferPayeeId : null,
        categoryId: !isTransfer ? account?.ynabId : null,
        memo: memo,
      );
    }

    // Genuine split — multiple non-source postings become subtransactions.
    // Each subtransaction amount is expressed from the source account's perspective,
    // so they must sum to the source posting amount.
    // We derive each subtransaction's share proportionally from the source amount.
    final totalNonSource = nonSourcePostings.fold(
        0, (sum, p) => sum + p.amountMilliunits.abs());

    final subtransactions = <YnabSubTransaction>[];
    int allocated = 0;
    for (int i = 0; i < nonSourcePostings.length; i++) {
      final posting = nonSourcePostings[i];
      final account = await _accountDao.findById(posting.accountId);
      final isTransfer = account?.ynabTransferPayeeId != null;

      // Proportional share of the source amount, last posting gets remainder
      final int amount;
      if (i == nonSourcePostings.length - 1) {
        amount = sourcePosting.amountMilliunits - allocated;
      } else {
        amount = totalNonSource == 0
            ? 0
            : (sourcePosting.amountMilliunits *
                    posting.amountMilliunits.abs() /
                    totalNonSource)
                .round();
        allocated += amount;
      }

      subtransactions.add(YnabSubTransaction(
        amount: amount,
        payeeId: isTransfer ? account!.ynabTransferPayeeId : null,
        payeeName: !isTransfer ? account?.ynabName ?? account?.ledgerName : null,
        categoryId: !isTransfer ? account?.ynabId : null,
        memo: posting.memo,
      ));
    }

    return YnabSaveTransaction(
      accountId: ynabAccountId,
      date: date,
      amount: sourcePosting.amountMilliunits,
      payeeName: tx.payeeName,
      memo: memo,
      subtransactions: subtransactions,
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Formats a date as a YNAB month string: "YYYY-MM-01"
  String _formatMonth(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$y-$m-01';
  }

  /// Syncs a budget move by PATCHing the budgeted amount on each category.
  /// Budget move postings are all mirror postings — each has a ynabId pointing
  /// to a YNAB category. We adjust each category's budgeted amount by the
  /// posting's amount.
  Future<YnabSyncResult> _syncBudgetMove(TransactionRow tx) async {
    final postings = await _transactionDao.postingsForTransaction(tx.id);
    final month = _formatMonth(tx.budgetMonth ?? tx.date);

    for (final posting in postings) {
      final account = await _accountDao.findById(posting.accountId);
      final categoryId = account?.ynabId;

      if (categoryId == null) {
        await _transactionDao.updateSyncStatus(
          transactionId: tx.id,
          ynabStatus: 'failed',
        );
        return YnabSyncResult(
          transactionId: tx.id,
          success: false,
          error:
              'Budget move posting "${account?.ledgerName ?? posting.accountId}" '
              'has no YNAB category linked.',
        );
      }

      // Fetch the current budgeted amount and add our delta
      // YNAB PATCH replaces the budgeted value, so we need to read first
      try {
        final current = await _client.getCategoryBudgeted(
          _budgetId,
          categoryId,
          month,
        );
        await _client.patchCategoryBudgeted(
          _budgetId,
          categoryId,
          month,
          current + posting.amountMilliunits,
        );
      } catch (e) {
        await _transactionDao.updateSyncStatus(
          transactionId: tx.id,
          ynabStatus: 'failed',
        );
        return YnabSyncResult(
          transactionId: tx.id,
          success: false,
          error: 'Failed to patch category $categoryId: $e',
        );
      }
    }

    await _transactionDao.updateSyncStatus(
      transactionId: tx.id,
      ynabStatus: 'synced',
    );
    return YnabSyncResult(transactionId: tx.id, success: true);
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final ynabSyncRepositoryProvider = Provider<YnabSyncRepository?>((ref) {
  final client = ref.watch(ynabClientProvider);
  final settings = ref.watch(settingsProvider).valueOrNull;

  if (client == null || settings?.ynabBudgetId == null) return null;

  return YnabSyncRepository(
    client: client,
    budgetId: settings!.ynabBudgetId!,
    transactionDao: ref.watch(transactionDaoProvider),
    accountDao: ref.watch(accountDaoProvider),
  );
});
