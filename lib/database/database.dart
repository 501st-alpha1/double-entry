import 'dart:async';
import 'package:drift/drift.dart';

part 'database.g.dart';

// ─────────────────────────────────────────────
// TABLE DEFINITIONS
// ─────────────────────────────────────────────

/// Accounts table. Stores both Ledger and YNAB identities for each account.
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerName => text()();
  TextColumn get ynabId => text().nullable()();
  TextColumn get ynabName => text().nullable()();

  /// The YNAB transfer_payee_id for this account, used when creating
  /// transfer transactions via the API.
  TextColumn get ynabTransferPayeeId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Payees table.
@DataClassName('PayeeRow')
class Payees extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Payee templates table. Each payee has one or more named templates.
@DataClassName('PayeeTemplateRow')
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
@DataClassName('PostingTemplateRow')
class PostingTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get payeeTemplateId =>
      text().references(PayeeTemplates, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get defaultAmountMilliunits => integer().nullable()();
  TextColumn get memo => text().nullable()();
  BoolColumn get isBudgetMirror => boolean().withDefault(const Constant(false))();

  /// Whether autofill should pre-fill the amount from
  /// defaultAmountMilliunits. Currently always false — amounts are
  /// remembered but not yet auto-applied; reserved for a future "remember
  /// amount" toggle.
  BoolColumn get applyDefaultAmount =>
      boolean().withDefault(const Constant(false))();

  /// Display order within the template
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transactions queue. Each row is a pending or synced transaction.
@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();

  /// "expense", "budgetMove", "transfer"
  TextColumn get type => text()();

  DateTimeColumn get date => dateTime()();
  TextColumn get payeeId => text().nullable().references(Payees, #id)();

  /// Raw payee name, kept separately in case payee record is later deleted
  TextColumn get payeeName => text()();

  TextColumn get note => text().nullable()();

  /// Time of the transaction, stored separately from date.
  /// Output as a Ledger tag; not sent to YNAB.
  DateTimeColumn get time => dateTime()();

  /// For budgetMove transactions only: the YNAB month this move applies to
  /// (always normalized to the 1st of that month). Null means "same month
  /// as date" — i.e. no override, no Ledger effective-date tag needed.
  DateTimeColumn get budgetMonth => dateTime().nullable()();

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
@DataClassName('PostingRow')
class Postings extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(Transactions, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get amountMilliunits => integer()();
  TextColumn get memo => text().nullable()();
  BoolColumn get isBudgetMirror =>
      boolean().withDefault(const Constant(false))();

  /// Whether this is the primary source account for YNAB sync.
  /// Exactly one non-mirror posting per transaction should have this set.
  BoolColumn get isSource =>
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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Add isSource column to postings table
        await m.addColumn(postings, postings.isSource);
      }
      if (from < 3) {
        await m.addColumn(accounts, accounts.ynabTransferPayeeId);
      }
      if (from < 4) {
        await m.addColumn(transactions, transactions.budgetMonth);
      }
      if (from < 5) {
        await m.addColumn(postingTemplates, postingTemplates.applyDefaultAmount);
      }
    },
  );

  // DAOs are defined below and attached here for convenience
  late final accountDao = AccountDao(this);
  late final payeeDao = PayeeDao(this);
  late final transactionDao = TransactionDao(this);
}

// ─────────────────────────────────────────────
// DAOs
// ─────────────────────────────────────────────

/// Controls which accounts are shown in the posting row typeahead.
enum AccountSearchFilter {
  /// No filter — show all accounts (used in accounts management screen).
  none,
  /// Regular expense/income — hide budget mirror accounts.
  expense,
  /// Budget move — show only [Assets:Budget:*] accounts.
  budgetMove,
  /// Transfer — show only real Assets/Liabilities, no budget or expense accounts.
  transfer,
}

/// Data access for accounts.
class AccountDao {
  final AppDatabase _db;
  AccountDao(this._db);

  Future<List<AccountRow>> allAccounts() =>
      _db.select(_db.accounts).get();

  Stream<List<AccountRow>> watchAllAccounts() =>
      _db.select(_db.accounts).watch();

  Future<AccountRow?> findById(String id) =>
      (_db.select(_db.accounts)..where((a) => a.id.equals(id)))
          .getSingleOrNull();

  /// Search accounts by partial match on ledgerName or ynabName,
  /// filtered by transaction type context.
  Future<List<AccountRow>> search(String query,
      {AccountSearchFilter filter = AccountSearchFilter.none}) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.accounts)
          ..where((a) {
            final matchesQuery =
                a.ledgerName.lower().like(q) | a.ynabName.lower().like(q);
            switch (filter) {
              case AccountSearchFilter.none:
                return matchesQuery;
              case AccountSearchFilter.expense:
                // Exclude budget mirror accounts (those starting with '[')
                return matchesQuery & a.ledgerName.like('[%').not();
              case AccountSearchFilter.budgetMove:
                // Only show budget category accounts
                return matchesQuery & a.ledgerName.like('[Assets:Budget:%');
              case AccountSearchFilter.transfer:
                // Only real asset/liability accounts, no budget mirrors
                return matchesQuery &
                    a.ledgerName.like('[%').not() &
                    (a.ledgerName.lower().like('assets:%') |
                        a.ledgerName.lower().like('liabilities:%')) &
                    a.ledgerName.lower().like('expenses:%').not();
            }
          }))
        .get();
  }

  /// Returns accounts used in pending transactions that have no ynabId and
  /// are required for YNAB sync:
  /// - Budget mirror accounts ([Assets:Budget:*]) for category mapping on
  ///   regular expense/income transactions
  /// - Budget accounts used directly in budgetMove transactions (these are
  ///   stored as regular, non-mirror postings since there's no "real"
  ///   account side to a budget move)
  /// - Source accounts (isSource = true) for the YNAB account field
  Future<List<AccountRow>> unlinkedAccountsInPendingTransactions() async {
    // Get all pending/failed transaction IDs
    final txQuery = _db.select(_db.transactions)
      ..where((t) =>
          t.ynabSyncStatus.equals('pending') |
          t.ynabSyncStatus.equals('failed'));
    final txIds = (await txQuery.get()).map((t) => t.id).toSet();
    if (txIds.isEmpty) return [];

    // Get every posting for those transactions — we can't safely filter to
    // just isBudgetMirror/isSource here, because budgetMove transactions
    // store their [Assets:Budget:*] postings as plain (non-mirror) rows,
    // and only one of the two postings is flagged isSource. Filtering
    // further by account name happens below instead.
    final postingQuery = _db.select(_db.postings)
      ..where((p) => p.transactionId.isIn(txIds));
    final postings = await postingQuery.get();
    final accountIds = postings.map((p) => p.accountId).toSet();
    if (accountIds.isEmpty) return [];

    // Return accounts with no ynabId, filtered to relevant types:
    // budget mirrors/budget accounts ([Assets:Budget:*]) and real
    // asset/liability accounts (excluding Expenses:* and other bracket
    // accounts like [Liabilities:Budget], which never get linked).
    final accountQuery = _db.select(_db.accounts)
      ..where((a) =>
          a.id.isIn(accountIds) &
          a.ynabId.isNull() &
          (a.ledgerName.like('[Assets:Budget:%') |
           (a.ledgerName.like('[%').not() &
            a.ledgerName.lower().like('expenses:%').not())));
    return accountQuery.get();
  }

  Stream<List<AccountRow>> watchUnlinkedAccountsInPendingTransactions() {
    // Re-run whenever postings or accounts change.
    // Postings change on transaction add/delete; accounts change when
    // YNAB links are added.
    late StreamController<List<AccountRow>> controller;
    StreamSubscription? postingsSub, accountsSub;

    Future<void> rerun() async {
      if (!controller.isClosed) {
        controller.add(await unlinkedAccountsInPendingTransactions());
      }
    }

    controller = StreamController<List<AccountRow>>(
      onListen: () {
        rerun();
        postingsSub =
            _db.select(_db.postings).watch().listen((_) => rerun());
        accountsSub =
            _db.select(_db.accounts).watch().listen((_) => rerun());
      },
      onCancel: () {
        postingsSub?.cancel();
        accountsSub?.cancel();
      },
    );

    return controller.stream;
  }

  Stream<List<AccountRow>> watchSearch(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.accounts)
          ..where((a) =>
              a.ledgerName.lower().like(q) |
              a.ynabName.lower().like(q))
          ..orderBy([(a) => OrderingTerm.asc(a.ledgerName)]))
        .watch();
  }

  Future<void> clearAllYnabLinks() =>
      _db.update(_db.accounts).write(const AccountsCompanion(
        ynabId: Value(null),
        ynabName: Value(null),
        ynabTransferPayeeId: Value(null),
      ));

  Future<void> rename(String id, String newLedgerName) =>
      (_db.update(_db.accounts)..where((a) => a.id.equals(id)))
          .write(AccountsCompanion(ledgerName: Value(newLedgerName)));

  Future<void> upsert(AccountsCompanion account) =>
      _db.into(_db.accounts).insertOnConflictUpdate(account);

  Future<void> delete(String id) =>
      (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
}

/// Data access for payees and their templates.
class PayeeDao {
  final AppDatabase _db;
  PayeeDao(this._db);

  Future<List<PayeeRow>> allPayees() =>
      _db.select(_db.payees).get();

  /// Search payees by partial name match. Used for the payee typeahead.
  Future<List<PayeeRow>> search(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.payees)
          ..where((p) => p.name.lower().like(q)))
        .get();
  }

  Future<PayeeRow?> findById(String id) =>
      (_db.select(_db.payees)..where((p) => p.id.equals(id)))
          .getSingleOrNull();

  Future<List<PayeeTemplateRow>> templatesForPayee(String payeeId) =>
      (_db.select(_db.payeeTemplates)
            ..where((t) => t.payeeId.equals(payeeId)))
          .get();

  /// Finds the "default" template for a payee, if one exists.
  /// Templates are expense-only — there is no per-transaction-type lookup.
  Future<PayeeTemplateRow?> findDefaultTemplate(String payeeId) =>
      (_db.select(_db.payeeTemplates)
            ..where((t) =>
                t.payeeId.equals(payeeId) & t.name.equals('default')))
          .getSingleOrNull();

  Future<List<PostingTemplateRow>> postingsForTemplate(String templateId) =>
      (_db.select(_db.postingTemplates)
            ..where((p) => p.payeeTemplateId.equals(templateId))
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .get();

  /// Replaces all posting templates for [templateId] with [postings].
  /// Used when saving a payee's default template — the new set of
  /// postings fully replaces the old set rather than merging with it.
  Future<void> replacePostingTemplates(
    String templateId,
    List<PostingTemplatesCompanion> postings,
  ) async {
    await (_db.delete(_db.postingTemplates)
          ..where((p) => p.payeeTemplateId.equals(templateId)))
        .go();
    for (final posting in postings) {
      await _db.into(_db.postingTemplates).insert(posting);
    }
  }

  Stream<List<PayeeRow>> watchSearch(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.payees)
          ..where((p) => p.name.lower().like(q))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  Future<void> rename(String id, String newName) =>
      (_db.update(_db.payees)..where((p) => p.id.equals(id)))
          .write(PayeesCompanion(name: Value(newName)));

  Future<void> deletePayee(String id) async {
    // Delete templates and their posting templates first
    final templates = await templatesForPayee(id);
    for (final t in templates) {
      await (_db.delete(_db.postingTemplates)
            ..where((p) => p.payeeTemplateId.equals(t.id)))
          .go();
    }
    await (_db.delete(_db.payeeTemplates)
          ..where((t) => t.payeeId.equals(id)))
        .go();
    await (_db.delete(_db.payees)..where((p) => p.id.equals(id))).go();
  }

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

  Future<TransactionRow?> findById(String id) =>
      (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<TransactionRow?> watchById(String id) =>
      (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  /// All pending transactions (not yet fully synced).
  Future<List<TransactionRow>> pendingTransactions() =>
      (_db.select(_db.transactions)
            ..where((t) =>
                t.ynabSyncStatus.equals('pending') |
                t.ynabSyncStatus.equals('failed') |
                t.ledgerSyncStatus.equals('pending') |
                t.ledgerSyncStatus.equals('failed')))
          .get();

  Stream<List<TransactionRow>> watchPendingTransactions() =>
      (_db.select(_db.transactions)
            ..where((t) =>
                t.ynabSyncStatus.equals('pending') |
                t.ynabSyncStatus.equals('failed') |
                t.ledgerSyncStatus.equals('pending') |
                t.ledgerSyncStatus.equals('failed'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<PostingRow>> postingsForTransaction(String transactionId) =>
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

  Future<void> updateTransaction(String id, TransactionsCompanion data) =>
      (_db.update(_db.transactions)..where((t) => t.id.equals(id)))
          .write(data);

  Future<void> deleteTransaction(String id) =>
      (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();

  Future<void> deletePostingsForTransaction(String transactionId) =>
      (_db.delete(_db.postings)
            ..where((p) => p.transactionId.equals(transactionId)))
          .go();

  /// Delete transactions that are fully synced to both systems.
  Future<void> deleteFullySynced() =>
      (_db.delete(_db.transactions)
            ..where((t) =>
                t.ynabSyncStatus.equals('synced') &
                t.ledgerSyncStatus.equals('synced')))
          .go();
}
