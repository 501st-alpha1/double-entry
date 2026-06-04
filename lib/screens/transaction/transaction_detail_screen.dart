import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
import '../../routing/router.dart';

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────

/// Holds a transaction row and its resolved posting rows with account names.
class TransactionDetail {
  final TransactionRow transaction;
  final List<_PostingDetail> postings;

  const TransactionDetail({
    required this.transaction,
    required this.postings,
  });
}

class _PostingDetail {
  final PostingRow posting;
  final String accountLedgerName;
  final bool isBudgetMirror;

  const _PostingDetail({
    required this.posting,
    required this.accountLedgerName,
    required this.isBudgetMirror,
  });
}

final _transactionDetailProvider =
    FutureProvider.autoDispose.family<TransactionDetail?, String>(
  (ref, transactionId) async {
    final transactionDao = ref.watch(transactionDaoProvider);
    final accountDao = ref.watch(accountDaoProvider);

    final tx = await transactionDao.findById(transactionId);
    if (tx == null) return null;

    final postingRows =
        await transactionDao.postingsForTransaction(transactionId);

    final postings = await Future.wait(
      postingRows.map((p) async {
        final account = await accountDao.findById(p.accountId);
        return _PostingDetail(
          posting: p,
          accountLedgerName: account?.ledgerName ?? p.accountId,
          isBudgetMirror: p.isBudgetMirror,
        );
      }),
    );

    return TransactionDetail(transaction: tx, postings: postings);
  },
);

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(_transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
        actions: [
          detailAsync.maybeWhen(
            data: (detail) => detail != null
                ? IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                    onPressed: () =>
                        context.push(Routes.editTransactionPath(transactionId)),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (detail) => detail == null
            ? const Center(child: Text('Transaction not found.'))
            : _DetailView(detail: detail),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Detail view
// ─────────────────────────────────────────────

class _DetailView extends StatelessWidget {
  final TransactionDetail detail;

  const _DetailView({required this.detail});

  @override
  Widget build(BuildContext context) {
    final tx = detail.transaction;
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Type chip
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            label: Text(_typeLabel(tx.type)),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 16),

        // Date / time row
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Date',
                value: _formatDate(tx.date),
                labelStyle: labelStyle,
              ),
            ),
            Expanded(
              child: _Field(
                label: 'Time',
                value: _formatTime(tx.time),
                labelStyle: labelStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Payee
        _Field(
          label: 'Payee',
          value: tx.payeeName,
          labelStyle: labelStyle,
        ),
        const SizedBox(height: 12),

        // Note
        if (tx.note != null && tx.note!.isNotEmpty) ...[
          _Field(
            label: 'Note',
            value: tx.note!,
            labelStyle: labelStyle,
          ),
          const SizedBox(height: 12),
        ],

        // Postings
        Text('Postings', style: labelStyle),
        const SizedBox(height: 6),
        ...detail.postings
            .where((p) => !p.isBudgetMirror)
            .map((p) => _PostingTile(posting: p)),

        // Sync status
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SyncStatusTile(
                label: 'YNAB',
                status: tx.ynabSyncStatus,
              ),
            ),
            Expanded(
              child: _SyncStatusTile(
                label: 'Ledger',
                status: tx.ledgerSyncStatus,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _typeLabel(String type) => switch (type) {
        'expense' => 'Expense',
        'budgetMove' => 'Budget Move',
        'transfer' => 'Transfer',
        _ => type,
      };

  String _formatDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;

  const _Field({
    required this.label,
    required this.value,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _PostingTile extends StatelessWidget {
  final _PostingDetail posting;

  const _PostingTile({required this.posting});

  @override
  Widget build(BuildContext context) {
    final amount = _formatAmount(posting.posting.amountMilliunits);
    final isNegative = posting.posting.amountMilliunits < 0;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(posting.accountLedgerName,
                style: theme.textTheme.bodyMedium),
          ),
          Text(
            amount,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isNegative
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int milliunits) {
    final isNegative = milliunits < 0;
    final abs = milliunits.abs();
    final dollars = abs ~/ 1000;
    final cents = (abs % 1000) ~/ 10;
    final formatted = '\$$dollars.${cents.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }
}

class _SyncStatusTile extends StatelessWidget {
  final String label;
  final String status;

  const _SyncStatusTile({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      'synced' => (Icons.check_circle_outline, Colors.green),
      'failed' => (Icons.error_outline, Colors.red),
      _ => (Icons.schedule, Colors.orange),
    };

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text('$label: $status',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
