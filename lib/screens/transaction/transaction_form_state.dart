import '../../models/models.dart';

/// Represents a single editable posting row in the transaction form.
/// Only real (non-mirror) postings are shown to the user.
class PostingFormRow {
  final String rowId; // local UI identity, not persisted
  final Account? account;
  final String amountRaw; // raw string as the user types it
  final String? memo;

  /// Whether this is the primary source account for YNAB sync.
  final bool isSource;

  /// Pending YNAB mapping for unsaved accounts, applied when the account
  /// record is created on save.
  final String? pendingYnabId;
  final String? pendingYnabName;

  const PostingFormRow({
    required this.rowId,
    this.account,
    this.amountRaw = '',
    this.memo,
    this.isSource = false,
    this.pendingYnabId,
    this.pendingYnabName,
  });

  /// Parses amountRaw to milliunits. Returns null if invalid or empty.
  int? get amountMilliunits {
    final cleaned = amountRaw.replaceAll(RegExp(r'[^\d.\-]'), '');
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return null;
    return (parsed * 1000).round();
  }

  bool get isValid => account != null && amountMilliunits != null;

  PostingFormRow copyWith({
    Account? account,
    String? amountRaw,
    String? memo,
    bool? isSource,
    String? pendingYnabId,
    String? pendingYnabName,
    bool clearPendingYnab = false,
  }) {
    return PostingFormRow(
      rowId: rowId,
      account: account ?? this.account,
      amountRaw: amountRaw ?? this.amountRaw,
      memo: memo ?? this.memo,
      isSource: isSource ?? this.isSource,
      pendingYnabId: clearPendingYnab ? null : (pendingYnabId ?? this.pendingYnabId),
      pendingYnabName: clearPendingYnab ? null : (pendingYnabName ?? this.pendingYnabName),
    );
  }
}

/// The complete state of the transaction form at any point in time.
class TransactionFormState {
  final TransactionType type;
  final DateTime date;
  final DateTime time;
  final Payee? payee;
  final String payeeNameRaw; // raw text field value
  final List<PostingFormRow> postingRows;
  final String? note;

  /// Whether the form has been submitted and is awaiting save.
  final bool isSaving;

  /// Validation error message, if any.
  final String? error;

  /// The budget move payee from settings, used when type is budgetMove
  /// and the payee field is hidden.
  final String? budgetMovePayee;

  const TransactionFormState({
    this.type = TransactionType.expense,
    required this.date,
    required this.time,
    this.payee,
    this.payeeNameRaw = '',
    this.postingRows = const [],
    this.note,
    this.isSaving = false,
    this.error,
    this.budgetMovePayee,
  });

  /// The sum of all posting amounts in milliunits.
  /// For a balanced transaction this should be zero (credits + debits cancel).
  int get totalMilliunits =>
      postingRows.fold(0, (sum, row) => sum + (row.amountMilliunits ?? 0));

  /// Display string for the running total, e.g. "$0.00" or "-$12.50"
  String get totalDisplay {
    final m = totalMilliunits;
    final isNegative = m < 0;
    final abs = m.abs();
    final dollars = abs ~/ 1000;
    final cents = (abs % 1000) ~/ 10;
    final formatted = '\$$dollars.${cents.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }

  /// True when all posting rows are valid, the form is ready to save,
  /// and postings sum to zero (required by Ledger double-entry).
  bool get isValid =>
      _hasPayee &&
      postingRows.isNotEmpty &&
      postingRows.every((r) => r.isValid) &&
      totalMilliunits == 0 &&
      !isSaving;

  /// True if a payee is provided either via the field or the budget move default.
  bool get _hasPayee =>
      payeeNameRaw.trim().isNotEmpty ||
      (type == TransactionType.budgetMove && budgetMovePayee != null);

  TransactionFormState copyWith({
    TransactionType? type,
    DateTime? date,
    DateTime? time,
    Payee? payee,
    bool clearPayee = false,
    String? payeeNameRaw,
    List<PostingFormRow>? postingRows,
    String? note,
    bool? isSaving,
    String? error,
    bool clearError = false,
    String? budgetMovePayee,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      payee: clearPayee ? null : (payee ?? this.payee),
      payeeNameRaw: payeeNameRaw ?? this.payeeNameRaw,
      postingRows: postingRows ?? this.postingRows,
      note: note ?? this.note,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      budgetMovePayee: budgetMovePayee ?? this.budgetMovePayee,
    );
  }
}
