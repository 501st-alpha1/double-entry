import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart' as db;
import '../../database/database.dart' show PayeeDao;
import '../../models/models.dart';
import 'transaction_form_state.dart';

const _uuid = Uuid();

/// Manages the state of the transaction form.
class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final Ref _ref;

  TransactionFormNotifier(this._ref)
      : super(TransactionFormState(
          date: DateTime.now(),
          time: DateTime.now(),
          postingRows: [PostingFormRow(rowId: _uuid.v4(), isSource: true)],
        ));

  // ─────────────────────────────────────────────
  // Field updates
  // ─────────────────────────────────────────────

  void setType(TransactionType type) {
    state = state.copyWith(type: type, postingRows: [
      PostingFormRow(rowId: _uuid.v4(), isSource: true),
    ]);
  }

  void setDate(DateTime date) => state = state.copyWith(date: date);

  void setTime(DateTime time) => state = state.copyWith(time: time);

  void setNote(String note) => state = state.copyWith(note: note);

  /// Called when the user types in the payee field.
  /// Only clears the resolved payee if the name no longer matches it.
  void setPayeeRaw(String name) {
    final currentPayee = state.payee;
    final nameMatchesSelected =
        currentPayee != null && currentPayee.name == name.trim();
    if (nameMatchesSelected) return;
    state = state.copyWith(payeeNameRaw: name, clearPayee: true);
  }

  /// Called when the user selects a payee from the typeahead.
  /// Autofills posting rows from the payee's default template.
  void selectPayee(Payee payee) {
    final template = payee.defaultTemplate;
    final rows = template.postingTemplates
        .where((t) => !t.isBudgetMirror)
        .toList();

    final formRows = rows.asMap().entries.map((e) => PostingFormRow(
          rowId: _uuid.v4(),
          account: e.value.account,
          amountRaw: e.value.defaultAmountMilliunits != null
              ? _milliunitsToRaw(e.value.defaultAmountMilliunits!)
              : '',
          memo: e.value.memo,
          isSource: e.key == 0, // first row is source by default
        )).toList();

    state = state.copyWith(
      payee: payee,
      payeeNameRaw: payee.name,
      postingRows: formRows.isEmpty
          ? [PostingFormRow(rowId: _uuid.v4(), isSource: true)]
          : formRows,
    );
  }

  /// Sets which posting row is the YNAB source account.
  /// Clears isSource on all other rows.
  void setSourcePosting(String rowId) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) => r.copyWith(isSource: r.rowId == rowId))
          .toList(),
    );
  }

  // ─────────────────────────────────────────────
  // Posting row management
  // ─────────────────────────────────────────────

  void setPostingAccount(String rowId, Account account) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) => r.rowId == rowId ? r.copyWith(account: account) : r)
          .toList(),
    );
  }

  void setPostingAmount(String rowId, String amountRaw) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) => r.rowId == rowId ? r.copyWith(amountRaw: amountRaw) : r)
          .toList(),
    );
  }

  void setPostingMemo(String rowId, String memo) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) => r.rowId == rowId ? r.copyWith(memo: memo) : r)
          .toList(),
    );
  }

  /// Stores a pending YNAB mapping for an unsaved account.
  /// Applied to the account record when the transaction is saved.
  void setPendingYnabMapping(
      String rowId, String ynabId, String ynabName) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) => r.rowId == rowId
              ? r.copyWith(pendingYnabId: ynabId, pendingYnabName: ynabName)
              : r)
          .toList(),
    );
  }

  void addPostingRow() {
    state = state.copyWith(
      postingRows: [
        ...state.postingRows,
        PostingFormRow(rowId: _uuid.v4()),
      ],
    );
  }

  void removePostingRow(String rowId) {
    if (state.postingRows.length <= 1) return; // always keep at least one row
    state = state.copyWith(
      postingRows: state.postingRows.where((r) => r.rowId != rowId).toList(),
    );
  }

  /// Loads an existing transaction into the form for editing.
  Future<void> initializeFromExisting(String transactionId) async {
    final transactionDao = _ref.read(transactionDaoProvider);
    final accountDao = _ref.read(accountDaoProvider);

    final tx = await transactionDao.findById(transactionId);
    if (tx == null) return;

    final postingRows = await transactionDao.postingsForTransaction(transactionId);

    // Build posting rows from real (non-mirror) postings only
    final rows = await Future.wait(
      postingRows
          .where((p) => !p.isBudgetMirror)
          .map((p) async {
            final accountRow = await accountDao.findById(p.accountId);
            final account = accountRow != null
                ? Account(
                    id: accountRow.id,
                    ledgerName: accountRow.ledgerName,
                    ynabId: accountRow.ynabId,
                    ynabName: accountRow.ynabName,
                  )
                : null;
            return PostingFormRow(
              rowId: _uuid.v4(),
              account: account,
              amountRaw: _milliunitsToRaw(p.amountMilliunits),
              memo: p.memo,
              isSource: p.isSource,
            );
          }),
    );

    // Parse TransactionType from stored string
    final type = TransactionType.values.firstWhere(
      (t) => t.name == tx.type,
      orElse: () => TransactionType.expense,
    );

    state = TransactionFormState(
      type: type,
      date: tx.date,
      time: tx.time,
      payeeNameRaw: tx.payeeName,
      postingRows: rows.isEmpty ? [PostingFormRow(rowId: _uuid.v4())] : rows,
      note: tx.note,
    );
  }

  /// Saves the transaction to the local queue and optionally updates
  /// the payee's default template.
  /// If [existingId] is provided, deletes the old record and reinserts.
  Future<bool> save({bool savePayeeDefaults = false, String? existingId}) async {
    if (!state.isValid) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final transactionId = existingId ?? _uuid.v4();
      final now = DateTime.now();
      final transactionDao = _ref.read(transactionDaoProvider);
      final payeeDao = _ref.read(payeeDaoProvider);

      // Resolve or create payee
      final payeeId = await _resolvePayeeId(payeeDao, savePayeeDefaults);

      // If editing, delete old postings and update the transaction row in place.
      // This preserves the original createdAt and transaction ID.
      if (existingId != null) {
        await transactionDao.deletePostingsForTransaction(existingId);
        await transactionDao.updateTransaction(
          existingId,
          db.TransactionsCompanion(
            type: Value(state.type.name),
            date: Value(state.date),
            time: Value(state.time),
            payeeId: Value(payeeId),
            payeeName: Value(state.payeeNameRaw.trim()),
            note: Value(state.note),
          ),
        );
      } else {
        // New transaction — insert fresh
        await transactionDao.insertTransaction(
          db.TransactionsCompanion.insert(
            id: transactionId,
            type: state.type.name,
            date: state.date,
            time: state.time,
            payeeId: Value(payeeId),
            payeeName: state.payeeNameRaw.trim(),
            note: Value(state.note),
            createdAt: now,
          ),
        );
      }

      // Insert real postings + derived budget mirror postings
      int sortOrder = 0;
      for (final row in state.postingRows) {
        final amount = row.amountMilliunits!;

        // Resolve or create the account, applying any pending YNAB mapping
        final accountId = await _resolveOrCreateAccount(
          row.account!.ledgerName,
          existingId: row.account!.id.isNotEmpty ? row.account!.id : null,
          pendingYnabId: row.pendingYnabId,
          pendingYnabName: row.pendingYnabName,
        );

        // Real posting
        await transactionDao.insertPosting(
          db.PostingsCompanion.insert(
            id: _uuid.v4(),
            transactionId: transactionId,
            accountId: accountId,
            amountMilliunits: amount,
            memo: Value(row.memo),
            isBudgetMirror: const Value(false),
            isSource: Value(row.isSource),
            sortOrder: Value(sortOrder++),
          ),
        );

        // Budget mirror posting (derived from expense account convention)
        final mirrorName = row.account!.budgetMirrorLedgerName;
        if (mirrorName != null && state.type == TransactionType.expense) {
          final mirrorAccountId = await _resolveOrCreateAccount(
            mirrorName,
          );
          // Real posting moves money out; mirror moves budget balance
          await transactionDao.insertPosting(
            db.PostingsCompanion.insert(
              id: _uuid.v4(),
              transactionId: transactionId,
              accountId: mirrorAccountId,
              amountMilliunits: -amount,
              isBudgetMirror: const Value(true),
              sortOrder: Value(sortOrder++),
            ),
          );

          // Offset posting against liabilities:budget
          final offsetAccountId = await _resolveOrCreateAccount(
            '[Liabilities:Budget]',
          );
          await transactionDao.insertPosting(
            db.PostingsCompanion.insert(
              id: _uuid.v4(),
              transactionId: transactionId,
              accountId: offsetAccountId,
              amountMilliunits: amount,
              isBudgetMirror: const Value(true),
              sortOrder: Value(sortOrder++),
            ),
          );
        }
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save: $e',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  Future<String?> _resolvePayeeId(
      PayeeDao payeeDao, bool saveDefaults) async {
    if (state.payee != null) {
      if (saveDefaults) {
        // TODO: update payee default template from current posting rows
      }
      return state.payee!.id;
    }

    // New payee — create a minimal record
    final id = _uuid.v4();
    await payeeDao.upsertPayee(
      db.PayeesCompanion.insert(id: id, name: state.payeeNameRaw.trim()),
    );
    return id;
  }

  /// Finds an account by ledgerName or creates a minimal record if not found.
  /// If [existingId] is provided and valid, uses it directly to skip the lookup.
  /// If [pendingYnabId] is provided, applies it when creating a new account.
  Future<String> _resolveOrCreateAccount(String ledgerName,
      {String? existingId,
      String? pendingYnabId,
      String? pendingYnabName}) async {
    if (existingId != null && existingId.isNotEmpty) return existingId;

    final accountDao = _ref.read(accountDaoProvider);
    final existing = await accountDao.allAccounts().then(
          (list) => list.where((a) => a.ledgerName == ledgerName).firstOrNull,
        );
    if (existing != null) return existing.id;

    final id = _uuid.v4();
    await accountDao.upsert(
      db.AccountsCompanion.insert(
        id: id,
        ledgerName: ledgerName,
        ynabId: Value(pendingYnabId),
        ynabName: Value(pendingYnabName),
      ),
    );
    return id;
  }

  String _milliunitsToRaw(int milliunits) {
    final isNegative = milliunits < 0;
    final abs = milliunits.abs();
    final dollars = abs ~/ 1000;
    final cents = (abs % 1000) ~/ 10;
    final value = '$dollars.${cents.toString().padLeft(2, '0')}';
    return isNegative ? '-$value' : value;
  }
}

/// Provider for the transaction form notifier.
/// autoDispose ensures state is reset when the screen is popped.
final transactionFormProvider = StateNotifierProvider.autoDispose<
    TransactionFormNotifier, TransactionFormState>(
  (ref) => TransactionFormNotifier(ref),
);
