import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
import '../../repositories/ynab/ynab_sync_repository.dart';
import '../../repositories/ledger/ledger_sync_repository.dart';
import '../../repositories/git/git_sync_repository.dart';
import '../../routing/router.dart';
import '../../services/settings_service.dart';
import '../../widgets/ynab_mapping_sheet.dart';

bool get _isDesktop =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;

// Provider for unlinked accounts in pending transactions
final _unlinkedAccountsProvider =
    StreamProvider<List<AccountRow>>((ref) {
  return ref
      .watch(accountDaoProvider)
      .watchUnlinkedAccountsInPendingTransactions();
});

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
      body: Column(
        children: [
          // Unlinked accounts banner
          ref.watch(_unlinkedAccountsProvider).maybeWhen(
                data: (accounts) => accounts.isEmpty
                    ? const SizedBox.shrink()
                    : _UnlinkedAccountsBanner(accounts: accounts),
                orElse: () => const SizedBox.shrink(),
              ),
          // Transaction list
          Expanded(
            child: pendingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (transactions) => transactions.isEmpty
                  ? const Center(child: Text('No pending transactions.'))
                  : _TransactionList(transactions: transactions),
            ),
          ),
        ],
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

class _TransactionList extends ConsumerWidget {
  final List<TransactionRow> transactions;

  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionTile(tx: tx);
      },
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  final TransactionRow tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(_transactionTotalProvider(tx.id));

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _delete(ref),
      child: ListTile(
        title: Text(tx.payeeName),
        subtitle: Text(tx.date.toLocal().toString().substring(0, 10)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total amount
            totalAsync.maybeWhen(
              data: (total) => Text(
                _formatAmount(total),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: total < 0
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            _SyncStatusIndicator(tx: tx),
            if (_isDesktop)
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error),
                tooltip: 'Delete',
                onPressed: () async {
                  final confirmed = await _confirmDelete(context);
                  if (confirmed == true) await _delete(ref);
                },
              ),
          ],
        ),
        onTap: () => context.push(Routes.transactionDetailPath(tx.id)),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('Delete transaction for "${tx.payeeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(WidgetRef ref) async {
    await ref.read(transactionDaoProvider).deletePostingsForTransaction(tx.id);
    await ref.read(transactionDaoProvider).deleteTransaction(tx.id);
  }

  String _formatAmount(int milliunits) {
    final isNegative = milliunits < 0;
    final abs = milliunits.abs();
    final dollars = abs ~/ 1000;
    final cents = (abs % 1000) ~/ 10;
    final sign = isNegative ? '-' : '';
    return '\$$sign$dollars.${cents.toString().padLeft(2, '0')}';
  }
}

/// Sums the positive (outflow from source) real postings for a transaction.
/// Shows the meaningful "spend" amount rather than the net zero total.
final _transactionTotalProvider =
    FutureProvider.autoDispose.family<int, String>((ref, transactionId) async {
  final postings = await ref
      .read(transactionDaoProvider)
      .postingsForTransaction(transactionId);
  // Sum non-mirror postings with positive amounts (the receiving side)
  return postings
      .where((p) => !p.isBudgetMirror && p.amountMilliunits > 0)
      .fold<int>(0, (sum, p) => sum + p.amountMilliunits);
});

class _SyncStatusIndicator extends StatelessWidget {
  final TransactionRow tx;

  const _SyncStatusIndicator({required this.tx});

  @override
  Widget build(BuildContext context) {
    final ynabDone = tx.ynabSyncStatus == 'synced';
    final ledgerDone = tx.ledgerSyncStatus == 'synced';
    final anyFailed =
        tx.ynabSyncStatus == 'failed' || tx.ledgerSyncStatus == 'failed';

    if (ynabDone && ledgerDone) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (anyFailed) {
      return const Icon(Icons.error, color: Colors.red);
    }
    return const Icon(Icons.schedule, color: Colors.orange);
  }
}

class _UnlinkedAccountsBanner extends ConsumerWidget {
  final List<AccountRow> accounts;
  const _UnlinkedAccountsBanner({required this.accounts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialBanner(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      content: Text(
        '${accounts.length} account${accounts.length == 1 ? '' : 's'} '
        'need${accounts.length == 1 ? 's' : ''} a YNAB mapping before sync.',
      ),
      leading: Icon(Icons.link_off,
          color: Theme.of(context).colorScheme.error),
      actions: [
        TextButton(
          onPressed: () => context.push(Routes.unlinkedAccounts),
          child: const Text('Link Now'),
        ),
        TextButton(
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text('Dismiss'),
        ),
      ],
    );
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

    // Option D: check for unlinked accounts before syncing to YNAB
    if (ynabSync != null) {
      final unlinked = await ref
          .read(accountDaoProvider)
          .unlinkedAccountsInPendingTransactions();

      if (unlinked.isNotEmpty && context.mounted) {
        final proceed = await _showUnlinkedDialog(context, ref);
        if (!proceed || !context.mounted) return;
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing...')),
    );

    int ynabSucceeded = 0, ynabFailed = 0;
    int ledgerSucceeded = 0, ledgerFailed = 0;
    bool gitSuccess = false;
    String? gitError;

    try {
      if (ynabSync != null) {
        final results = await ynabSync.syncPending();
        ynabSucceeded = results.where((r) => r.success).length;
        ynabFailed = results.where((r) => !r.success).length;
        if (ynabFailed > 0) {
          final errors = results
              .where((r) => !r.success && r.error != null)
              .map((r) => r.error!)
              .join('; ');
          debugPrint('YNAB sync failures: $errors');
          gitError = errors; // reuse for display
        }
      }
    } catch (e, st) {
      debugPrint('YNAB sync exception: $e\n$st');
      ynabFailed++;
    }

    try {
      if (ledgerSync != null) {
        final results = await ledgerSync.syncPending();
        ledgerSucceeded = results.where((r) => r.success).length;
        ledgerFailed = results.where((r) => !r.success).length;
      }
    } catch (e) {
      ledgerFailed++;
    }

    // Git push — only on Android, runs independently of ledger sync result
    if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
      try {
        // gitSyncProvider is a FutureProvider — read the future directly
        final gitRepo = await ref.read(gitSyncProvider.future);
        if (gitRepo != null) {
          await gitRepo.commitAndPush(
            authorName: 'Double Entry',
            authorEmail: 'double_entry@localhost',
          );
          gitSuccess = true;
        }
      } catch (e, st) {
        debugPrint('Git sync error: $e\n$st');
        gitError = e.toString();
      }
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
    if (gitError != null && gitSuccess == false) {
      parts.add('Git: failed — $gitError');
    } else if (gitSuccess) {
      parts.add('Git: pushed');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(parts.join(' · ')),
        backgroundColor: (totalFailed > 0 || gitError != null)
            ? Theme.of(context).colorScheme.error
            : null,
        duration:
            Duration(seconds: (totalFailed > 0 || gitError != null) ? 6 : 3),
      ),
    );
  }

  /// Shows a dialog listing unlinked accounts with options to link or skip.
  /// Returns true if the user wants to proceed with sync anyway.
  Future<bool> _showUnlinkedDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const _UnlinkedAccountsDialog(),
    );
    return result ?? false;
  }
}

class _UnlinkedAccountsDialog extends ConsumerWidget {
  const _UnlinkedAccountsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlinkedAsync = ref.watch(_unlinkedAccountsProvider);

    return AlertDialog(
      title: const Text('Unlinked Accounts'),
      content: unlinkedAsync.when(
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('Error: $e'),
        data: (unlinked) => unlinked.isEmpty
            ? const Text('All accounts are now linked. Ready to sync.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The following account${unlinked.length == 1 ? '' : 's'} '
                    '${unlinked.length == 1 ? 'has' : 'have'} no YNAB mapping. '
                    'YNAB sync may fail for affected transactions.',
                  ),
                  const SizedBox(height: 12),
                  ...unlinked.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.link_off, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(a.ledgerName)),
                            TextButton(
                              onPressed: () =>
                                  showYnabMappingSheet(context, ref, a),
                              child: const Text('Link'),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(unlinkedAsync.valueOrNull?.isEmpty == true
              ? 'Sync'
              : 'Sync Anyway'),
        ),
      ],
    );
  }
}
