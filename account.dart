/// Represents a financial account that exists in both YNAB and Ledger,
/// potentially under different names.
class Account {
  final String id;

  /// The full colon-separated Ledger account name, e.g. "Assets:Bank:Checking".
  /// Enter with proper capitalization as it should appear in the Ledger file.
  final String ledgerName;

  /// The YNAB account UUID, null if this account is Ledger-only (e.g. budget mirrors)
  final String? ynabId;

  /// The YNAB display name, e.g. "Checking". Used for display purposes only.
  final String? ynabName;

  const Account({
    required this.id,
    required this.ledgerName,
    this.ynabId,
    this.ynabName,
  });

  /// The display name: prefers YNAB name if available, otherwise the Ledger name.
  String get displayName => ynabName ?? ledgerName;

  /// Derives the corresponding budget mirror account name by convention.
  /// e.g. "Expenses:Food" -> "Assets:Budget:Food"
  /// Returns null if this account is not an expenses account.
  /// TODO: support custom patterns here.
  String? get budgetMirrorLedgerName {
    if (!ledgerName.toLowerCase().startsWith('expenses:')) return null;
    final subcategory = ledgerName.substring(ledgerName.indexOf(':') + 1);
    return 'Assets:Budget:$subcategory';
  }

  Account copyWith({
    String? id,
    String? ledgerName,
    String? ynabId,
    String? ynabName,
  }) {
    return Account(
      id: id ?? this.id,
      ledgerName: ledgerName ?? this.ledgerName,
      ynabId: ynabId ?? this.ynabId,
      ynabName: ynabName ?? this.ynabName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Account && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Account($ledgerName)';
}
