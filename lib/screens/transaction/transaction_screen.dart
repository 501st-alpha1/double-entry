import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart' show AccountRow, PayeeRow, AccountSearchFilter;
import '../../repositories/ynab/ynab_reference_data.dart';
import '../../widgets/keyboard_autocomplete.dart';
import '../../widgets/ynab_mapping_sheet.dart';
import 'transaction_form_state.dart';
import 'transaction_form_notifier.dart';

/// Converts a Drift [PayeeRow] to a minimal model [Payee] for use in the form.
/// Templates are not loaded here — selectPayee in the notifier handles that.
Payee _payeeRowToModel(PayeeRow row) => Payee(
      id: row.id,
      name: row.name,
      templates: const [],
    );

/// Converts a Drift [AccountRow] to a model [Account].
Account _accountRowToModel(AccountRow row) => Account(
      id: row.id,
      ledgerName: row.ledgerName,
      ynabId: row.ynabId,
      ynabName: row.ynabName,
    );

class TransactionScreen extends ConsumerStatefulWidget {
  final String? editTransactionId;

  const TransactionScreen({super.key, this.editTransactionId});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    // If editing, load the existing transaction after the first frame
    if (widget.editTransactionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(transactionFormProvider.notifier)
            .initializeFromExisting(widget.editTransactionId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final isEditing = widget.editTransactionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'New Transaction'),
        actions: [
          TextButton(
            onPressed: formState.isValid
                ? () => _save(context, ref, saveAndNew: false)
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error banner
            if (formState.error != null)
              _ErrorBanner(message: formState.error!),

            // Transaction type selector
            _TypeSelector(),
            const SizedBox(height: 16),

            // Date and time row
            _DateTimeRow(),
            const SizedBox(height: 16),

            // Payee field
            _PayeeField(),
            const SizedBox(height: 16),

            // Posting rows
            _PostingRowList(),
            const SizedBox(height: 8),

            // Add posting button (only for split-capable types)
            if (formState.type != TransactionType.transfer)
              TextButton.icon(
                onPressed: () => ref
                    .read(transactionFormProvider.notifier)
                    .addPostingRow(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add posting'),
              ),
            const SizedBox(height: 16),

            // Running total
            _RunningTotal(),
            const SizedBox(height: 16),

            // Note field
            _NoteField(),
            const SizedBox(height: 24),

            // Save buttons
            _SaveButtons(isEditing: isEditing),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref,
      {required bool saveAndNew}) async {
    final notifier = ref.read(transactionFormProvider.notifier);
    final success = await notifier.save(
      existingId: widget.editTransactionId,
    );
    if (success && context.mounted) {
      if (saveAndNew) {
        // Pop and immediately push a fresh form
        context.pop();
        context.push('/transaction/new');
      } else {
        context.pop();
      }
    }
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _TypeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(transactionFormProvider).type;
    final notifier = ref.read(transactionFormProvider.notifier);

    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.shopping_cart_outlined),
        ),
        ButtonSegment(
          value: TransactionType.budgetMove,
          label: Text('Budget Move'),
          icon: Icon(Icons.swap_horiz),
        ),
        ButtonSegment(
          value: TransactionType.transfer,
          label: Text('Transfer'),
          icon: Icon(Icons.account_balance_outlined),
        ),
      ],
      selected: {type},
      onSelectionChanged: (selected) => notifier.setType(selected.first),
    );
  }
}

class _DateTimeRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(_formatDate(state.date)),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) notifier.setDate(picked);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.access_time, size: 16),
            label: Text(_formatTime(state.time)),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(state.time),
              );
              if (picked != null) {
                final updated = DateTime(
                  state.time.year,
                  state.time.month,
                  state.time.day,
                  picked.hour,
                  picked.minute,
                );
                notifier.setTime(updated);
              }
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _PayeeField extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PayeeField> createState() => _PayeeFieldState();
}

class _PayeeFieldState extends ConsumerState<_PayeeField> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(transactionFormProvider.notifier);

    return KeyboardAutocomplete<PayeeRow>(
      displayStringForOption: (p) => p.name,
      optionsBuilder: (textEditingValue) async {
        // Keep payeeNameRaw in sync with whatever is in the field
        notifier.setPayeeRaw(textEditingValue.text);
        if (textEditingValue.text.isEmpty) return [];
        final payeeDao = ref.read(payeeDaoProvider);
        return payeeDao.search(textEditingValue.text);
      },
      onSelected: (row) => notifier.selectPayee(_payeeRowToModel(row)),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Payee',
            hintText: 'e.g. Whole Foods',
          ),
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }
}

class _PostingRowList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(transactionFormProvider).rows;

    return Column(
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PostingRow(row: row),
              ))
          .toList(),
    );
  }
}

class _PostingRow extends ConsumerStatefulWidget {
  final PostingFormRow row;

  const _PostingRow({required this.row});

  @override
  ConsumerState<_PostingRow> createState() => _PostingRowState();
}

class _PostingRowState extends ConsumerState<_PostingRow> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.row.amountRaw);
  }

  @override
  void didUpdateWidget(_PostingRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller if state was updated externally (e.g. payee autofill)
    if (oldWidget.row.amountRaw != widget.row.amountRaw &&
        _amountController.text != widget.row.amountRaw) {
      _amountController.text = widget.row.amountRaw;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(transactionFormProvider.notifier);
    final rows = ref.watch(transactionFormProvider).postingRows;
    final row = widget.row;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source account indicator — only shown when multiple rows exist
        if (rows.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Tooltip(
              message: row.isSource ? 'YNAB source account' : 'Set as YNAB source account',
              child: IconButton(
                icon: Icon(
                  row.isSource ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 20,
                  color: row.isSource
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                onPressed: () => notifier.setSourcePosting(row.rowId),
              ),
            ),
          ),
        Expanded(
          flex: 3,
          child: _AccountTypeahead(
            rowId: row.rowId,
            selectedAccount: row.account,
            onSelected: (account) =>
                notifier.setPostingAccount(row.rowId, account),
            transactionType: ref.watch(transactionFormProvider).type,
          ),
        ),
        const SizedBox(width: 8),

        // Amount field
        Expanded(
          flex: 2,
          child: TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '\$',
              errorText: row.amountRaw.isNotEmpty &&
                      row.amountMilliunits == null
                  ? 'Invalid'
                  : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            onChanged: (v) => notifier.setPostingAmount(row.rowId, v),
          ),
        ),

        // YNAB link button (shown when account has no ynabId)
        _buildLinkButton(context, row),

        // Remove button (only shown when more than one row)
        if (rows.length > 1)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            tooltip: 'Remove posting',
            onPressed: () => notifier.removePostingRow(row.rowId),
          )
        else
          const SizedBox(width: 40), // maintain alignment
      ],
    );
  }

  /// Shows the mapping sheet but returns the selection as (ynabId, ynabName)
  /// instead of writing to the DB. Used for unsaved accounts.
  Future<(String, String)?> _showInMemoryMappingSheet(
      BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<(String, String)?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _InMemoryMappingSheet(),
    );
  }

  /// Shows the YNAB link button if the account has no ynabId,
  /// including accounts that haven't been saved to the DB yet.
  Widget _buildLinkButton(BuildContext context, PostingFormRow row) {
    if (row.account == null) return const SizedBox.shrink();
    final notifier = ref.read(transactionFormProvider.notifier);

    // Account not yet in DB (typed manually) — show mapping sheet
    // and store selection in form state for application on save
    if (row.account!.id.isEmpty) {
      final hasPending = row.pendingYnabId != null;
      return Tooltip(
        message: hasPending
            ? 'Linked to YNAB: ${row.pendingYnabName}'
            : 'Link to YNAB',
        child: IconButton(
          icon: Icon(
            hasPending ? Icons.link : Icons.link,
            size: 18,
            color: hasPending
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
          onPressed: () async {
            final result = await _showInMemoryMappingSheet(context, ref);
            if (result != null) {
              notifier.setPendingYnabMapping(
                  row.rowId, result.$1, result.$2);
            }
          },
        ),
      );
    }

    // Account in DB — check if it has a ynabId
    return FutureBuilder<AccountRow?>(
      future: ref.read(accountDaoProvider).findById(row.account!.id),
      builder: (context, snap) {
        final dbAccount = snap.data;
        if (dbAccount == null || dbAccount.ynabId != null) {
          return const SizedBox.shrink();
        }
        return Tooltip(
          message: 'Link to YNAB',
          child: IconButton(
            icon: Icon(Icons.link,
                size: 18, color: Theme.of(context).colorScheme.error),
            onPressed: () async {
              await showYnabMappingSheet(context, ref, dbAccount);
            },
          ),
        );
      },
    );
  }
}

class _AccountTypeahead extends ConsumerStatefulWidget {
  final String rowId;
  final Account? selectedAccount;
  final ValueChanged<Account> onSelected;
  final TransactionType transactionType;

  const _AccountTypeahead({
    required this.rowId,
    required this.selectedAccount,
    required this.onSelected,
    required this.transactionType,
  });

  @override
  ConsumerState<_AccountTypeahead> createState() => _AccountTypeaheadState();
}

class _AccountTypeaheadState extends ConsumerState<_AccountTypeahead> {
  @override
  Widget build(BuildContext context) {
    return KeyboardAutocomplete<AccountRow>(
      displayStringForOption: (a) => a.ledgerName,
      initialValue: widget.selectedAccount != null
          ? TextEditingValue(text: widget.selectedAccount!.ledgerName)
          : null,
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) return [];
        final accountDao = ref.read(accountDaoProvider);
        final filter = switch (widget.transactionType) {
          TransactionType.expense => AccountSearchFilter.expense,
          TransactionType.budgetMove => AccountSearchFilter.budgetMove,
          TransactionType.transfer => AccountSearchFilter.transfer,
        };
        return accountDao.search(textEditingValue.text, filter: filter);
      },
      onSelected: (row) => widget.onSelected(_accountRowToModel(row)),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        // Commit whatever is typed when the field loses focus,
        // creating a minimal Account if no suggestion was selected.
        focusNode.addListener(() {
          if (!focusNode.hasFocus && controller.text.trim().isNotEmpty) {
            final text = controller.text.trim();
            // Only commit if the account isn't already set to this value
            if (widget.selectedAccount?.ledgerName != text) {
              widget.onSelected(Account(
                id: '', // will be resolved or created on save
                ledgerName: text,
              ));
            }
          }
        });
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Account',
            hintText: 'e.g. Expenses:Food',
          ),
        );
      },
    );
  }
}

class _RunningTotal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormProvider);
    final theme = Theme.of(context);
    final isZero = state.totalMilliunits == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Total: ', style: theme.textTheme.bodySmall),
        Text(
          state.totalDisplay,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isZero
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}

class _NoteField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFormProvider.notifier);

    return TextField(
      decoration: const InputDecoration(
        labelText: 'Note',
        hintText: 'Optional memo for both YNAB and Ledger',
      ),
      maxLines: 2,
      onChanged: notifier.setNote,
    );
  }
}

class _SaveButtons extends ConsumerWidget {
  final bool isEditing;

  const _SaveButtons({required this.isEditing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormProvider);

    if (state.isSaving) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: state.isValid
                ? () => _save(context, ref, saveAndNew: false)
                : null,
            child: const Text('Save'),
          ),
        ),
        if (!isEditing) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: state.isValid
                  ? () => _save(context, ref, saveAndNew: true)
                  : null,
              child: const Text('Save & New'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref,
      {required bool saveAndNew}) async {
    final notifier = ref.read(transactionFormProvider.notifier);
    final success = await notifier.save();
    if (success && context.mounted) {
      if (saveAndNew) {
        context.pop();
        context.push('/transaction/new');
      } else {
        context.pop();
      }
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

extension on TransactionFormState {
  List<PostingFormRow> get rows => postingRows;
}

/// A mapping sheet variant that returns the selected (ynabId, ynabName)
/// without writing to the DB. Used for accounts not yet saved.
class _InMemoryMappingSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refDataAsync = ref.watch(ynabReferenceDataProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Link to YNAB',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: refDataAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Failed to load YNAB data: $e')),
                data: (refData) {
                  if (refData == null) {
                    return const Center(child: Text('YNAB not configured.'));
                  }
                  return ListView(
                    controller: scrollController,
                    children: [
                      _MappingHeader(
                          title: 'Accounts (${refData.activeAccounts.length})'),
                      ...refData.activeAccounts.map((a) => ListTile(
                            title: Text(a.name),
                            onTap: () =>
                                Navigator.pop(context, (a.id, a.name)),
                          )),
                      const _MappingHeader(title: 'Categories'),
                      ...refData.categoriesByGroup.entries.expand((entry) => [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 2),
                              child: Text(entry.key,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      )),
                            ),
                            ...entry.value.map((cat) => ListTile(
                                  title: Text(cat.name),
                                  onTap: () => Navigator.pop(
                                      context, (cat.id, cat.name)),
                                )),
                          ]),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MappingHeader extends StatelessWidget {
  final String title;
  const _MappingHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
