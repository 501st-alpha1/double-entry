import 'account.dart';
import 'transaction.dart';

/// A template for a single posting within a payee default.
/// Stores the account and an optional default amount.
class PostingTemplate {
  final Account account;

  /// Optional default amount in milliunits. Null means user must enter it.
  final int? defaultAmountMilliunits;

  final String? memo;
  final bool isBudgetMirror;

  /// Whether autofill should pre-fill the amount from
  /// defaultAmountMilliunits. Always false for now — reserved for a
  /// future "remember amount" toggle. The amount is still saved/updated
  /// on every save regardless of this flag.
  final bool applyDefaultAmount;

  const PostingTemplate({
    required this.account,
    this.defaultAmountMilliunits,
    this.memo,
    this.isBudgetMirror = false,
    this.applyDefaultAmount = false,
  });

  PostingTemplate copyWith({
    Account? account,
    int? defaultAmountMilliunits,
    String? memo,
    bool? isBudgetMirror,
    bool? applyDefaultAmount,
  }) {
    return PostingTemplate(
      account: account ?? this.account,
      defaultAmountMilliunits:
          defaultAmountMilliunits ?? this.defaultAmountMilliunits,
      memo: memo ?? this.memo,
      isBudgetMirror: isBudgetMirror ?? this.isBudgetMirror,
      applyDefaultAmount: applyDefaultAmount ?? this.applyDefaultAmount,
    );
  }
}

/// A named template variation for a payee.
/// v1 only uses the default template; named variations are supported in the
/// data model so v2 can add a template picker without a schema migration.
class PayeeTemplate {
  final String id;

  /// "default" for the primary template; a descriptive name for variations
  /// e.g. "cash back", "online order".
  final String name;

  final TransactionType transactionType;

  /// The posting templates for this variation, in order.
  /// Does not include budget mirror postings — those are derived at runtime.
  final List<PostingTemplate> postingTemplates;

  const PayeeTemplate({
    required this.id,
    required this.name,
    required this.transactionType,
    required this.postingTemplates,
  });

  bool get isDefault => name == 'default';
}

/// A payee with one or more posting templates for autofill.
class Payee {
  final String id;
  final String name;

  /// All templates for this payee. Always contains at least one (the default).
  final List<PayeeTemplate> templates;

  const Payee({
    required this.id,
    required this.name,
    required this.templates,
  });

  /// The default template used for autofill in v1.
  PayeeTemplate get defaultTemplate =>
      templates.firstWhere((t) => t.isDefault, orElse: () => templates.first);

  Payee copyWith({
    String? id,
    String? name,
    List<PayeeTemplate>? templates,
  }) {
    return Payee(
      id: id ?? this.id,
      name: name ?? this.name,
      templates: templates ?? this.templates,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Payee && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Payee($name)';
}
