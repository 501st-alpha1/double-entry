import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
import '../../models/models.dart' as models;
import 'ledger_output_repository.dart';

/// Result of a Ledger sync attempt for a single transaction.
class LedgerSyncResult {
  final String transactionId;
  final bool success;
  final String? error;

  const LedgerSyncResult({
    required this.transactionId,
    required this.success,
    this.error,
  });
}

/// Loads pending transactions from the DB, converts them to domain model
/// objects, writes them to the Ledger output file, and updates sync status.
class LedgerSyncRepository {
  final LedgerOutputRepository _output;
  final TransactionDao _transactionDao;
  final AccountDao _accountDao;

  LedgerSyncRepository({
    required LedgerOutputRepository output,
    required TransactionDao transactionDao,
    required AccountDao accountDao,
  })  : _output = output,
        _transactionDao = transactionDao,
        _accountDao = accountDao;

  Future<List<LedgerSyncResult>> syncPending() async {
    final pending = await _transactionDao.pendingTransactions();
    final toSync = pending
        .where((t) =>
            t.ledgerSyncStatus == 'pending' || t.ledgerSyncStatus == 'failed')
        .toList();

    if (toSync.isEmpty) return [];

    // Build domain model transactions for all pending rows
    final entries = <({String id, models.Transaction transaction})>[];
    for (final tx in toSync) {
      try {
        final transaction = await _buildTransaction(tx);
        entries.add((id: tx.id, transaction: transaction));
      } catch (e) {
        // If we can't build the model, mark as failed immediately
        await _transactionDao.updateSyncStatus(
          transactionId: tx.id,
          ledgerStatus: 'failed',
        );
      }
    }

    if (entries.isEmpty) {
      return toSync
          .map((t) => LedgerSyncResult(
                transactionId: t.id,
                success: false,
                error: 'Failed to build transaction model',
              ))
          .toList();
    }

    // Write all to file in one operation
    try {
      await _output.write(entries.map((e) => e.transaction).toList());

      // Mark all as synced
      final results = <LedgerSyncResult>[];
      for (final entry in entries) {
        await _transactionDao.updateSyncStatus(
          transactionId: entry.id,
          ledgerStatus: 'synced',
        );
        results.add(LedgerSyncResult(
          transactionId: entry.id,
          success: true,
        ));
      }
      return results;
    } on LedgerOutputException catch (e) {
      // File write failed — mark all as failed
      final results = <LedgerSyncResult>[];
      for (final entry in entries) {
        await _transactionDao.updateSyncStatus(
          transactionId: entry.id,
          ledgerStatus: 'failed',
        );
        results.add(LedgerSyncResult(
          transactionId: entry.id,
          success: false,
          error: e.toString(),
        ));
      }
      return results;
    }
  }

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  Future<models.Transaction> _buildTransaction(TransactionRow tx) async {
    final postingRows =
        await _transactionDao.postingsForTransaction(tx.id);

    final postings = await Future.wait(postingRows.map((p) async {
      final accountRow = await _accountDao.findById(p.accountId);
      final account = models.Account(
        id: accountRow?.id ?? p.accountId,
        ledgerName: accountRow?.ledgerName ?? p.accountId,
        ynabId: accountRow?.ynabId,
        ynabName: accountRow?.ynabName,
      );
      return models.Posting(
        account: account,
        amountMilliunits: p.amountMilliunits,
        memo: p.memo,
        isBudgetMirror: p.isBudgetMirror,
      );
    }));

    final type = models.TransactionType.values.firstWhere(
      (t) => t.name == tx.type,
      orElse: () => models.TransactionType.expense,
    );

    return models.Transaction(
      id: tx.id,
      type: type,
      date: tx.date,
      time: tx.time,
      payee: tx.payeeName,
      postings: postings,
      note: tx.note,
      createdAt: tx.createdAt,
      budgetMonth: tx.budgetMonth,
    );
  }
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

final ledgerSyncRepositoryProvider = Provider<LedgerSyncRepository?>((ref) {
  final output = ref.watch(ledgerOutputRepositoryProvider);
  if (output == null) return null;

  return LedgerSyncRepository(
    output: output,
    transactionDao: ref.watch(transactionDaoProvider),
    accountDao: ref.watch(accountDaoProvider),
  );
});
