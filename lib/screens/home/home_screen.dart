import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
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
                    onPressed: () {
                      // TODO: trigger sync
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
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
          onTap: () => context.push(Routes.editTransactionPath(tx.id)),
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

