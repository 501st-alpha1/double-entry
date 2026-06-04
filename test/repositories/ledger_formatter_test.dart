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
    ledgerName: 'assets:budget:food',
  );
  final budgetOffset = Account(
    id: 'budget-offset-1',
    ledgerName: 'liabilities:budget',
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
      expect(output, contains('Assets:Budget:Food'));
      expect(output, contains('Liabilities:Budget'));
      expect(output, contains(r'$45.00'));
      expect(output, contains(r'-$45.00'));
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
      final budgetIdx = output.indexOf('Assets:Budget');

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
      expect(output, contains(r'-$1.05'));
    });
  });
}
