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
        .where((t) => t.ynabSyncStatus == 'pending')
        .toList();

    if (toSync.isEmpty) return [];

    final results = <YnabSyncResult>[];

    for (final tx in toSync) {
      try {
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
      } catch (e) {
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
    // The source posting's amount is the total; each non-source
    // posting becomes a subtransaction.
    final subtransactions = <YnabSubTransaction>[];
    for (final posting in nonSourcePostings) {
      final account = await _accountDao.findById(posting.accountId);
      subtransactions.add(YnabSubTransaction(
        amount: posting.amountMilliunits,
        // If the target is an account with a YNAB ID, it's a transfer
        payeeId: account?.ynabId != null
            ? 'transfer:${account!.ynabId}'
            : null,
        payeeName:
            account?.ynabId == null ? account?.ynabName ?? account?.ledgerName : null,
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
