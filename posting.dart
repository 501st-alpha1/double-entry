import 'account.dart';

/// A single line in a double-entry transaction, associating an account
/// with an amount (in milliunits, e.g. 10000 = $10.00).
///
/// A transaction's postings must sum to zero.
class Posting {
  /// The account this posting applies to.
  final Account account;

  /// Amount in milliunits (1000 = $1.00). Negative = money leaving the account.
  final int amountMilliunits;

  /// Optional per-posting memo (maps to Ledger inline comment, YNAB memo on splits).
  final String? memo;

  /// Whether this is a budget mirror posting (assets:budget:* or liabilities:budget).
  /// Budget mirror postings are generated automatically and hidden in the UI by default.
  final bool isBudgetMirror;

  const Posting({
    required this.account,
    required this.amountMilliunits,
    this.memo,
    this.isBudgetMirror = false,
  });

  /// Amount as a human-readable decimal string, e.g. "-10.00"
  String get displayAmount {
    final dollars = amountMilliunits ~/ 1000;
    final cents = (amountMilliunits.abs() % 1000) ~/ 10;
    final sign = amountMilliunits < 0 ? '-' : '';
    return '$sign${dollars.abs()}.${cents.toString().padLeft(2, '0')}';
  }

  Posting copyWith({
    Account? account,
    int? amountMilliunits,
    String? memo,
    bool? isBudgetMirror,
  }) {
    return Posting(
      account: account ?? this.account,
      amountMilliunits: amountMilliunits ?? this.amountMilliunits,
      memo: memo ?? this.memo,
      isBudgetMirror: isBudgetMirror ?? this.isBudgetMirror,
    );
  }

  @override
  String toString() =>
      'Posting(${account.ledgerName}, $displayAmount, mirror: $isBudgetMirror)';
}
