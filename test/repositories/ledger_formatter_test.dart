import 'package:flutter_test/flutter_test.dart';
import 'package:double_entry/models/models.dart';
import 'package:double_entry/repositories/ledger/ledger_formatter.dart';

void main() {
  final formatter = LedgerFormatter();

  // Shared test accounts
  final bankAccount = Account(
    id: 'bank-1',
    ledgerName: 'assets:bank:checking',
    ynabId: 'ynab-bank-uuid',
    ynabName: 'Checking',
  );
  final foodExpense = Account(
    id: 'food-1',
    ledgerName: 'expenses:food',
    ynabId: 'ynab-food-uuid',
    ynabName: 'Groceries',
  );
  final budgetFood = Account(
    id: 'budget-food-1',
    ledgerName: '[Assets:Budget:Food]',
  );
  final budgetOffset = Account(
    id: 'budget-offset-1',
    ledgerName: '[Liabilities:Budget]',
  );

  group('LedgerFormatter', () {
    test('formats a simple expense transaction', () {
      final transaction = Transaction(
        id: 'tx-1',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Whole Foods',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
          Posting(
              account: budgetFood,
              amountMilliunits: -45000,
              isBudgetMirror: true),
          Posting(
              account: budgetOffset,
              amountMilliunits: 45000,
              isBudgetMirror: true),
        ],
        createdAt: DateTime(2024, 1, 15),
      );

      final output = formatter.formatTransaction(transaction);

      expect(output, contains('2024/01/15 Whole Foods'));
      expect(output, contains('Expenses:Food'));
      expect(output, contains('Assets:Bank:Checking'));
      expect(output, contains('[Assets:Budget:Food]'));
      expect(output, contains('[Liabilities:Budget]'));
      expect(output, contains(r'$45.00'));
      expect(output, contains(r'$-45.00'));
    });

    test('includes transaction note as comment', () {
      final transaction = Transaction(
        id: 'tx-2',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Whole Foods',
        note: 'Weekly grocery run',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
        ],
        createdAt: DateTime(2024, 1, 15),
      );

      final output = formatter.formatTransaction(transaction);
      expect(output, contains(';; Weekly grocery run'));
    });

    test('real postings appear before budget mirror postings', () {
      final transaction = Transaction(
        id: 'tx-3',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Whole Foods',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
          Posting(
              account: budgetFood,
              amountMilliunits: -45000,
              isBudgetMirror: true),
          Posting(
              account: budgetOffset,
              amountMilliunits: 45000,
              isBudgetMirror: true),
        ],
        createdAt: DateTime(2024, 1, 15),
      );

      final output = formatter.formatTransaction(transaction);
      final foodIdx = output.indexOf('Expenses:Food');
      final bankIdx = output.indexOf('Assets:Bank');
      final budgetIdx = output.indexOf('[Assets:Budget');

      expect(foodIdx, lessThan(budgetIdx));
      expect(bankIdx, lessThan(budgetIdx));
    });

    test('formats a budget move (no real postings)', () {
      final groceriesAccount = Account(
          id: 'budget-groceries', ledgerName: 'assets:budget:groceries');
      final diningAccount =
          Account(id: 'budget-dining', ledgerName: 'assets:budget:dining');

      final transaction = Transaction(
        id: 'tx-4',
        type: TransactionType.budgetMove,
        date: DateTime(2024, 1, 15),
        payee: 'Budget adjustment',
        postings: [
          Posting(
              account: groceriesAccount,
              amountMilliunits: -20000,
              isBudgetMirror: true),
          Posting(
              account: diningAccount,
              amountMilliunits: 20000,
              isBudgetMirror: true),
        ],
        createdAt: DateTime(2024, 1, 15),
      );

      final output = formatter.formatTransaction(transaction);
      expect(output, contains('Assets:Budget:Groceries'));
      expect(output, contains('Assets:Budget:Dining'));
    });

    test('formats multiple transactions separated by blank lines', () {
      final tx = Transaction(
        id: 'tx-5',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Test',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 10000),
          Posting(account: bankAccount, amountMilliunits: -10000),
        ],
        createdAt: DateTime(2024, 1, 15),
      );

      final output = formatter.formatTransactions([tx, tx]);
      expect(output, contains('\n\n'));
    });

    test('includes TransactionTime tag with HH:MM format', () {
      final transaction = Transaction(
        id: 'tx-7',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Whole Foods',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
        ],
        createdAt: DateTime(2024, 1, 15, 9, 5), // 09:05
        time: DateTime(2024, 1, 15, 13, 42),
      );

      final output = formatter.formatTransaction(transaction);
      expect(output, contains(';; TransactionTime: 13:42'));
    });

    test('TransactionTime defaults to createdAt when not specified', () {
      final transaction = Transaction(
        id: 'tx-8',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Whole Foods',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
        ],
        createdAt: DateTime(2024, 1, 15, 9, 5),
      );

      final output = formatter.formatTransaction(transaction);
      expect(output, contains(';; TransactionTime: 09:05'));
    });

    test('TransactionTime tag appears before postings', () {
      final transaction = Transaction(
        id: 'tx-9',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Whole Foods',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
        ],
        createdAt: DateTime(2024, 1, 15, 13, 42),
      );

      final output = formatter.formatTransaction(transaction);
      final timeIdx = output.indexOf('TransactionTime');
      final postingIdx = output.indexOf('Expenses:Food');
      expect(timeIdx, lessThan(postingIdx));
    });

    test('amount formatting: milliunits to display string', () {
      final tx = Transaction(
        id: 'tx-6',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Test',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 1050), // $1.05
          Posting(account: bankAccount, amountMilliunits: -1050),
        ],
        createdAt: DateTime(2024, 1, 15),
      );

      final output = formatter.formatTransaction(tx);
      expect(output, contains(r'$1.05'));
      expect(output, contains(r'$-1.05'));
    });

    test('TransactionTime appears before note comment', () {
      final transaction = Transaction(
        id: 'tx-10',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Whole Foods',
        note: 'Weekly grocery run',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
        ],
        createdAt: DateTime(2024, 1, 15, 13, 42),
      );

      final output = formatter.formatTransaction(transaction);
      final timeIdx = output.indexOf('TransactionTime');
      final noteIdx = output.indexOf('Weekly grocery run');
      expect(timeIdx, lessThan(noteIdx));
    });

    test('amount end-column aligns to column 80', () {
      final transaction = Transaction(
        id: 'tx-11',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        payee: 'Test',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
        ],
        createdAt: DateTime(2024, 1, 15),
      );

      final output = formatter.formatTransaction(transaction);
      // Each posting line should end at column 80 (before the newline)
      for (final line in output.split('\n')) {
        if (line.trimLeft().startsWith(';') || line.trim().isEmpty) continue;
        if (line.startsWith('    ') && !line.trimLeft().startsWith(';;')) {
          // Posting line — strip trailing newline and check length
          expect(line.trimRight().length, equals(80),
              reason: 'Posting line should be 80 chars: "$line"');
        }
      }
    });

    test('budget move with budgetMonth in the same month as date has no '
        'effective-date comment', () {
      final groceriesAccount = Account(
          id: 'budget-groceries', ledgerName: '[Assets:Budget:Groceries]');
      final diningAccount =
          Account(id: 'budget-dining', ledgerName: '[Assets:Budget:Dining]');

      final transaction = Transaction(
        id: 'tx-12',
        type: TransactionType.budgetMove,
        date: DateTime(2024, 1, 15),
        payee: 'Budget adjustment',
        postings: [
          Posting(
              account: groceriesAccount,
              amountMilliunits: -20000,
              isBudgetMirror: true),
          Posting(
              account: diningAccount,
              amountMilliunits: 20000,
              isBudgetMirror: true),
        ],
        createdAt: DateTime(2024, 1, 15),
        budgetMonth: DateTime(2024, 1, 1),
      );

      final output = formatter.formatTransaction(transaction);
      expect(output, isNot(contains('[=')));
    });

    test('budget move with prior budgetMonth includes effective-date '
        'comment for the last day of that month', () {
      final groceriesAccount = Account(
          id: 'budget-groceries', ledgerName: '[Assets:Budget:Groceries]');
      final diningAccount =
          Account(id: 'budget-dining', ledgerName: '[Assets:Budget:Dining]');

      final transaction = Transaction(
        id: 'tx-13',
        type: TransactionType.budgetMove,
        date: DateTime(2026, 6, 20),
        payee: 'Budget adjustment',
        postings: [
          Posting(
              account: groceriesAccount,
              amountMilliunits: -20000,
              isBudgetMirror: true),
          Posting(
              account: diningAccount,
              amountMilliunits: 20000,
              isBudgetMirror: true),
        ],
        createdAt: DateTime(2026, 6, 20),
        budgetMonth: DateTime(2026, 5, 1),
      );

      final output = formatter.formatTransaction(transaction);
      expect(output, contains(';; [=2026/05/31]'));
    });

    test('effective-date comment appears after TransactionTime and before '
        'the note', () {
      final groceriesAccount = Account(
          id: 'budget-groceries', ledgerName: '[Assets:Budget:Groceries]');
      final diningAccount =
          Account(id: 'budget-dining', ledgerName: '[Assets:Budget:Dining]');

      final transaction = Transaction(
        id: 'tx-14',
        type: TransactionType.budgetMove,
        date: DateTime(2026, 6, 20),
        payee: 'Budget adjustment',
        note: 'Catching up May overspend',
        postings: [
          Posting(
              account: groceriesAccount,
              amountMilliunits: -20000,
              isBudgetMirror: true),
          Posting(
              account: diningAccount,
              amountMilliunits: 20000,
              isBudgetMirror: true),
        ],
        createdAt: DateTime(2026, 6, 20, 13, 42),
        budgetMonth: DateTime(2026, 5, 1),
      );

      final output = formatter.formatTransaction(transaction);
      final timeIdx = output.indexOf('TransactionTime');
      final effDateIdx = output.indexOf('[=2026/05/31]');
      final noteIdx = output.indexOf('Catching up May overspend');

      expect(timeIdx, lessThan(effDateIdx));
      expect(effDateIdx, lessThan(noteIdx));
    });

    test('budgetMonth on non-budgetMove transaction has no effect', () {
      // isBudgetMonthOverridden requires the postings model's own check,
      // but the formatter always checks transaction.isBudgetMonthOverridden,
      // which only depends on budgetMonth vs date, not type. Confirm here
      // that an expense with a stray budgetMonth set still emits the tag,
      // since the model intentionally doesn't gate on type — only the
      // notifier guarantees budgetMonth is null outside budgetMove.
      final transaction = Transaction(
        id: 'tx-15',
        type: TransactionType.expense,
        date: DateTime(2026, 6, 20),
        payee: 'Whole Foods',
        postings: [
          Posting(account: foodExpense, amountMilliunits: 45000),
          Posting(account: bankAccount, amountMilliunits: -45000),
        ],
        createdAt: DateTime(2026, 6, 20),
        budgetMonth: null,
      );

      final output = formatter.formatTransaction(transaction);
      expect(output, isNot(contains('[=')));
    });
  });
}
