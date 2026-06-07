/// Lightweight models for YNAB API responses.
/// These are separate from the app's domain models to keep the API
/// contract isolated from internal representation.

class YnabBudget {
  final String id;
  final String name;

  const YnabBudget({required this.id, required this.name});

  factory YnabBudget.fromJson(Map<String, dynamic> json) => YnabBudget(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}

class YnabAccount {
  final String id;
  final String name;
  final bool onBudget;
  final bool closed;
  final bool deleted;

  /// The special payee ID used to create transfers to this account.
  final String? transferPayeeId;

  const YnabAccount({
    required this.id,
    required this.name,
    required this.onBudget,
    required this.closed,
    required this.deleted,
    this.transferPayeeId,
  });

  factory YnabAccount.fromJson(Map<String, dynamic> json) => YnabAccount(
        id: json['id'] as String,
        name: json['name'] as String,
        onBudget: json['on_budget'] as bool,
        closed: json['closed'] as bool,
        deleted: json['deleted'] as bool,
        transferPayeeId: json['transfer_payee_id'] as String?,
      );
}

class YnabCategory {
  final String id;
  final String name;
  final String groupName;
  final bool hidden;
  final bool deleted;

  const YnabCategory({
    required this.id,
    required this.name,
    required this.groupName,
    required this.hidden,
    required this.deleted,
  });

  factory YnabCategory.fromJson(
      Map<String, dynamic> json, String groupName) =>
      YnabCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        groupName: groupName,
        hidden: json['hidden'] as bool,
        deleted: json['deleted'] as bool,
      );
}

/// A transaction ready to be sent to the YNAB API.
class YnabSaveTransaction {
  final String accountId;
  final String date; // ISO 8601 e.g. "2024-01-15"
  final int amount; // milliunits
  final String? payeeId;
  final String? payeeName;
  final String? categoryId;
  final String? memo;
  final String cleared; // "cleared", "uncleared", "reconciled"
  final bool approved;

  /// Subtransactions for split transactions.
  final List<YnabSubTransaction>? subtransactions;

  const YnabSaveTransaction({
    required this.accountId,
    required this.date,
    required this.amount,
    this.payeeId,
    this.payeeName,
    this.categoryId,
    this.memo,
    this.cleared = 'uncleared',
    this.approved = false,
    this.subtransactions,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'account_id': accountId,
      'date': date,
      'amount': amount,
      'cleared': cleared,
      'approved': approved,
    };
    if (payeeId != null) map['payee_id'] = payeeId;
    if (payeeName != null) map['payee_name'] = payeeName;
    if (categoryId != null) map['category_id'] = categoryId;
    if (memo != null) map['memo'] = memo;
    if (subtransactions != null) {
      map['subtransactions'] = subtransactions!.map((s) => s.toJson()).toList();
    }
    return map;
  }
}

/// A subtransaction for split transactions in YNAB.
class YnabSubTransaction {
  final int amount; // milliunits
  final String? payeeId;
  final String? payeeName;
  final String? categoryId;
  final String? memo;

  const YnabSubTransaction({
    required this.amount,
    this.payeeId,
    this.payeeName,
    this.categoryId,
    this.memo,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'amount': amount};
    if (payeeId != null) map['payee_id'] = payeeId;
    if (payeeName != null) map['payee_name'] = payeeName;
    if (categoryId != null) map['category_id'] = categoryId;
    if (memo != null) map['memo'] = memo;
    return map;
  }
}

/// Wraps an API error response.
class YnabApiException implements Exception {
  final int statusCode;
  final String errorId;
  final String detail;

  const YnabApiException({
    required this.statusCode,
    required this.errorId,
    required this.detail,
  });

  @override
  String toString() =>
      'YnabApiException($statusCode): $errorId — $detail';
}
