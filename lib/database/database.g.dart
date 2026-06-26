// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ledgerNameMeta =
      const VerificationMeta('ledgerName');
  @override
  late final GeneratedColumn<String> ledgerName = GeneratedColumn<String>(
      'ledger_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ynabIdMeta = const VerificationMeta('ynabId');
  @override
  late final GeneratedColumn<String> ynabId = GeneratedColumn<String>(
      'ynab_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ynabNameMeta =
      const VerificationMeta('ynabName');
  @override
  late final GeneratedColumn<String> ynabName = GeneratedColumn<String>(
      'ynab_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ynabTransferPayeeIdMeta =
      const VerificationMeta('ynabTransferPayeeId');
  @override
  late final GeneratedColumn<String> ynabTransferPayeeId =
      GeneratedColumn<String>('ynab_transfer_payee_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ledgerName, ynabId, ynabName, ynabTransferPayeeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<AccountRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_name')) {
      context.handle(
          _ledgerNameMeta,
          ledgerName.isAcceptableOrUnknown(
              data['ledger_name']!, _ledgerNameMeta));
    } else if (isInserting) {
      context.missing(_ledgerNameMeta);
    }
    if (data.containsKey('ynab_id')) {
      context.handle(_ynabIdMeta,
          ynabId.isAcceptableOrUnknown(data['ynab_id']!, _ynabIdMeta));
    }
    if (data.containsKey('ynab_name')) {
      context.handle(_ynabNameMeta,
          ynabName.isAcceptableOrUnknown(data['ynab_name']!, _ynabNameMeta));
    }
    if (data.containsKey('ynab_transfer_payee_id')) {
      context.handle(
          _ynabTransferPayeeIdMeta,
          ynabTransferPayeeId.isAcceptableOrUnknown(
              data['ynab_transfer_payee_id']!, _ynabTransferPayeeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ledgerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ledger_name'])!,
      ynabId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ynab_id']),
      ynabName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ynab_name']),
      ynabTransferPayeeId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ynab_transfer_payee_id']),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String ledgerName;
  final String? ynabId;
  final String? ynabName;

  /// The YNAB transfer_payee_id for this account, used when creating
  /// transfer transactions via the API.
  final String? ynabTransferPayeeId;
  const AccountRow(
      {required this.id,
      required this.ledgerName,
      this.ynabId,
      this.ynabName,
      this.ynabTransferPayeeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_name'] = Variable<String>(ledgerName);
    if (!nullToAbsent || ynabId != null) {
      map['ynab_id'] = Variable<String>(ynabId);
    }
    if (!nullToAbsent || ynabName != null) {
      map['ynab_name'] = Variable<String>(ynabName);
    }
    if (!nullToAbsent || ynabTransferPayeeId != null) {
      map['ynab_transfer_payee_id'] = Variable<String>(ynabTransferPayeeId);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      ledgerName: Value(ledgerName),
      ynabId:
          ynabId == null && nullToAbsent ? const Value.absent() : Value(ynabId),
      ynabName: ynabName == null && nullToAbsent
          ? const Value.absent()
          : Value(ynabName),
      ynabTransferPayeeId: ynabTransferPayeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(ynabTransferPayeeId),
    );
  }

  factory AccountRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      ledgerName: serializer.fromJson<String>(json['ledgerName']),
      ynabId: serializer.fromJson<String?>(json['ynabId']),
      ynabName: serializer.fromJson<String?>(json['ynabName']),
      ynabTransferPayeeId:
          serializer.fromJson<String?>(json['ynabTransferPayeeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerName': serializer.toJson<String>(ledgerName),
      'ynabId': serializer.toJson<String?>(ynabId),
      'ynabName': serializer.toJson<String?>(ynabName),
      'ynabTransferPayeeId': serializer.toJson<String?>(ynabTransferPayeeId),
    };
  }

  AccountRow copyWith(
          {String? id,
          String? ledgerName,
          Value<String?> ynabId = const Value.absent(),
          Value<String?> ynabName = const Value.absent(),
          Value<String?> ynabTransferPayeeId = const Value.absent()}) =>
      AccountRow(
        id: id ?? this.id,
        ledgerName: ledgerName ?? this.ledgerName,
        ynabId: ynabId.present ? ynabId.value : this.ynabId,
        ynabName: ynabName.present ? ynabName.value : this.ynabName,
        ynabTransferPayeeId: ynabTransferPayeeId.present
            ? ynabTransferPayeeId.value
            : this.ynabTransferPayeeId,
      );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      ledgerName:
          data.ledgerName.present ? data.ledgerName.value : this.ledgerName,
      ynabId: data.ynabId.present ? data.ynabId.value : this.ynabId,
      ynabName: data.ynabName.present ? data.ynabName.value : this.ynabName,
      ynabTransferPayeeId: data.ynabTransferPayeeId.present
          ? data.ynabTransferPayeeId.value
          : this.ynabTransferPayeeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('ledgerName: $ledgerName, ')
          ..write('ynabId: $ynabId, ')
          ..write('ynabName: $ynabName, ')
          ..write('ynabTransferPayeeId: $ynabTransferPayeeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ledgerName, ynabId, ynabName, ynabTransferPayeeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.ledgerName == this.ledgerName &&
          other.ynabId == this.ynabId &&
          other.ynabName == this.ynabName &&
          other.ynabTransferPayeeId == this.ynabTransferPayeeId);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> ledgerName;
  final Value<String?> ynabId;
  final Value<String?> ynabName;
  final Value<String?> ynabTransferPayeeId;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.ledgerName = const Value.absent(),
    this.ynabId = const Value.absent(),
    this.ynabName = const Value.absent(),
    this.ynabTransferPayeeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String ledgerName,
    this.ynabId = const Value.absent(),
    this.ynabName = const Value.absent(),
    this.ynabTransferPayeeId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ledgerName = Value(ledgerName);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? ledgerName,
    Expression<String>? ynabId,
    Expression<String>? ynabName,
    Expression<String>? ynabTransferPayeeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerName != null) 'ledger_name': ledgerName,
      if (ynabId != null) 'ynab_id': ynabId,
      if (ynabName != null) 'ynab_name': ynabName,
      if (ynabTransferPayeeId != null)
        'ynab_transfer_payee_id': ynabTransferPayeeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? ledgerName,
      Value<String?>? ynabId,
      Value<String?>? ynabName,
      Value<String?>? ynabTransferPayeeId,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      ledgerName: ledgerName ?? this.ledgerName,
      ynabId: ynabId ?? this.ynabId,
      ynabName: ynabName ?? this.ynabName,
      ynabTransferPayeeId: ynabTransferPayeeId ?? this.ynabTransferPayeeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerName.present) {
      map['ledger_name'] = Variable<String>(ledgerName.value);
    }
    if (ynabId.present) {
      map['ynab_id'] = Variable<String>(ynabId.value);
    }
    if (ynabName.present) {
      map['ynab_name'] = Variable<String>(ynabName.value);
    }
    if (ynabTransferPayeeId.present) {
      map['ynab_transfer_payee_id'] =
          Variable<String>(ynabTransferPayeeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerName: $ledgerName, ')
          ..write('ynabId: $ynabId, ')
          ..write('ynabName: $ynabName, ')
          ..write('ynabTransferPayeeId: $ynabTransferPayeeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayeesTable extends Payees with TableInfo<$PayeesTable, PayeeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payees';
  @override
  VerificationContext validateIntegrity(Insertable<PayeeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayeeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayeeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $PayeesTable createAlias(String alias) {
    return $PayeesTable(attachedDatabase, alias);
  }
}

class PayeeRow extends DataClass implements Insertable<PayeeRow> {
  final String id;
  final String name;
  const PayeeRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PayeesCompanion toCompanion(bool nullToAbsent) {
    return PayeesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory PayeeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayeeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  PayeeRow copyWith({String? id, String? name}) => PayeeRow(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  PayeeRow copyWithCompanion(PayeesCompanion data) {
    return PayeeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayeeRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayeeRow && other.id == this.id && other.name == this.name);
}

class PayeesCompanion extends UpdateCompanion<PayeeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const PayeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayeesCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<PayeeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayeesCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return PayeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayeeTemplatesTable extends PayeeTemplates
    with TableInfo<$PayeeTemplatesTable, PayeeTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayeeTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payeeIdMeta =
      const VerificationMeta('payeeId');
  @override
  late final GeneratedColumn<String> payeeId = GeneratedColumn<String>(
      'payee_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES payees (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, payeeId, name, transactionType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payee_templates';
  @override
  VerificationContext validateIntegrity(Insertable<PayeeTemplateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payee_id')) {
      context.handle(_payeeIdMeta,
          payeeId.isAcceptableOrUnknown(data['payee_id']!, _payeeIdMeta));
    } else if (isInserting) {
      context.missing(_payeeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayeeTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayeeTemplateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      payeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
    );
  }

  @override
  $PayeeTemplatesTable createAlias(String alias) {
    return $PayeeTemplatesTable(attachedDatabase, alias);
  }
}

class PayeeTemplateRow extends DataClass
    implements Insertable<PayeeTemplateRow> {
  final String id;
  final String payeeId;

  /// "default" or a descriptive variation name e.g. "cash back"
  final String name;

  /// TransactionType enum value as string: "expense", "budgetMove", "transfer"
  final String transactionType;
  const PayeeTemplateRow(
      {required this.id,
      required this.payeeId,
      required this.name,
      required this.transactionType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payee_id'] = Variable<String>(payeeId);
    map['name'] = Variable<String>(name);
    map['transaction_type'] = Variable<String>(transactionType);
    return map;
  }

  PayeeTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PayeeTemplatesCompanion(
      id: Value(id),
      payeeId: Value(payeeId),
      name: Value(name),
      transactionType: Value(transactionType),
    );
  }

  factory PayeeTemplateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayeeTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      payeeId: serializer.fromJson<String>(json['payeeId']),
      name: serializer.fromJson<String>(json['name']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payeeId': serializer.toJson<String>(payeeId),
      'name': serializer.toJson<String>(name),
      'transactionType': serializer.toJson<String>(transactionType),
    };
  }

  PayeeTemplateRow copyWith(
          {String? id,
          String? payeeId,
          String? name,
          String? transactionType}) =>
      PayeeTemplateRow(
        id: id ?? this.id,
        payeeId: payeeId ?? this.payeeId,
        name: name ?? this.name,
        transactionType: transactionType ?? this.transactionType,
      );
  PayeeTemplateRow copyWithCompanion(PayeeTemplatesCompanion data) {
    return PayeeTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      payeeId: data.payeeId.present ? data.payeeId.value : this.payeeId,
      name: data.name.present ? data.name.value : this.name,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayeeTemplateRow(')
          ..write('id: $id, ')
          ..write('payeeId: $payeeId, ')
          ..write('name: $name, ')
          ..write('transactionType: $transactionType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payeeId, name, transactionType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayeeTemplateRow &&
          other.id == this.id &&
          other.payeeId == this.payeeId &&
          other.name == this.name &&
          other.transactionType == this.transactionType);
}

class PayeeTemplatesCompanion extends UpdateCompanion<PayeeTemplateRow> {
  final Value<String> id;
  final Value<String> payeeId;
  final Value<String> name;
  final Value<String> transactionType;
  final Value<int> rowid;
  const PayeeTemplatesCompanion({
    this.id = const Value.absent(),
    this.payeeId = const Value.absent(),
    this.name = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayeeTemplatesCompanion.insert({
    required String id,
    required String payeeId,
    required String name,
    required String transactionType,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        payeeId = Value(payeeId),
        name = Value(name),
        transactionType = Value(transactionType);
  static Insertable<PayeeTemplateRow> custom({
    Expression<String>? id,
    Expression<String>? payeeId,
    Expression<String>? name,
    Expression<String>? transactionType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payeeId != null) 'payee_id': payeeId,
      if (name != null) 'name': name,
      if (transactionType != null) 'transaction_type': transactionType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayeeTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? payeeId,
      Value<String>? name,
      Value<String>? transactionType,
      Value<int>? rowid}) {
    return PayeeTemplatesCompanion(
      id: id ?? this.id,
      payeeId: payeeId ?? this.payeeId,
      name: name ?? this.name,
      transactionType: transactionType ?? this.transactionType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payeeId.present) {
      map['payee_id'] = Variable<String>(payeeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayeeTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('payeeId: $payeeId, ')
          ..write('name: $name, ')
          ..write('transactionType: $transactionType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostingTemplatesTable extends PostingTemplates
    with TableInfo<$PostingTemplatesTable, PostingTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostingTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payeeTemplateIdMeta =
      const VerificationMeta('payeeTemplateId');
  @override
  late final GeneratedColumn<String> payeeTemplateId = GeneratedColumn<String>(
      'payee_template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES payee_templates (id)'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _defaultAmountMilliunitsMeta =
      const VerificationMeta('defaultAmountMilliunits');
  @override
  late final GeneratedColumn<int> defaultAmountMilliunits =
      GeneratedColumn<int>('default_amount_milliunits', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBudgetMirrorMeta =
      const VerificationMeta('isBudgetMirror');
  @override
  late final GeneratedColumn<bool> isBudgetMirror = GeneratedColumn<bool>(
      'is_budget_mirror', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_budget_mirror" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _applyDefaultAmountMeta =
      const VerificationMeta('applyDefaultAmount');
  @override
  late final GeneratedColumn<bool> applyDefaultAmount = GeneratedColumn<bool>(
      'apply_default_amount', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("apply_default_amount" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        payeeTemplateId,
        accountId,
        defaultAmountMilliunits,
        memo,
        isBudgetMirror,
        applyDefaultAmount,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posting_templates';
  @override
  VerificationContext validateIntegrity(Insertable<PostingTemplateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payee_template_id')) {
      context.handle(
          _payeeTemplateIdMeta,
          payeeTemplateId.isAcceptableOrUnknown(
              data['payee_template_id']!, _payeeTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_payeeTemplateIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('default_amount_milliunits')) {
      context.handle(
          _defaultAmountMilliunitsMeta,
          defaultAmountMilliunits.isAcceptableOrUnknown(
              data['default_amount_milliunits']!,
              _defaultAmountMilliunitsMeta));
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('is_budget_mirror')) {
      context.handle(
          _isBudgetMirrorMeta,
          isBudgetMirror.isAcceptableOrUnknown(
              data['is_budget_mirror']!, _isBudgetMirrorMeta));
    }
    if (data.containsKey('apply_default_amount')) {
      context.handle(
          _applyDefaultAmountMeta,
          applyDefaultAmount.isAcceptableOrUnknown(
              data['apply_default_amount']!, _applyDefaultAmountMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostingTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostingTemplateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      payeeTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payee_template_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      defaultAmountMilliunits: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}default_amount_milliunits']),
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      isBudgetMirror: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_budget_mirror'])!,
      applyDefaultAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}apply_default_amount'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $PostingTemplatesTable createAlias(String alias) {
    return $PostingTemplatesTable(attachedDatabase, alias);
  }
}

class PostingTemplateRow extends DataClass
    implements Insertable<PostingTemplateRow> {
  final String id;
  final String payeeTemplateId;
  final String accountId;
  final int? defaultAmountMilliunits;
  final String? memo;
  final bool isBudgetMirror;

  /// Whether autofill should pre-fill the amount from
  /// defaultAmountMilliunits. Currently always false — amounts are
  /// remembered but not yet auto-applied; reserved for a future "remember
  /// amount" toggle.
  final bool applyDefaultAmount;

  /// Display order within the template
  final int sortOrder;
  const PostingTemplateRow(
      {required this.id,
      required this.payeeTemplateId,
      required this.accountId,
      this.defaultAmountMilliunits,
      this.memo,
      required this.isBudgetMirror,
      required this.applyDefaultAmount,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payee_template_id'] = Variable<String>(payeeTemplateId);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || defaultAmountMilliunits != null) {
      map['default_amount_milliunits'] = Variable<int>(defaultAmountMilliunits);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['is_budget_mirror'] = Variable<bool>(isBudgetMirror);
    map['apply_default_amount'] = Variable<bool>(applyDefaultAmount);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PostingTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PostingTemplatesCompanion(
      id: Value(id),
      payeeTemplateId: Value(payeeTemplateId),
      accountId: Value(accountId),
      defaultAmountMilliunits: defaultAmountMilliunits == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAmountMilliunits),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      isBudgetMirror: Value(isBudgetMirror),
      applyDefaultAmount: Value(applyDefaultAmount),
      sortOrder: Value(sortOrder),
    );
  }

  factory PostingTemplateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostingTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      payeeTemplateId: serializer.fromJson<String>(json['payeeTemplateId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      defaultAmountMilliunits:
          serializer.fromJson<int?>(json['defaultAmountMilliunits']),
      memo: serializer.fromJson<String?>(json['memo']),
      isBudgetMirror: serializer.fromJson<bool>(json['isBudgetMirror']),
      applyDefaultAmount: serializer.fromJson<bool>(json['applyDefaultAmount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payeeTemplateId': serializer.toJson<String>(payeeTemplateId),
      'accountId': serializer.toJson<String>(accountId),
      'defaultAmountMilliunits':
          serializer.toJson<int?>(defaultAmountMilliunits),
      'memo': serializer.toJson<String?>(memo),
      'isBudgetMirror': serializer.toJson<bool>(isBudgetMirror),
      'applyDefaultAmount': serializer.toJson<bool>(applyDefaultAmount),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PostingTemplateRow copyWith(
          {String? id,
          String? payeeTemplateId,
          String? accountId,
          Value<int?> defaultAmountMilliunits = const Value.absent(),
          Value<String?> memo = const Value.absent(),
          bool? isBudgetMirror,
          bool? applyDefaultAmount,
          int? sortOrder}) =>
      PostingTemplateRow(
        id: id ?? this.id,
        payeeTemplateId: payeeTemplateId ?? this.payeeTemplateId,
        accountId: accountId ?? this.accountId,
        defaultAmountMilliunits: defaultAmountMilliunits.present
            ? defaultAmountMilliunits.value
            : this.defaultAmountMilliunits,
        memo: memo.present ? memo.value : this.memo,
        isBudgetMirror: isBudgetMirror ?? this.isBudgetMirror,
        applyDefaultAmount: applyDefaultAmount ?? this.applyDefaultAmount,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  PostingTemplateRow copyWithCompanion(PostingTemplatesCompanion data) {
    return PostingTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      payeeTemplateId: data.payeeTemplateId.present
          ? data.payeeTemplateId.value
          : this.payeeTemplateId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      defaultAmountMilliunits: data.defaultAmountMilliunits.present
          ? data.defaultAmountMilliunits.value
          : this.defaultAmountMilliunits,
      memo: data.memo.present ? data.memo.value : this.memo,
      isBudgetMirror: data.isBudgetMirror.present
          ? data.isBudgetMirror.value
          : this.isBudgetMirror,
      applyDefaultAmount: data.applyDefaultAmount.present
          ? data.applyDefaultAmount.value
          : this.applyDefaultAmount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostingTemplateRow(')
          ..write('id: $id, ')
          ..write('payeeTemplateId: $payeeTemplateId, ')
          ..write('accountId: $accountId, ')
          ..write('defaultAmountMilliunits: $defaultAmountMilliunits, ')
          ..write('memo: $memo, ')
          ..write('isBudgetMirror: $isBudgetMirror, ')
          ..write('applyDefaultAmount: $applyDefaultAmount, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      payeeTemplateId,
      accountId,
      defaultAmountMilliunits,
      memo,
      isBudgetMirror,
      applyDefaultAmount,
      sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostingTemplateRow &&
          other.id == this.id &&
          other.payeeTemplateId == this.payeeTemplateId &&
          other.accountId == this.accountId &&
          other.defaultAmountMilliunits == this.defaultAmountMilliunits &&
          other.memo == this.memo &&
          other.isBudgetMirror == this.isBudgetMirror &&
          other.applyDefaultAmount == this.applyDefaultAmount &&
          other.sortOrder == this.sortOrder);
}

class PostingTemplatesCompanion extends UpdateCompanion<PostingTemplateRow> {
  final Value<String> id;
  final Value<String> payeeTemplateId;
  final Value<String> accountId;
  final Value<int?> defaultAmountMilliunits;
  final Value<String?> memo;
  final Value<bool> isBudgetMirror;
  final Value<bool> applyDefaultAmount;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PostingTemplatesCompanion({
    this.id = const Value.absent(),
    this.payeeTemplateId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.defaultAmountMilliunits = const Value.absent(),
    this.memo = const Value.absent(),
    this.isBudgetMirror = const Value.absent(),
    this.applyDefaultAmount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostingTemplatesCompanion.insert({
    required String id,
    required String payeeTemplateId,
    required String accountId,
    this.defaultAmountMilliunits = const Value.absent(),
    this.memo = const Value.absent(),
    this.isBudgetMirror = const Value.absent(),
    this.applyDefaultAmount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        payeeTemplateId = Value(payeeTemplateId),
        accountId = Value(accountId);
  static Insertable<PostingTemplateRow> custom({
    Expression<String>? id,
    Expression<String>? payeeTemplateId,
    Expression<String>? accountId,
    Expression<int>? defaultAmountMilliunits,
    Expression<String>? memo,
    Expression<bool>? isBudgetMirror,
    Expression<bool>? applyDefaultAmount,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payeeTemplateId != null) 'payee_template_id': payeeTemplateId,
      if (accountId != null) 'account_id': accountId,
      if (defaultAmountMilliunits != null)
        'default_amount_milliunits': defaultAmountMilliunits,
      if (memo != null) 'memo': memo,
      if (isBudgetMirror != null) 'is_budget_mirror': isBudgetMirror,
      if (applyDefaultAmount != null)
        'apply_default_amount': applyDefaultAmount,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostingTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? payeeTemplateId,
      Value<String>? accountId,
      Value<int?>? defaultAmountMilliunits,
      Value<String?>? memo,
      Value<bool>? isBudgetMirror,
      Value<bool>? applyDefaultAmount,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return PostingTemplatesCompanion(
      id: id ?? this.id,
      payeeTemplateId: payeeTemplateId ?? this.payeeTemplateId,
      accountId: accountId ?? this.accountId,
      defaultAmountMilliunits:
          defaultAmountMilliunits ?? this.defaultAmountMilliunits,
      memo: memo ?? this.memo,
      isBudgetMirror: isBudgetMirror ?? this.isBudgetMirror,
      applyDefaultAmount: applyDefaultAmount ?? this.applyDefaultAmount,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payeeTemplateId.present) {
      map['payee_template_id'] = Variable<String>(payeeTemplateId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (defaultAmountMilliunits.present) {
      map['default_amount_milliunits'] =
          Variable<int>(defaultAmountMilliunits.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (isBudgetMirror.present) {
      map['is_budget_mirror'] = Variable<bool>(isBudgetMirror.value);
    }
    if (applyDefaultAmount.present) {
      map['apply_default_amount'] = Variable<bool>(applyDefaultAmount.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostingTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('payeeTemplateId: $payeeTemplateId, ')
          ..write('accountId: $accountId, ')
          ..write('defaultAmountMilliunits: $defaultAmountMilliunits, ')
          ..write('memo: $memo, ')
          ..write('isBudgetMirror: $isBudgetMirror, ')
          ..write('applyDefaultAmount: $applyDefaultAmount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _payeeIdMeta =
      const VerificationMeta('payeeId');
  @override
  late final GeneratedColumn<String> payeeId = GeneratedColumn<String>(
      'payee_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES payees (id)'));
  static const VerificationMeta _payeeNameMeta =
      const VerificationMeta('payeeName');
  @override
  late final GeneratedColumn<String> payeeName = GeneratedColumn<String>(
      'payee_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _budgetMonthMeta =
      const VerificationMeta('budgetMonth');
  @override
  late final GeneratedColumn<DateTime> budgetMonth = GeneratedColumn<DateTime>(
      'budget_month', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _ynabSyncStatusMeta =
      const VerificationMeta('ynabSyncStatus');
  @override
  late final GeneratedColumn<String> ynabSyncStatus = GeneratedColumn<String>(
      'ynab_sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _ledgerSyncStatusMeta =
      const VerificationMeta('ledgerSyncStatus');
  @override
  late final GeneratedColumn<String> ledgerSyncStatus = GeneratedColumn<String>(
      'ledger_sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _ynabTransactionIdMeta =
      const VerificationMeta('ynabTransactionId');
  @override
  late final GeneratedColumn<String> ynabTransactionId =
      GeneratedColumn<String>('ynab_transaction_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        date,
        payeeId,
        payeeName,
        note,
        time,
        budgetMonth,
        ynabSyncStatus,
        ledgerSyncStatus,
        ynabTransactionId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payee_id')) {
      context.handle(_payeeIdMeta,
          payeeId.isAcceptableOrUnknown(data['payee_id']!, _payeeIdMeta));
    }
    if (data.containsKey('payee_name')) {
      context.handle(_payeeNameMeta,
          payeeName.isAcceptableOrUnknown(data['payee_name']!, _payeeNameMeta));
    } else if (isInserting) {
      context.missing(_payeeNameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('budget_month')) {
      context.handle(
          _budgetMonthMeta,
          budgetMonth.isAcceptableOrUnknown(
              data['budget_month']!, _budgetMonthMeta));
    }
    if (data.containsKey('ynab_sync_status')) {
      context.handle(
          _ynabSyncStatusMeta,
          ynabSyncStatus.isAcceptableOrUnknown(
              data['ynab_sync_status']!, _ynabSyncStatusMeta));
    }
    if (data.containsKey('ledger_sync_status')) {
      context.handle(
          _ledgerSyncStatusMeta,
          ledgerSyncStatus.isAcceptableOrUnknown(
              data['ledger_sync_status']!, _ledgerSyncStatusMeta));
    }
    if (data.containsKey('ynab_transaction_id')) {
      context.handle(
          _ynabTransactionIdMeta,
          ynabTransactionId.isAcceptableOrUnknown(
              data['ynab_transaction_id']!, _ynabTransactionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      payeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee_id']),
      payeeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee_name'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      budgetMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}budget_month']),
      ynabSyncStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ynab_sync_status'])!,
      ledgerSyncStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ledger_sync_status'])!,
      ynabTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ynab_transaction_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;

  /// "expense", "budgetMove", "transfer"
  final String type;
  final DateTime date;
  final String? payeeId;

  /// Raw payee name, kept separately in case payee record is later deleted
  final String payeeName;
  final String? note;

  /// Time of the transaction, stored separately from date.
  /// Output as a Ledger tag; not sent to YNAB.
  final DateTime time;

  /// For budgetMove transactions only: the YNAB month this move applies to
  /// (always normalized to the 1st of that month). Null means "same month
  /// as date" — i.e. no override, no Ledger effective-date tag needed.
  final DateTime? budgetMonth;

  /// "pending", "synced", "failed"
  final String ynabSyncStatus;
  final String ledgerSyncStatus;
  final String? ynabTransactionId;
  final DateTime createdAt;
  const TransactionRow(
      {required this.id,
      required this.type,
      required this.date,
      this.payeeId,
      required this.payeeName,
      this.note,
      required this.time,
      this.budgetMonth,
      required this.ynabSyncStatus,
      required this.ledgerSyncStatus,
      this.ynabTransactionId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || payeeId != null) {
      map['payee_id'] = Variable<String>(payeeId);
    }
    map['payee_name'] = Variable<String>(payeeName);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['time'] = Variable<DateTime>(time);
    if (!nullToAbsent || budgetMonth != null) {
      map['budget_month'] = Variable<DateTime>(budgetMonth);
    }
    map['ynab_sync_status'] = Variable<String>(ynabSyncStatus);
    map['ledger_sync_status'] = Variable<String>(ledgerSyncStatus);
    if (!nullToAbsent || ynabTransactionId != null) {
      map['ynab_transaction_id'] = Variable<String>(ynabTransactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      date: Value(date),
      payeeId: payeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(payeeId),
      payeeName: Value(payeeName),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      time: Value(time),
      budgetMonth: budgetMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetMonth),
      ynabSyncStatus: Value(ynabSyncStatus),
      ledgerSyncStatus: Value(ledgerSyncStatus),
      ynabTransactionId: ynabTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(ynabTransactionId),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      date: serializer.fromJson<DateTime>(json['date']),
      payeeId: serializer.fromJson<String?>(json['payeeId']),
      payeeName: serializer.fromJson<String>(json['payeeName']),
      note: serializer.fromJson<String?>(json['note']),
      time: serializer.fromJson<DateTime>(json['time']),
      budgetMonth: serializer.fromJson<DateTime?>(json['budgetMonth']),
      ynabSyncStatus: serializer.fromJson<String>(json['ynabSyncStatus']),
      ledgerSyncStatus: serializer.fromJson<String>(json['ledgerSyncStatus']),
      ynabTransactionId:
          serializer.fromJson<String?>(json['ynabTransactionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'date': serializer.toJson<DateTime>(date),
      'payeeId': serializer.toJson<String?>(payeeId),
      'payeeName': serializer.toJson<String>(payeeName),
      'note': serializer.toJson<String?>(note),
      'time': serializer.toJson<DateTime>(time),
      'budgetMonth': serializer.toJson<DateTime?>(budgetMonth),
      'ynabSyncStatus': serializer.toJson<String>(ynabSyncStatus),
      'ledgerSyncStatus': serializer.toJson<String>(ledgerSyncStatus),
      'ynabTransactionId': serializer.toJson<String?>(ynabTransactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionRow copyWith(
          {String? id,
          String? type,
          DateTime? date,
          Value<String?> payeeId = const Value.absent(),
          String? payeeName,
          Value<String?> note = const Value.absent(),
          DateTime? time,
          Value<DateTime?> budgetMonth = const Value.absent(),
          String? ynabSyncStatus,
          String? ledgerSyncStatus,
          Value<String?> ynabTransactionId = const Value.absent(),
          DateTime? createdAt}) =>
      TransactionRow(
        id: id ?? this.id,
        type: type ?? this.type,
        date: date ?? this.date,
        payeeId: payeeId.present ? payeeId.value : this.payeeId,
        payeeName: payeeName ?? this.payeeName,
        note: note.present ? note.value : this.note,
        time: time ?? this.time,
        budgetMonth: budgetMonth.present ? budgetMonth.value : this.budgetMonth,
        ynabSyncStatus: ynabSyncStatus ?? this.ynabSyncStatus,
        ledgerSyncStatus: ledgerSyncStatus ?? this.ledgerSyncStatus,
        ynabTransactionId: ynabTransactionId.present
            ? ynabTransactionId.value
            : this.ynabTransactionId,
        createdAt: createdAt ?? this.createdAt,
      );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      payeeId: data.payeeId.present ? data.payeeId.value : this.payeeId,
      payeeName: data.payeeName.present ? data.payeeName.value : this.payeeName,
      note: data.note.present ? data.note.value : this.note,
      time: data.time.present ? data.time.value : this.time,
      budgetMonth:
          data.budgetMonth.present ? data.budgetMonth.value : this.budgetMonth,
      ynabSyncStatus: data.ynabSyncStatus.present
          ? data.ynabSyncStatus.value
          : this.ynabSyncStatus,
      ledgerSyncStatus: data.ledgerSyncStatus.present
          ? data.ledgerSyncStatus.value
          : this.ledgerSyncStatus,
      ynabTransactionId: data.ynabTransactionId.present
          ? data.ynabTransactionId.value
          : this.ynabTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('payeeId: $payeeId, ')
          ..write('payeeName: $payeeName, ')
          ..write('note: $note, ')
          ..write('time: $time, ')
          ..write('budgetMonth: $budgetMonth, ')
          ..write('ynabSyncStatus: $ynabSyncStatus, ')
          ..write('ledgerSyncStatus: $ledgerSyncStatus, ')
          ..write('ynabTransactionId: $ynabTransactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      date,
      payeeId,
      payeeName,
      note,
      time,
      budgetMonth,
      ynabSyncStatus,
      ledgerSyncStatus,
      ynabTransactionId,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.date == this.date &&
          other.payeeId == this.payeeId &&
          other.payeeName == this.payeeName &&
          other.note == this.note &&
          other.time == this.time &&
          other.budgetMonth == this.budgetMonth &&
          other.ynabSyncStatus == this.ynabSyncStatus &&
          other.ledgerSyncStatus == this.ledgerSyncStatus &&
          other.ynabTransactionId == this.ynabTransactionId &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> date;
  final Value<String?> payeeId;
  final Value<String> payeeName;
  final Value<String?> note;
  final Value<DateTime> time;
  final Value<DateTime?> budgetMonth;
  final Value<String> ynabSyncStatus;
  final Value<String> ledgerSyncStatus;
  final Value<String?> ynabTransactionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.payeeId = const Value.absent(),
    this.payeeName = const Value.absent(),
    this.note = const Value.absent(),
    this.time = const Value.absent(),
    this.budgetMonth = const Value.absent(),
    this.ynabSyncStatus = const Value.absent(),
    this.ledgerSyncStatus = const Value.absent(),
    this.ynabTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String type,
    required DateTime date,
    this.payeeId = const Value.absent(),
    required String payeeName,
    this.note = const Value.absent(),
    required DateTime time,
    this.budgetMonth = const Value.absent(),
    this.ynabSyncStatus = const Value.absent(),
    this.ledgerSyncStatus = const Value.absent(),
    this.ynabTransactionId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        date = Value(date),
        payeeName = Value(payeeName),
        time = Value(time),
        createdAt = Value(createdAt);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? date,
    Expression<String>? payeeId,
    Expression<String>? payeeName,
    Expression<String>? note,
    Expression<DateTime>? time,
    Expression<DateTime>? budgetMonth,
    Expression<String>? ynabSyncStatus,
    Expression<String>? ledgerSyncStatus,
    Expression<String>? ynabTransactionId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (payeeId != null) 'payee_id': payeeId,
      if (payeeName != null) 'payee_name': payeeName,
      if (note != null) 'note': note,
      if (time != null) 'time': time,
      if (budgetMonth != null) 'budget_month': budgetMonth,
      if (ynabSyncStatus != null) 'ynab_sync_status': ynabSyncStatus,
      if (ledgerSyncStatus != null) 'ledger_sync_status': ledgerSyncStatus,
      if (ynabTransactionId != null) 'ynab_transaction_id': ynabTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<DateTime>? date,
      Value<String?>? payeeId,
      Value<String>? payeeName,
      Value<String?>? note,
      Value<DateTime>? time,
      Value<DateTime?>? budgetMonth,
      Value<String>? ynabSyncStatus,
      Value<String>? ledgerSyncStatus,
      Value<String?>? ynabTransactionId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      payeeId: payeeId ?? this.payeeId,
      payeeName: payeeName ?? this.payeeName,
      note: note ?? this.note,
      time: time ?? this.time,
      budgetMonth: budgetMonth ?? this.budgetMonth,
      ynabSyncStatus: ynabSyncStatus ?? this.ynabSyncStatus,
      ledgerSyncStatus: ledgerSyncStatus ?? this.ledgerSyncStatus,
      ynabTransactionId: ynabTransactionId ?? this.ynabTransactionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (payeeId.present) {
      map['payee_id'] = Variable<String>(payeeId.value);
    }
    if (payeeName.present) {
      map['payee_name'] = Variable<String>(payeeName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (budgetMonth.present) {
      map['budget_month'] = Variable<DateTime>(budgetMonth.value);
    }
    if (ynabSyncStatus.present) {
      map['ynab_sync_status'] = Variable<String>(ynabSyncStatus.value);
    }
    if (ledgerSyncStatus.present) {
      map['ledger_sync_status'] = Variable<String>(ledgerSyncStatus.value);
    }
    if (ynabTransactionId.present) {
      map['ynab_transaction_id'] = Variable<String>(ynabTransactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('payeeId: $payeeId, ')
          ..write('payeeName: $payeeName, ')
          ..write('note: $note, ')
          ..write('time: $time, ')
          ..write('budgetMonth: $budgetMonth, ')
          ..write('ynabSyncStatus: $ynabSyncStatus, ')
          ..write('ledgerSyncStatus: $ledgerSyncStatus, ')
          ..write('ynabTransactionId: $ynabTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostingsTable extends Postings
    with TableInfo<$PostingsTable, PostingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _amountMilliunitsMeta =
      const VerificationMeta('amountMilliunits');
  @override
  late final GeneratedColumn<int> amountMilliunits = GeneratedColumn<int>(
      'amount_milliunits', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBudgetMirrorMeta =
      const VerificationMeta('isBudgetMirror');
  @override
  late final GeneratedColumn<bool> isBudgetMirror = GeneratedColumn<bool>(
      'is_budget_mirror', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_budget_mirror" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSourceMeta =
      const VerificationMeta('isSource');
  @override
  late final GeneratedColumn<bool> isSource = GeneratedColumn<bool>(
      'is_source', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_source" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        accountId,
        amountMilliunits,
        memo,
        isBudgetMirror,
        isSource,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'postings';
  @override
  VerificationContext validateIntegrity(Insertable<PostingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount_milliunits')) {
      context.handle(
          _amountMilliunitsMeta,
          amountMilliunits.isAcceptableOrUnknown(
              data['amount_milliunits']!, _amountMilliunitsMeta));
    } else if (isInserting) {
      context.missing(_amountMilliunitsMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('is_budget_mirror')) {
      context.handle(
          _isBudgetMirrorMeta,
          isBudgetMirror.isAcceptableOrUnknown(
              data['is_budget_mirror']!, _isBudgetMirrorMeta));
    }
    if (data.containsKey('is_source')) {
      context.handle(_isSourceMeta,
          isSource.isAcceptableOrUnknown(data['is_source']!, _isSourceMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostingRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      amountMilliunits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_milliunits'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      isBudgetMirror: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_budget_mirror'])!,
      isSource: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_source'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $PostingsTable createAlias(String alias) {
    return $PostingsTable(attachedDatabase, alias);
  }
}

class PostingRow extends DataClass implements Insertable<PostingRow> {
  final String id;
  final String transactionId;
  final String accountId;
  final int amountMilliunits;
  final String? memo;
  final bool isBudgetMirror;

  /// Whether this is the primary source account for YNAB sync.
  /// Exactly one non-mirror posting per transaction should have this set.
  final bool isSource;

  /// Display order within the transaction
  final int sortOrder;
  const PostingRow(
      {required this.id,
      required this.transactionId,
      required this.accountId,
      required this.amountMilliunits,
      this.memo,
      required this.isBudgetMirror,
      required this.isSource,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['account_id'] = Variable<String>(accountId);
    map['amount_milliunits'] = Variable<int>(amountMilliunits);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['is_budget_mirror'] = Variable<bool>(isBudgetMirror);
    map['is_source'] = Variable<bool>(isSource);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PostingsCompanion toCompanion(bool nullToAbsent) {
    return PostingsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      accountId: Value(accountId),
      amountMilliunits: Value(amountMilliunits),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      isBudgetMirror: Value(isBudgetMirror),
      isSource: Value(isSource),
      sortOrder: Value(sortOrder),
    );
  }

  factory PostingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostingRow(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amountMilliunits: serializer.fromJson<int>(json['amountMilliunits']),
      memo: serializer.fromJson<String?>(json['memo']),
      isBudgetMirror: serializer.fromJson<bool>(json['isBudgetMirror']),
      isSource: serializer.fromJson<bool>(json['isSource']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'accountId': serializer.toJson<String>(accountId),
      'amountMilliunits': serializer.toJson<int>(amountMilliunits),
      'memo': serializer.toJson<String?>(memo),
      'isBudgetMirror': serializer.toJson<bool>(isBudgetMirror),
      'isSource': serializer.toJson<bool>(isSource),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PostingRow copyWith(
          {String? id,
          String? transactionId,
          String? accountId,
          int? amountMilliunits,
          Value<String?> memo = const Value.absent(),
          bool? isBudgetMirror,
          bool? isSource,
          int? sortOrder}) =>
      PostingRow(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        accountId: accountId ?? this.accountId,
        amountMilliunits: amountMilliunits ?? this.amountMilliunits,
        memo: memo.present ? memo.value : this.memo,
        isBudgetMirror: isBudgetMirror ?? this.isBudgetMirror,
        isSource: isSource ?? this.isSource,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  PostingRow copyWithCompanion(PostingsCompanion data) {
    return PostingRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountMilliunits: data.amountMilliunits.present
          ? data.amountMilliunits.value
          : this.amountMilliunits,
      memo: data.memo.present ? data.memo.value : this.memo,
      isBudgetMirror: data.isBudgetMirror.present
          ? data.isBudgetMirror.value
          : this.isBudgetMirror,
      isSource: data.isSource.present ? data.isSource.value : this.isSource,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostingRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('amountMilliunits: $amountMilliunits, ')
          ..write('memo: $memo, ')
          ..write('isBudgetMirror: $isBudgetMirror, ')
          ..write('isSource: $isSource, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, accountId,
      amountMilliunits, memo, isBudgetMirror, isSource, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostingRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.accountId == this.accountId &&
          other.amountMilliunits == this.amountMilliunits &&
          other.memo == this.memo &&
          other.isBudgetMirror == this.isBudgetMirror &&
          other.isSource == this.isSource &&
          other.sortOrder == this.sortOrder);
}

class PostingsCompanion extends UpdateCompanion<PostingRow> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> accountId;
  final Value<int> amountMilliunits;
  final Value<String?> memo;
  final Value<bool> isBudgetMirror;
  final Value<bool> isSource;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PostingsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountMilliunits = const Value.absent(),
    this.memo = const Value.absent(),
    this.isBudgetMirror = const Value.absent(),
    this.isSource = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostingsCompanion.insert({
    required String id,
    required String transactionId,
    required String accountId,
    required int amountMilliunits,
    this.memo = const Value.absent(),
    this.isBudgetMirror = const Value.absent(),
    this.isSource = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transactionId = Value(transactionId),
        accountId = Value(accountId),
        amountMilliunits = Value(amountMilliunits);
  static Insertable<PostingRow> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? accountId,
    Expression<int>? amountMilliunits,
    Expression<String>? memo,
    Expression<bool>? isBudgetMirror,
    Expression<bool>? isSource,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (accountId != null) 'account_id': accountId,
      if (amountMilliunits != null) 'amount_milliunits': amountMilliunits,
      if (memo != null) 'memo': memo,
      if (isBudgetMirror != null) 'is_budget_mirror': isBudgetMirror,
      if (isSource != null) 'is_source': isSource,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionId,
      Value<String>? accountId,
      Value<int>? amountMilliunits,
      Value<String?>? memo,
      Value<bool>? isBudgetMirror,
      Value<bool>? isSource,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return PostingsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      amountMilliunits: amountMilliunits ?? this.amountMilliunits,
      memo: memo ?? this.memo,
      isBudgetMirror: isBudgetMirror ?? this.isBudgetMirror,
      isSource: isSource ?? this.isSource,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amountMilliunits.present) {
      map['amount_milliunits'] = Variable<int>(amountMilliunits.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (isBudgetMirror.present) {
      map['is_budget_mirror'] = Variable<bool>(isBudgetMirror.value);
    }
    if (isSource.present) {
      map['is_source'] = Variable<bool>(isSource.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostingsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('amountMilliunits: $amountMilliunits, ')
          ..write('memo: $memo, ')
          ..write('isBudgetMirror: $isBudgetMirror, ')
          ..write('isSource: $isSource, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $PayeesTable payees = $PayeesTable(this);
  late final $PayeeTemplatesTable payeeTemplates = $PayeeTemplatesTable(this);
  late final $PostingTemplatesTable postingTemplates =
      $PostingTemplatesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $PostingsTable postings = $PostingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        payees,
        payeeTemplates,
        postingTemplates,
        transactions,
        postings
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String ledgerName,
  Value<String?> ynabId,
  Value<String?> ynabName,
  Value<String?> ynabTransferPayeeId,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> ledgerName,
  Value<String?> ynabId,
  Value<String?> ynabName,
  Value<String?> ynabTransferPayeeId,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PostingTemplatesTable, List<PostingTemplateRow>>
      _postingTemplatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.postingTemplates,
              aliasName: $_aliasNameGenerator(
                  db.accounts.id, db.postingTemplates.accountId));

  $$PostingTemplatesTableProcessedTableManager get postingTemplatesRefs {
    final manager = $$PostingTemplatesTableTableManager(
            $_db, $_db.postingTemplates)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_postingTemplatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PostingsTable, List<PostingRow>>
      _postingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.postings,
              aliasName:
                  $_aliasNameGenerator(db.accounts.id, db.postings.accountId));

  $$PostingsTableProcessedTableManager get postingsRefs {
    final manager = $$PostingsTableTableManager($_db, $_db.postings)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ledgerName => $composableBuilder(
      column: $table.ledgerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ynabId => $composableBuilder(
      column: $table.ynabId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ynabName => $composableBuilder(
      column: $table.ynabName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ynabTransferPayeeId => $composableBuilder(
      column: $table.ynabTransferPayeeId,
      builder: (column) => ColumnFilters(column));

  Expression<bool> postingTemplatesRefs(
      Expression<bool> Function($$PostingTemplatesTableFilterComposer f) f) {
    final $$PostingTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postingTemplates,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.postingTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> postingsRefs(
      Expression<bool> Function($$PostingsTableFilterComposer f) f) {
    final $$PostingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableFilterComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ledgerName => $composableBuilder(
      column: $table.ledgerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ynabId => $composableBuilder(
      column: $table.ynabId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ynabName => $composableBuilder(
      column: $table.ynabName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ynabTransferPayeeId => $composableBuilder(
      column: $table.ynabTransferPayeeId,
      builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ledgerName => $composableBuilder(
      column: $table.ledgerName, builder: (column) => column);

  GeneratedColumn<String> get ynabId =>
      $composableBuilder(column: $table.ynabId, builder: (column) => column);

  GeneratedColumn<String> get ynabName =>
      $composableBuilder(column: $table.ynabName, builder: (column) => column);

  GeneratedColumn<String> get ynabTransferPayeeId => $composableBuilder(
      column: $table.ynabTransferPayeeId, builder: (column) => column);

  Expression<T> postingTemplatesRefs<T extends Object>(
      Expression<T> Function($$PostingTemplatesTableAnnotationComposer a) f) {
    final $$PostingTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postingTemplates,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.postingTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> postingsRefs<T extends Object>(
      Expression<T> Function($$PostingsTableAnnotationComposer a) f) {
    final $$PostingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableAnnotationComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    AccountRow,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (AccountRow, $$AccountsTableReferences),
    AccountRow,
    PrefetchHooks Function({bool postingTemplatesRefs, bool postingsRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ledgerName = const Value.absent(),
            Value<String?> ynabId = const Value.absent(),
            Value<String?> ynabName = const Value.absent(),
            Value<String?> ynabTransferPayeeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            ledgerName: ledgerName,
            ynabId: ynabId,
            ynabName: ynabName,
            ynabTransferPayeeId: ynabTransferPayeeId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ledgerName,
            Value<String?> ynabId = const Value.absent(),
            Value<String?> ynabName = const Value.absent(),
            Value<String?> ynabTransferPayeeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            ledgerName: ledgerName,
            ynabId: ynabId,
            ynabName: ynabName,
            ynabTransferPayeeId: ynabTransferPayeeId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {postingTemplatesRefs = false, postingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (postingTemplatesRefs) db.postingTemplates,
                if (postingsRefs) db.postings
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postingTemplatesRefs)
                    await $_getPrefetchedData<AccountRow, $AccountsTable,
                            PostingTemplateRow>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._postingTemplatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .postingTemplatesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items),
                  if (postingsRefs)
                    await $_getPrefetchedData<AccountRow, $AccountsTable,
                            PostingRow>(
                        currentTable: table,
                        referencedTable:
                            $$AccountsTableReferences._postingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .postingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    AccountRow,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (AccountRow, $$AccountsTableReferences),
    AccountRow,
    PrefetchHooks Function({bool postingTemplatesRefs, bool postingsRefs})>;
typedef $$PayeesTableCreateCompanionBuilder = PayeesCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$PayeesTableUpdateCompanionBuilder = PayeesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

final class $$PayeesTableReferences
    extends BaseReferences<_$AppDatabase, $PayeesTable, PayeeRow> {
  $$PayeesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PayeeTemplatesTable, List<PayeeTemplateRow>>
      _payeeTemplatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.payeeTemplates,
              aliasName: $_aliasNameGenerator(
                  db.payees.id, db.payeeTemplates.payeeId));

  $$PayeeTemplatesTableProcessedTableManager get payeeTemplatesRefs {
    final manager = $$PayeeTemplatesTableTableManager($_db, $_db.payeeTemplates)
        .filter((f) => f.payeeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_payeeTemplatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName:
                  $_aliasNameGenerator(db.payees.id, db.transactions.payeeId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.payeeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PayeesTableFilterComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> payeeTemplatesRefs(
      Expression<bool> Function($$PayeeTemplatesTableFilterComposer f) f) {
    final $$PayeeTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payeeTemplates,
        getReferencedColumn: (t) => t.payeeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeeTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.payeeTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.payeeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PayeesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$PayeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> payeeTemplatesRefs<T extends Object>(
      Expression<T> Function($$PayeeTemplatesTableAnnotationComposer a) f) {
    final $$PayeeTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payeeTemplates,
        getReferencedColumn: (t) => t.payeeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeeTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.payeeTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.payeeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PayeesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PayeesTable,
    PayeeRow,
    $$PayeesTableFilterComposer,
    $$PayeesTableOrderingComposer,
    $$PayeesTableAnnotationComposer,
    $$PayeesTableCreateCompanionBuilder,
    $$PayeesTableUpdateCompanionBuilder,
    (PayeeRow, $$PayeesTableReferences),
    PayeeRow,
    PrefetchHooks Function({bool payeeTemplatesRefs, bool transactionsRefs})> {
  $$PayeesTableTableManager(_$AppDatabase db, $PayeesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeesCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeesCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PayeesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {payeeTemplatesRefs = false, transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (payeeTemplatesRefs) db.payeeTemplates,
                if (transactionsRefs) db.transactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (payeeTemplatesRefs)
                    await $_getPrefetchedData<PayeeRow, $PayeesTable,
                            PayeeTemplateRow>(
                        currentTable: table,
                        referencedTable: $$PayeesTableReferences
                            ._payeeTemplatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PayeesTableReferences(db, table, p0)
                                .payeeTemplatesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.payeeId == item.id),
                        typedResults: items),
                  if (transactionsRefs)
                    await $_getPrefetchedData<PayeeRow, $PayeesTable,
                            TransactionRow>(
                        currentTable: table,
                        referencedTable:
                            $$PayeesTableReferences._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PayeesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.payeeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PayeesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PayeesTable,
    PayeeRow,
    $$PayeesTableFilterComposer,
    $$PayeesTableOrderingComposer,
    $$PayeesTableAnnotationComposer,
    $$PayeesTableCreateCompanionBuilder,
    $$PayeesTableUpdateCompanionBuilder,
    (PayeeRow, $$PayeesTableReferences),
    PayeeRow,
    PrefetchHooks Function({bool payeeTemplatesRefs, bool transactionsRefs})>;
typedef $$PayeeTemplatesTableCreateCompanionBuilder = PayeeTemplatesCompanion
    Function({
  required String id,
  required String payeeId,
  required String name,
  required String transactionType,
  Value<int> rowid,
});
typedef $$PayeeTemplatesTableUpdateCompanionBuilder = PayeeTemplatesCompanion
    Function({
  Value<String> id,
  Value<String> payeeId,
  Value<String> name,
  Value<String> transactionType,
  Value<int> rowid,
});

final class $$PayeeTemplatesTableReferences extends BaseReferences<
    _$AppDatabase, $PayeeTemplatesTable, PayeeTemplateRow> {
  $$PayeeTemplatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PayeesTable _payeeIdTable(_$AppDatabase db) => db.payees.createAlias(
      $_aliasNameGenerator(db.payeeTemplates.payeeId, db.payees.id));

  $$PayeesTableProcessedTableManager get payeeId {
    final $_column = $_itemColumn<String>('payee_id')!;

    final manager = $$PayeesTableTableManager($_db, $_db.payees)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PostingTemplatesTable, List<PostingTemplateRow>>
      _postingTemplatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.postingTemplates,
              aliasName: $_aliasNameGenerator(
                  db.payeeTemplates.id, db.postingTemplates.payeeTemplateId));

  $$PostingTemplatesTableProcessedTableManager get postingTemplatesRefs {
    final manager =
        $$PostingTemplatesTableTableManager($_db, $_db.postingTemplates).filter(
            (f) => f.payeeTemplateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_postingTemplatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PayeeTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PayeeTemplatesTable> {
  $$PayeeTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  $$PayeesTableFilterComposer get payeeId {
    final $$PayeesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableFilterComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> postingTemplatesRefs(
      Expression<bool> Function($$PostingTemplatesTableFilterComposer f) f) {
    final $$PostingTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postingTemplates,
        getReferencedColumn: (t) => t.payeeTemplateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.postingTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PayeeTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayeeTemplatesTable> {
  $$PayeeTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  $$PayeesTableOrderingComposer get payeeId {
    final $$PayeesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableOrderingComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PayeeTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayeeTemplatesTable> {
  $$PayeeTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  $$PayeesTableAnnotationComposer get payeeId {
    final $$PayeesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableAnnotationComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> postingTemplatesRefs<T extends Object>(
      Expression<T> Function($$PostingTemplatesTableAnnotationComposer a) f) {
    final $$PostingTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postingTemplates,
        getReferencedColumn: (t) => t.payeeTemplateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.postingTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PayeeTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PayeeTemplatesTable,
    PayeeTemplateRow,
    $$PayeeTemplatesTableFilterComposer,
    $$PayeeTemplatesTableOrderingComposer,
    $$PayeeTemplatesTableAnnotationComposer,
    $$PayeeTemplatesTableCreateCompanionBuilder,
    $$PayeeTemplatesTableUpdateCompanionBuilder,
    (PayeeTemplateRow, $$PayeeTemplatesTableReferences),
    PayeeTemplateRow,
    PrefetchHooks Function({bool payeeId, bool postingTemplatesRefs})> {
  $$PayeeTemplatesTableTableManager(
      _$AppDatabase db, $PayeeTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayeeTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayeeTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayeeTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> payeeId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeeTemplatesCompanion(
            id: id,
            payeeId: payeeId,
            name: name,
            transactionType: transactionType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String payeeId,
            required String name,
            required String transactionType,
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeeTemplatesCompanion.insert(
            id: id,
            payeeId: payeeId,
            name: name,
            transactionType: transactionType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PayeeTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {payeeId = false, postingTemplatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (postingTemplatesRefs) db.postingTemplates
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (payeeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.payeeId,
                    referencedTable:
                        $$PayeeTemplatesTableReferences._payeeIdTable(db),
                    referencedColumn:
                        $$PayeeTemplatesTableReferences._payeeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postingTemplatesRefs)
                    await $_getPrefetchedData<PayeeTemplateRow,
                            $PayeeTemplatesTable, PostingTemplateRow>(
                        currentTable: table,
                        referencedTable: $$PayeeTemplatesTableReferences
                            ._postingTemplatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PayeeTemplatesTableReferences(db, table, p0)
                                .postingTemplatesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.payeeTemplateId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PayeeTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PayeeTemplatesTable,
    PayeeTemplateRow,
    $$PayeeTemplatesTableFilterComposer,
    $$PayeeTemplatesTableOrderingComposer,
    $$PayeeTemplatesTableAnnotationComposer,
    $$PayeeTemplatesTableCreateCompanionBuilder,
    $$PayeeTemplatesTableUpdateCompanionBuilder,
    (PayeeTemplateRow, $$PayeeTemplatesTableReferences),
    PayeeTemplateRow,
    PrefetchHooks Function({bool payeeId, bool postingTemplatesRefs})>;
typedef $$PostingTemplatesTableCreateCompanionBuilder
    = PostingTemplatesCompanion Function({
  required String id,
  required String payeeTemplateId,
  required String accountId,
  Value<int?> defaultAmountMilliunits,
  Value<String?> memo,
  Value<bool> isBudgetMirror,
  Value<bool> applyDefaultAmount,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$PostingTemplatesTableUpdateCompanionBuilder
    = PostingTemplatesCompanion Function({
  Value<String> id,
  Value<String> payeeTemplateId,
  Value<String> accountId,
  Value<int?> defaultAmountMilliunits,
  Value<String?> memo,
  Value<bool> isBudgetMirror,
  Value<bool> applyDefaultAmount,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$PostingTemplatesTableReferences extends BaseReferences<
    _$AppDatabase, $PostingTemplatesTable, PostingTemplateRow> {
  $$PostingTemplatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PayeeTemplatesTable _payeeTemplateIdTable(_$AppDatabase db) =>
      db.payeeTemplates.createAlias($_aliasNameGenerator(
          db.postingTemplates.payeeTemplateId, db.payeeTemplates.id));

  $$PayeeTemplatesTableProcessedTableManager get payeeTemplateId {
    final $_column = $_itemColumn<String>('payee_template_id')!;

    final manager = $$PayeeTemplatesTableTableManager($_db, $_db.payeeTemplates)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payeeTemplateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.postingTemplates.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PostingTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PostingTemplatesTable> {
  $$PostingTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultAmountMilliunits => $composableBuilder(
      column: $table.defaultAmountMilliunits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBudgetMirror => $composableBuilder(
      column: $table.isBudgetMirror,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get applyDefaultAmount => $composableBuilder(
      column: $table.applyDefaultAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$PayeeTemplatesTableFilterComposer get payeeTemplateId {
    final $$PayeeTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeTemplateId,
        referencedTable: $db.payeeTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeeTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.payeeTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PostingTemplatesTable> {
  $$PostingTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultAmountMilliunits => $composableBuilder(
      column: $table.defaultAmountMilliunits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBudgetMirror => $composableBuilder(
      column: $table.isBudgetMirror,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get applyDefaultAmount => $composableBuilder(
      column: $table.applyDefaultAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$PayeeTemplatesTableOrderingComposer get payeeTemplateId {
    final $$PayeeTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeTemplateId,
        referencedTable: $db.payeeTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeeTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.payeeTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostingTemplatesTable> {
  $$PostingTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get defaultAmountMilliunits => $composableBuilder(
      column: $table.defaultAmountMilliunits, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<bool> get isBudgetMirror => $composableBuilder(
      column: $table.isBudgetMirror, builder: (column) => column);

  GeneratedColumn<bool> get applyDefaultAmount => $composableBuilder(
      column: $table.applyDefaultAmount, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PayeeTemplatesTableAnnotationComposer get payeeTemplateId {
    final $$PayeeTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeTemplateId,
        referencedTable: $db.payeeTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeeTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.payeeTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PostingTemplatesTable,
    PostingTemplateRow,
    $$PostingTemplatesTableFilterComposer,
    $$PostingTemplatesTableOrderingComposer,
    $$PostingTemplatesTableAnnotationComposer,
    $$PostingTemplatesTableCreateCompanionBuilder,
    $$PostingTemplatesTableUpdateCompanionBuilder,
    (PostingTemplateRow, $$PostingTemplatesTableReferences),
    PostingTemplateRow,
    PrefetchHooks Function({bool payeeTemplateId, bool accountId})> {
  $$PostingTemplatesTableTableManager(
      _$AppDatabase db, $PostingTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostingTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostingTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostingTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> payeeTemplateId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<int?> defaultAmountMilliunits = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<bool> isBudgetMirror = const Value.absent(),
            Value<bool> applyDefaultAmount = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingTemplatesCompanion(
            id: id,
            payeeTemplateId: payeeTemplateId,
            accountId: accountId,
            defaultAmountMilliunits: defaultAmountMilliunits,
            memo: memo,
            isBudgetMirror: isBudgetMirror,
            applyDefaultAmount: applyDefaultAmount,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String payeeTemplateId,
            required String accountId,
            Value<int?> defaultAmountMilliunits = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<bool> isBudgetMirror = const Value.absent(),
            Value<bool> applyDefaultAmount = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingTemplatesCompanion.insert(
            id: id,
            payeeTemplateId: payeeTemplateId,
            accountId: accountId,
            defaultAmountMilliunits: defaultAmountMilliunits,
            memo: memo,
            isBudgetMirror: isBudgetMirror,
            applyDefaultAmount: applyDefaultAmount,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PostingTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {payeeTemplateId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (payeeTemplateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.payeeTemplateId,
                    referencedTable: $$PostingTemplatesTableReferences
                        ._payeeTemplateIdTable(db),
                    referencedColumn: $$PostingTemplatesTableReferences
                        ._payeeTemplateIdTable(db)
                        .id,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$PostingTemplatesTableReferences._accountIdTable(db),
                    referencedColumn: $$PostingTemplatesTableReferences
                        ._accountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PostingTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PostingTemplatesTable,
    PostingTemplateRow,
    $$PostingTemplatesTableFilterComposer,
    $$PostingTemplatesTableOrderingComposer,
    $$PostingTemplatesTableAnnotationComposer,
    $$PostingTemplatesTableCreateCompanionBuilder,
    $$PostingTemplatesTableUpdateCompanionBuilder,
    (PostingTemplateRow, $$PostingTemplatesTableReferences),
    PostingTemplateRow,
    PrefetchHooks Function({bool payeeTemplateId, bool accountId})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String type,
  required DateTime date,
  Value<String?> payeeId,
  required String payeeName,
  Value<String?> note,
  required DateTime time,
  Value<DateTime?> budgetMonth,
  Value<String> ynabSyncStatus,
  Value<String> ledgerSyncStatus,
  Value<String?> ynabTransactionId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<DateTime> date,
  Value<String?> payeeId,
  Value<String> payeeName,
  Value<String?> note,
  Value<DateTime> time,
  Value<DateTime?> budgetMonth,
  Value<String> ynabSyncStatus,
  Value<String> ledgerSyncStatus,
  Value<String?> ynabTransactionId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PayeesTable _payeeIdTable(_$AppDatabase db) => db.payees
      .createAlias($_aliasNameGenerator(db.transactions.payeeId, db.payees.id));

  $$PayeesTableProcessedTableManager? get payeeId {
    final $_column = $_itemColumn<String>('payee_id');
    if ($_column == null) return null;
    final manager = $$PayeesTableTableManager($_db, $_db.payees)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PostingsTable, List<PostingRow>>
      _postingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.postings,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.postings.transactionId));

  $$PostingsTableProcessedTableManager get postingsRefs {
    final manager = $$PostingsTableTableManager($_db, $_db.postings).filter(
        (f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payeeName => $composableBuilder(
      column: $table.payeeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get budgetMonth => $composableBuilder(
      column: $table.budgetMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ynabSyncStatus => $composableBuilder(
      column: $table.ynabSyncStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ledgerSyncStatus => $composableBuilder(
      column: $table.ledgerSyncStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ynabTransactionId => $composableBuilder(
      column: $table.ynabTransactionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PayeesTableFilterComposer get payeeId {
    final $$PayeesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableFilterComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> postingsRefs(
      Expression<bool> Function($$PostingsTableFilterComposer f) f) {
    final $$PostingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableFilterComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payeeName => $composableBuilder(
      column: $table.payeeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get budgetMonth => $composableBuilder(
      column: $table.budgetMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ynabSyncStatus => $composableBuilder(
      column: $table.ynabSyncStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ledgerSyncStatus => $composableBuilder(
      column: $table.ledgerSyncStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ynabTransactionId => $composableBuilder(
      column: $table.ynabTransactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PayeesTableOrderingComposer get payeeId {
    final $$PayeesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableOrderingComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get payeeName =>
      $composableBuilder(column: $table.payeeName, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<DateTime> get budgetMonth => $composableBuilder(
      column: $table.budgetMonth, builder: (column) => column);

  GeneratedColumn<String> get ynabSyncStatus => $composableBuilder(
      column: $table.ynabSyncStatus, builder: (column) => column);

  GeneratedColumn<String> get ledgerSyncStatus => $composableBuilder(
      column: $table.ledgerSyncStatus, builder: (column) => column);

  GeneratedColumn<String> get ynabTransactionId => $composableBuilder(
      column: $table.ynabTransactionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PayeesTableAnnotationComposer get payeeId {
    final $$PayeesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableAnnotationComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> postingsRefs<T extends Object>(
      Expression<T> Function($$PostingsTableAnnotationComposer a) f) {
    final $$PostingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableAnnotationComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TransactionRow,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (TransactionRow, $$TransactionsTableReferences),
    TransactionRow,
    PrefetchHooks Function({bool payeeId, bool postingsRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> payeeId = const Value.absent(),
            Value<String> payeeName = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<DateTime?> budgetMonth = const Value.absent(),
            Value<String> ynabSyncStatus = const Value.absent(),
            Value<String> ledgerSyncStatus = const Value.absent(),
            Value<String?> ynabTransactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            type: type,
            date: date,
            payeeId: payeeId,
            payeeName: payeeName,
            note: note,
            time: time,
            budgetMonth: budgetMonth,
            ynabSyncStatus: ynabSyncStatus,
            ledgerSyncStatus: ledgerSyncStatus,
            ynabTransactionId: ynabTransactionId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required DateTime date,
            Value<String?> payeeId = const Value.absent(),
            required String payeeName,
            Value<String?> note = const Value.absent(),
            required DateTime time,
            Value<DateTime?> budgetMonth = const Value.absent(),
            Value<String> ynabSyncStatus = const Value.absent(),
            Value<String> ledgerSyncStatus = const Value.absent(),
            Value<String?> ynabTransactionId = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            type: type,
            date: date,
            payeeId: payeeId,
            payeeName: payeeName,
            note: note,
            time: time,
            budgetMonth: budgetMonth,
            ynabSyncStatus: ynabSyncStatus,
            ledgerSyncStatus: ledgerSyncStatus,
            ynabTransactionId: ynabTransactionId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({payeeId = false, postingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (postingsRefs) db.postings],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (payeeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.payeeId,
                    referencedTable:
                        $$TransactionsTableReferences._payeeIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._payeeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postingsRefs)
                    await $_getPrefetchedData<TransactionRow, $TransactionsTable,
                            PostingRow>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._postingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .postingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TransactionRow,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (TransactionRow, $$TransactionsTableReferences),
    TransactionRow,
    PrefetchHooks Function({bool payeeId, bool postingsRefs})>;
typedef $$PostingsTableCreateCompanionBuilder = PostingsCompanion Function({
  required String id,
  required String transactionId,
  required String accountId,
  required int amountMilliunits,
  Value<String?> memo,
  Value<bool> isBudgetMirror,
  Value<bool> isSource,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$PostingsTableUpdateCompanionBuilder = PostingsCompanion Function({
  Value<String> id,
  Value<String> transactionId,
  Value<String> accountId,
  Value<int> amountMilliunits,
  Value<String?> memo,
  Value<bool> isBudgetMirror,
  Value<bool> isSource,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$PostingsTableReferences
    extends BaseReferences<_$AppDatabase, $PostingsTable, PostingRow> {
  $$PostingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
          $_aliasNameGenerator(db.postings.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts
      .createAlias($_aliasNameGenerator(db.postings.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PostingsTableFilterComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMilliunits => $composableBuilder(
      column: $table.amountMilliunits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBudgetMirror => $composableBuilder(
      column: $table.isBudgetMirror,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSource => $composableBuilder(
      column: $table.isSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMilliunits => $composableBuilder(
      column: $table.amountMilliunits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBudgetMirror => $composableBuilder(
      column: $table.isBudgetMirror,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSource => $composableBuilder(
      column: $table.isSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMilliunits => $composableBuilder(
      column: $table.amountMilliunits, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<bool> get isBudgetMirror => $composableBuilder(
      column: $table.isBudgetMirror, builder: (column) => column);

  GeneratedColumn<bool> get isSource =>
      $composableBuilder(column: $table.isSource, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PostingsTable,
    PostingRow,
    $$PostingsTableFilterComposer,
    $$PostingsTableOrderingComposer,
    $$PostingsTableAnnotationComposer,
    $$PostingsTableCreateCompanionBuilder,
    $$PostingsTableUpdateCompanionBuilder,
    (PostingRow, $$PostingsTableReferences),
    PostingRow,
    PrefetchHooks Function({bool transactionId, bool accountId})> {
  $$PostingsTableTableManager(_$AppDatabase db, $PostingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transactionId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<int> amountMilliunits = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<bool> isBudgetMirror = const Value.absent(),
            Value<bool> isSource = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingsCompanion(
            id: id,
            transactionId: transactionId,
            accountId: accountId,
            amountMilliunits: amountMilliunits,
            memo: memo,
            isBudgetMirror: isBudgetMirror,
            isSource: isSource,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionId,
            required String accountId,
            required int amountMilliunits,
            Value<String?> memo = const Value.absent(),
            Value<bool> isBudgetMirror = const Value.absent(),
            Value<bool> isSource = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingsCompanion.insert(
            id: id,
            transactionId: transactionId,
            accountId: accountId,
            amountMilliunits: amountMilliunits,
            memo: memo,
            isBudgetMirror: isBudgetMirror,
            isSource: isSource,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PostingsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({transactionId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$PostingsTableReferences._transactionIdTable(db),
                    referencedColumn:
                        $$PostingsTableReferences._transactionIdTable(db).id,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$PostingsTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$PostingsTableReferences._accountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PostingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PostingsTable,
    PostingRow,
    $$PostingsTableFilterComposer,
    $$PostingsTableOrderingComposer,
    $$PostingsTableAnnotationComposer,
    $$PostingsTableCreateCompanionBuilder,
    $$PostingsTableUpdateCompanionBuilder,
    (PostingRow, $$PostingsTableReferences),
    PostingRow,
    PrefetchHooks Function({bool transactionId, bool accountId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$PayeesTableTableManager get payees =>
      $$PayeesTableTableManager(_db, _db.payees);
  $$PayeeTemplatesTableTableManager get payeeTemplates =>
      $$PayeeTemplatesTableTableManager(_db, _db.payeeTemplates);
  $$PostingTemplatesTableTableManager get postingTemplates =>
      $$PostingTemplatesTableTableManager(_db, _db.postingTemplates);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$PostingsTableTableManager get postings =>
      $$PostingsTableTableManager(_db, _db.postings);
}
