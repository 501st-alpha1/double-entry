import 'package:drift/drift.dart';

// ─────────────────────────────────────────────
// TABLE DEFINITIONS
// ─────────────────────────────────────────────

/// Accounts table. Stores both Ledger and YNAB identities for each account.
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerName => text()();
  TextColumn get ynabId => text().nullable()();
  TextColumn get ynabName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Payees table.
class Payees extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Payee templates table. Each payee has one or more named templates.
class PayeeTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get payeeId => text().references(Payees, #id)();

  /// "default" or a descriptive variation name e.g. "cash back"
  TextColumn get name => text()();

  /// TransactionType enum value as string: "expense", "budgetMove", "transfer"
  TextColumn get transactionType => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Posting templates belonging to a PayeeTemplate.
class PostingTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get payeeTemplateId =>
      text().references(PayeeTemplates, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get defaultAmountMilliunits => integer().nullable()();
  TextColumn get memo => text().nullable()();
  BoolColumn get isBudgetMirror => boolean().withDefault(const Constant(false))();

  /// Display order within the template
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transactions queue. Each row is a pending or synced transaction.
class Transactions extends Table {
  TextColumn get id => text()();

  /// "expense", "budgetMove", "transfer"
  TextColumn get type => text()();

  DateTimeColumn get date => dateTime()();
  TextColumn get payeeId => text().nullable().references(Payees, #id)();

  /// Raw payee name, kept separately in case payee record is later deleted
  TextColumn get payeeName => text()();

  TextColumn get note => text().nullable()();

  /// "pending", "synced", "failed"
  TextColumn get ynabSyncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get ledgerSyncStatus =>
      text().withDefault(const Constant('pending'))();

  TextColumn get ynabTransactionId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Individual postings belonging to a Transaction.
class Postings extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(Transactions, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get amountMilliunits => integer()();
  TextColumn get memo => text().nullable()();
  BoolColumn get isBudgetMirror =>
      boolean().withDefault(const Constant(false))();

  /// Display order within the transaction
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────
// DATABASE
// ─────────────────────────────────────────────

@DriftDatabase(tables: [
  Accounts,
  Payees,
  PayeeTemplates,
  PostingTemplates,
  Transactions,
  Postings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // DAOs are defined below and attached here for convenience
  late final accountDao = AccountDao(this);
  late final payeeDao = PayeeDao(this);
  late final transactionDao = TransactionDao(this);
}

// ─────────────────────────────────────────────
// DAOs
// ─────────────────────────────────────────────

/// Data access for accounts.
class AccountDao {
  final AppDatabase _db;
  AccountDao(this._db);

  Future<List<Account>> allAccounts() =>
      _db.select(_db.accounts).get();

  Stream<List<Account>> watchAllAccounts() =>
      _db.select(_db.accounts).watch();

  Future<Account?> findById(String id) =>
      (_db.select(_db.accounts)..where((a) => a.id.equals(id)))
          .getSingleOrNull();

  /// Search accounts by partial match on ledgerName or ynabName.
  /// Used for the typeahead widget.
  Future<List<Account>> search(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.accounts)
          ..where((a) =>
              a.ledgerName.lower().like(q) |
              a.ynabName.lower().like(q)))
        .get();
  }

  Future<void> upsert(AccountsCompanion account) =>
      _db.into(_db.accounts).insertOnConflictUpdate(account);

  Future<void> delete(String id) =>
      (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
}

/// Data access for payees and their templates.
class PayeeDao {
  final AppDatabase _db;
  PayeeDao(this._db);

  Future<List<Payee>> allPayees() =>
      _db.select(_db.payees).get();

  /// Search payees by partial name match. Used for the payee typeahead.
  Future<List<Payee>> search(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.payees)
          ..where((p) => p.name.lower().like(q)))
        .get();
  }

  Future<Payee?> findById(String id) =>
      (_db.select(_db.payees)..where((p) => p.id.equals(id)))
          .getSingleOrNull();

  Future<List<PayeeTemplate>> templatesForPayee(String payeeId) =>
      (_db.select(_db.payeeTemplates)
            ..where((t) => t.payeeId.equals(payeeId)))
          .get();

  Future<List<PostingTemplate>> postingsForTemplate(String templateId) =>
      (_db.select(_db.postingTemplates)
            ..where((p) => p.payeeTemplateId.equals(templateId))
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .get();

  Future<void> upsertPayee(PayeesCompanion payee) =>
      _db.into(_db.payees).insertOnConflictUpdate(payee);

  Future<void> upsertTemplate(PayeeTemplatesCompanion template) =>
      _db.into(_db.payeeTemplates).insertOnConflictUpdate(template);

  Future<void> upsertPostingTemplate(PostingTemplatesCompanion posting) =>
      _db.into(_db.postingTemplates).insertOnConflictUpdate(posting);
}

/// Data access for the transaction queue.
class TransactionDao {
  final AppDatabase _db;
  TransactionDao(this._db);

  /// All pending transactions (not yet fully synced).
  Future<List<Transaction>> pendingTransactions() =>
      (_db.select(_db.transactions)
            ..where((t) =>
                t.ynabSyncStatus.equals('pending') |
                t.ledgerSyncStatus.equals('pending')))
          .get();

  Stream<List<Transaction>> watchPendingTransactions() =>
      (_db.select(_db.transactions)
            ..where((t) =>
                t.ynabSyncStatus.equals('pending') |
                t.ledgerSyncStatus.equals('pending'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<Posting>> postingsForTransaction(String transactionId) =>
      (_db.select(_db.postings)
            ..where((p) => p.transactionId.equals(transactionId))
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .get();

  Future<void> insertTransaction(TransactionsCompanion transaction) =>
      _db.into(_db.transactions).insert(transaction);

  Future<void> insertPosting(PostingsCompanion posting) =>
      _db.into(_db.postings).insert(posting);

  Future<void> updateSyncStatus({
    required String transactionId,
    String? ynabStatus,
    String? ledgerStatus,
    String? ynabTransactionId,
  }) =>
      (_db.update(_db.transactions)
            ..where((t) => t.id.equals(transactionId)))
          .write(TransactionsCompanion(
        ynabSyncStatus: ynabStatus != null
            ? Value(ynabStatus)
            : const Value.absent(),
        ledgerSyncStatus: ledgerStatus != null
            ? Value(ledgerStatus)
            : const Value.absent(),
        ynabTransactionId: ynabTransactionId != null
            ? Value(ynabTransactionId)
            : const Value.absent(),
      ));

  /// Delete transactions that are fully synced to both systems.
  Future<void> deleteFullySynced() =>
      (_db.delete(_db.transactions)
            ..where((t) =>
                t.ynabSyncStatus.equals('synced') &
                t.ledgerSyncStatus.equals('synced')))
          .go();
}
