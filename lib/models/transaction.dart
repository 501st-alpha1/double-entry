import 'posting.dart';

/// The three shapes a transaction can take.
enum TransactionType {
  /// Real posting(s) + budget mirror posting(s). Most common.
  expense,

  /// Budget mirror postings only. No real money movement.
  budgetMove,

  /// Real posting only (e.g. bank -> credit card, bank -> bank).
  transfer,
}

/// The sync state of a transaction against an external system.
enum SyncStatus {
  /// Not yet synced.
  pending,

  /// Successfully synced.
  synced,

  /// Sync attempted but failed.
  failed,
}

/// A complete financial transaction destined for both YNAB and Ledger.
///
/// Amounts across all postings must sum to zero (enforced at the repository layer,
/// not in the model itself to allow in-progress editing).
class Transaction {
  final String id;
  final TransactionType type;
  final DateTime date;

  /// The payee name, e.g. "Whole Foods".
  final String payee;

  /// All postings, including budget mirror postings.
  /// Real postings come first by convention.
  final List<Posting> postings;

  /// Free-text note. Maps to YNAB transaction memo and Ledger transaction comment.
  final String? note;

  final SyncStatus ynabSyncStatus;
  final SyncStatus ledgerSyncStatus;

  /// The YNAB transaction ID, populated after successful YNAB sync.
  final String? ynabTransactionId;

  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.date,
    required this.payee,
    required this.postings,
    this.note,
    this.ynabSyncStatus = SyncStatus.pending,
    this.ledgerSyncStatus = SyncStatus.pending,
    this.ynabTransactionId,
    required this.createdAt,
  });

  /// Whether this transaction is fully synced to both systems.
  bool get isFullySynced =>
      ynabSyncStatus == SyncStatus.synced &&
      ledgerSyncStatus == SyncStatus.synced;

  /// Real (non-mirror) postings only.
  List<Posting> get realPostings =>
      postings.where((p) => !p.isBudgetMirror).toList();

  /// Budget mirror postings only.
  List<Posting> get budgetPostings =>
      postings.where((p) => p.isBudgetMirror).toList();

  /// Validates that all postings sum to zero.
  bool get isBalanced =>
      postings.fold(0, (sum, p) => sum + p.amountMilliunits) == 0;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    DateTime? date,
    String? payee,
    List<Posting>? postings,
    String? note,
    SyncStatus? ynabSyncStatus,
    SyncStatus? ledgerSyncStatus,
    String? ynabTransactionId,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      payee: payee ?? this.payee,
      postings: postings ?? this.postings,
      note: note ?? this.note,
      ynabSyncStatus: ynabSyncStatus ?? this.ynabSyncStatus,
      ledgerSyncStatus: ledgerSyncStatus ?? this.ledgerSyncStatus,
      ynabTransactionId: ynabTransactionId ?? this.ynabTransactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Transaction && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Transaction($id, $type, $payee, ${date.toIso8601String()})';
}
