import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
import '../../repositories/ynab/ynab_sync_repository.dart';
import '../../repositories/ledger/ledger_sync_repository.dart';
import '../../routing/router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(_pendingTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Double Entry'),
        actions: [
          pendingAsync.maybeWhen(
            data: (transactions) => transactions.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: 'Sync ${transactions.length} pending',
                    onPressed: () => _sync(context, ref),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transactions) => transactions.isEmpty
            ? const Center(child: Text('No pending transactions.'))
            : _TransactionList(transactions: transactions),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.newTransaction),
        tooltip: 'New transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Watches the pending transactions stream from the database.
final _pendingTransactionsProvider =
    StreamProvider<List<TransactionRow>>((ref) {
  return ref.watch(transactionDaoProvider).watchPendingTransactions();
});

class _TransactionList extends StatelessWidget {
  final List<TransactionRow> transactions;

  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return ListTile(
          title: Text(tx.payeeName),
          subtitle: Text(tx.date.toLocal().toString().substring(0, 10)),
          trailing: _SyncStatusIndicator(tx: tx),
          onTap: () => context.push(Routes.transactionDetailPath(tx.id)),
        );
      },
    );
  }
}

class _SyncStatusIndicator extends StatelessWidget {
  final TransactionRow tx;

  const _SyncStatusIndicator({required this.tx});

  @override
  Widget build(BuildContext context) {
    final ynabDone = tx.ynabSyncStatus == 'synced';
    final ledgerDone = tx.ledgerSyncStatus == 'synced';

    if (ynabDone && ledgerDone) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (tx.ynabSyncStatus == 'failed' || tx.ledgerSyncStatus == 'failed') {
      return const Icon(Icons.error, color: Colors.red);
    }
    return const Icon(Icons.schedule, color: Colors.orange);
  }
}

extension _HomeScreenSync on HomeScreen {
  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final ynabSync = ref.read(ynabSyncRepositoryProvider);
    final ledgerSync = ref.read(ledgerSyncRepositoryProvider);

    if (ynabSync == null && ledgerSync == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing configured. Check Settings.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing...')),
    );

    int ynabSucceeded = 0, ynabFailed = 0;
    int ledgerSucceeded = 0, ledgerFailed = 0;
    final errors = <String>[];

    try {
      if (ynabSync != null) {
        final results = await ynabSync.syncPending();
        ynabSucceeded = results.where((r) => r.success).length;
        ynabFailed = results.where((r) => !r.success).length;
        errors.addAll(results
            .where((r) => !r.success && r.error != null)
            .map((r) => 'YNAB: ${r.error}'));
      }
    } catch (e) {
      errors.add('YNAB: $e');
    }

    try {
      if (ledgerSync != null) {
        final results = await ledgerSync.syncPending();
        ledgerSucceeded = results.where((r) => r.success).length;
        ledgerFailed = results.where((r) => !r.success).length;
        errors.addAll(results
            .where((r) => !r.success && r.error != null)
            .map((r) => 'Ledger: ${r.error}'));
      }
    } catch (e) {
      errors.add('Ledger: $e');
    }

    if (!context.mounted) return;

    final totalFailed = ynabFailed + ledgerFailed;
    final parts = <String>[];
    if (ynabSync != null) {
      parts.add('YNAB: $ynabSucceeded synced'
          '${ynabFailed > 0 ? ', $ynabFailed failed' : ''}');
    }
    if (ledgerSync != null) {
      parts.add('Ledger: $ledgerSucceeded synced'
          '${ledgerFailed > 0 ? ', $ledgerFailed failed' : ''}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(parts.join(' · ')),
        backgroundColor:
            totalFailed > 0 ? Theme.of(context).colorScheme.error : null,
        duration: Duration(seconds: errors.isEmpty ? 3 : 6),
      ),
    );
  }
}

