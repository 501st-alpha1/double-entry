import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';

const _uuid = Uuid();

/// Represents a single editable posting row in the form.
/// Only real (non-mirror) postings are shown; budget mirrors are derived on save.
class PostingFormRow {
  final String rowId; // stable key for widget list
  final Account? account;
  final String amountRaw; // raw string as the user types it
  final String memo;

  const PostingFormRow({
    required this.rowId,
    this.account,
    this.amountRaw = '',
    this.memo = '',
  });

  /// Parsed amount in milliunits, or null if unparseable.
  int? get amountMilliunits {
    final cleaned = amountRaw.replaceAll(RegExp(r'[,$]'), '');
    final value = double.tryParse(cleaned);
    if (value == null) return null;
    return (value * 1000).round();
  }

  bool get isValid => account != null && amountMilliunits != null;

  PostingFormRow copyWith({
    Account? account,
    String? amountRaw,
    String? memo,
  }) {
    return PostingFormRow(
      rowId: rowId,
      account: account ?? this.account,
      amountRaw: amountRaw ?? this.amountRaw,
      memo: memo ?? this.memo,
    );
  }
}

/// The full state of the transaction form.
class TransactionFormState {
  final TransactionType type;
  final DateTime date;
  final DateTime time;
  final Payee? payee;
  final String payeeNameRaw; // raw text while user is typing
  final List<PostingFormRow> postingRows;
  final String note;
  final bool savePayeeDefaults;

  const TransactionFormState({
    this.type = TransactionType.expense,
    required this.date,
    required this.time,
    this.payee,
    this.payeeNameRaw = '',
    this.postingRows = const [],
    this.note = '',
    this.savePayeeDefaults = false,
  });

  /// Total of all posting amounts in milliunits.
  /// For a balanced transaction this should be zero.
  int get totalMilliunits =>
      postingRows.fold(0, (sum, row) => sum + (row.amountMilliunits ?? 0));

  /// Whether the form has enough data to save.
  bool get isValid =>
      payeeNameRaw.isNotEmpty &&
      postingRows.isNotEmpty &&
      postingRows.every((r) => r.isValid);

  TransactionFormState copyWith({
    TransactionType? type,
    DateTime? date,
    DateTime? time,
    Payee? payee,
    String? payeeNameRaw,
    List<PostingFormRow>? postingRows,
    String? note,
    bool? savePayeeDefaults,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      payee: payee ?? this.payee,
      payeeNameRaw: payeeNameRaw ?? this.payeeNameRaw,
      postingRows: postingRows ?? this.postingRows,
      note: note ?? this.note,
      savePayeeDefaults: savePayeeDefaults ?? this.savePayeeDefaults,
    );
  }
}

/// Notifier that manages the transaction form state.
class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  TransactionFormNotifier()
      : super(TransactionFormState(
          date: DateTime.now(),
          time: DateTime.now(),
          postingRows: [PostingFormRow(rowId: _uuid.v4())],
        ));

  void setType(TransactionType type) {
    state = state.copyWith(type: type);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setTime(DateTime time) {
    state = state.copyWith(time: time);
  }

  void setPayee(Payee? payee, String rawName) {
    if (payee != null) {
      // Autofill posting rows from payee default template
      final template = payee.defaultTemplate;
      final rows = template.postingTemplates
          .where((t) => !t.isBudgetMirror)
          .map((t) => PostingFormRow(
                rowId: _uuid.v4(),
                account: t.account,
                amountRaw: t.defaultAmountMilliunits != null
                    ? (t.defaultAmountMilliunits! / 1000).toStringAsFixed(2)
                    : '',
                memo: t.memo ?? '',
              ))
          .toList();

      state = state.copyWith(
        payee: payee,
        payeeNameRaw: rawName,
        postingRows: rows.isNotEmpty
            ? rows
            : [PostingFormRow(rowId: _uuid.v4())],
      );
    } else {
      state = state.copyWith(
        payee: null,
        payeeNameRaw: rawName,
      );
    }
  }

  void updatePostingAccount(String rowId, Account account) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) => r.rowId == rowId ? r.copyWith(account: account) : r)
          .toList(),
    );
  }

  void updatePostingAmount(String rowId, String amountRaw) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) =>
              r.rowId == rowId ? r.copyWith(amountRaw: amountRaw) : r)
          .toList(),
    );
  }

  void updatePostingMemo(String rowId, String memo) {
    state = state.copyWith(
      postingRows: state.postingRows
          .map((r) => r.rowId == rowId ? r.copyWith(memo: memo) : r)
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
      postingRows:
          state.postingRows.where((r) => r.rowId != rowId).toList(),
    );
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void setSavePayeeDefaults(bool value) {
    state = state.copyWith(savePayeeDefaults: value);
  }

  void reset() {
    state = TransactionFormState(
      date: DateTime.now(),
      time: DateTime.now(),
      postingRows: [PostingFormRow(rowId: _uuid.v4())],
    );
  }
}

final transactionFormProvider =
    StateNotifierProvider.autoDispose<TransactionFormNotifier, TransactionFormState>(
  (ref) => TransactionFormNotifier(),
);
