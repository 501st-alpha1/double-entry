import 'package:drift/drift.dart' as drift show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart' as db;
import '../../models/models.dart';
import 'transaction_form_state.dart';
import '../../widgets/payee_typeahead.dart';
import '../../widgets/account_typeahead.dart';

const _uuid = Uuid();

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Type selector ──────────────────────────
            _TypeSelector(
              value: formState.type,
              onChanged: notifier.setType,
            ),
            const SizedBox(height: 16),

            // ── Date & time row ────────────────────────
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    date: formState.date,
                    onChanged: notifier.setDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    time: formState.time,
                    onChanged: notifier.setTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Payee ──────────────────────────────────
            PayeeTypeahead(
              initialValue: formState.payeeNameRaw,
              onSelected: (payee, name) => notifier.setPayee(payee, name),
            ),
            const SizedBox(height: 16),

            // ── Posting rows ───────────────────────────
            _PostingRows(
              rows: formState.postingRows,
              type: formState.type,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: notifier.addPostingRow,
              icon: const Icon(Icons.add),
              label: const Text('Add posting'),
            ),

            // ── Running total (shown for splits) ───────
            if (formState.postingRows.length > 1)
              _RunningTotal(totalMilliunits: formState.totalMilliunits),

            const SizedBox(height: 16),

            // ── Note ───────────────────────────────────
            TextField(
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Optional',
              ),
              onChanged: notifier.setNote,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // ── Save payee defaults ────────────────────
            if (formState.payee == null && formState.payeeNameRaw.isNotEmpty)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Save as default for this payee'),
                value: formState.savePayeeDefaults,
                onChanged: (v) => notifier.setSavePayeeDefaults(v ?? false),
              ),

            const SizedBox(height: 24),

            // ── Action buttons ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: formState.isValid
                        ? () => _save(context, ref, andNew: false)
                        : null,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: formState.isValid
                        ? () => _save(context, ref, andNew: true)
                        : null,
                    child: const Text('Save & New'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref, {
    required bool andNew,
  }) async {
    final formState = ref.read(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);
    final transactionDao = ref.read(transactionDaoProvider);
    final payeeDao = ref.read(payeeDaoProvider);

    final txId = _uuid.v4();
    final now = DateTime.now();

    // Save payee defaults if requested and payee is new
    if (formState.savePayeeDefaults && formState.payee == null) {
      final payeeId = _uuid.v4();
      final templateId = _uuid.v4();

      await payeeDao.upsertPayee(db.PayeesCompanion.insert(
        id: payeeId,
        name: formState.payeeNameRaw,
      ));
      await payeeDao.upsertTemplate(db.PayeeTemplatesCompanion.insert(
        id: templateId,
        payeeId: payeeId,
        name: 'default',
        transactionType: formState.type.name,
      ));

      for (var i = 0; i < formState.postingRows.length; i++) {
        final row = formState.postingRows[i];
        if (row.account == null) continue;
        await payeeDao.upsertPostingTemplate(
          db.PostingTemplatesCompanion.insert(
            id: _uuid.v4(),
            payeeTemplateId: templateId,
            accountId: row.account!.id,
            sortOrder: drift.Value(i),
          ),
        );
      }
    }

    // Insert the transaction
    await transactionDao.insertTransaction(
      db.TransactionsCompanion.insert(
        id: txId,
        type: formState.type.name,
        date: formState.date,
        time: formState.time,
        payeeName: formState.payeeNameRaw,
        note: drift.Value(formState.note.isEmpty ? null : formState.note),
        createdAt: now,
      ),
    );

    // Insert real postings
    for (var i = 0; i < formState.postingRows.length; i++) {
      final row = formState.postingRows[i];
      if (!row.isValid) continue;
      await transactionDao.insertPosting(
        db.PostingsCompanion.insert(
          id: _uuid.v4(),
          transactionId: txId,
          accountId: row.account!.id,
          amountMilliunits: row.amountMilliunits!,
          memo: drift.Value(row.memo.isEmpty ? null : row.memo),
          sortOrder: drift.Value(i),
        ),
      );
    }

    if (andNew) {
      notifier.reset();
    } else {
      if (context.mounted) context.pop();
    }
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  const _TypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.shopping_cart),
        ),
        ButtonSegment(
          value: TransactionType.budgetMove,
          label: Text('Budget Move'),
          icon: Icon(Icons.swap_horiz),
        ),
        ButtonSegment(
          value: TransactionType.transfer,
          label: Text('Transfer'),
          icon: Icon(Icons.account_balance),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DateField({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label =
        '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          suffixIcon: Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(label),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final DateTime time;
  final ValueChanged<DateTime> onChanged;

  const _TimeField({required this.time, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(time),
        );
        if (picked != null) {
          onChanged(DateTime(
            time.year, time.month, time.day,
            picked.hour, picked.minute,
          ));
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Time',
          suffixIcon: Icon(Icons.access_time, size: 18),
        ),
        child: Text(label),
      ),
    );
  }
}

class _PostingRows extends ConsumerWidget {
  final List<PostingFormRow> rows;
  final TransactionType type;

  const _PostingRows({required this.rows, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFormProvider.notifier);

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PostingRowWidget(
            row: row,
            canRemove: rows.length > 1,
            onAccountSelected: (account) =>
                notifier.updatePostingAccount(row.rowId, account),
            onAmountChanged: (v) =>
                notifier.updatePostingAmount(row.rowId, v),
            onMemoChanged: (v) =>
                notifier.updatePostingMemo(row.rowId, v),
            onRemove: () => notifier.removePostingRow(row.rowId),
          ),
        );
      }).toList(),
    );
  }
}

class _PostingRowWidget extends StatelessWidget {
  final PostingFormRow row;
  final bool canRemove;
  final ValueChanged<Account> onAccountSelected;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onMemoChanged;
  final VoidCallback onRemove;

  const _PostingRowWidget({
    required this.row,
    required this.canRemove,
    required this.onAccountSelected,
    required this.onAmountChanged,
    required this.onMemoChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AccountTypeahead(
                    initialValue: row.account?.displayName ?? '',
                    onSelected: onAccountSelected,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    controller: TextEditingController(text: row.amountRaw)
                      ..selection = TextSelection.collapsed(
                          offset: row.amountRaw.length),
                    onChanged: onAmountChanged,
                  ),
                ),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: onRemove,
                    tooltip: 'Remove posting',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Memo',
                hintText: 'Optional',
              ),
              controller: TextEditingController(text: row.memo)
                ..selection =
                    TextSelection.collapsed(offset: row.memo.length),
              onChanged: onMemoChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _RunningTotal extends StatelessWidget {
  final int totalMilliunits;

  const _RunningTotal({required this.totalMilliunits});

  @override
  Widget build(BuildContext context) {
    final isBalanced = totalMilliunits == 0;
    final dollars = totalMilliunits.abs() ~/ 1000;
    final cents = (totalMilliunits.abs() % 1000) ~/ 10;
    final sign = totalMilliunits < 0 ? '-' : '+';
    final label = isBalanced
        ? 'Balanced'
        : 'Total: $sign\$$dollars.${cents.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: isBalanced
                ? Colors.green
                : Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isBalanced
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
