import '../models/models.dart';

/// Formats [Transaction] objects into Ledger-CLI plain text format.
///
/// This is pure Dart with no external dependencies, making it fully testable
/// in isolation.
class LedgerFormatter {
  /// The currency symbol to use. Defaults to "$".
  final String currencySymbol;

  /// Column at which to align amounts. Defaults to 80.
  final int amountColumn;

  const LedgerFormatter({
    this.currencySymbol = r'$',
    this.amountColumn = 80,
  });

  /// Formats a single transaction as a Ledger journal entry string.
  ///
  /// Example output:
  /// ```
  /// 2024/01/15 Whole Foods
  ///     ;; Picked up groceries and snacks
  ///     ;; TransactionTime: 13:42
  ///     Expenses:Food                                                         $45.00
  ///     Assets:Budget:Food                                                   $-45.00
  ///     Assets:Bank:Checking                                                 $-45.00
  ///     Liabilities:Budget                                                    $45.00
  /// ```
  String formatTransaction(Transaction transaction) {
    final buffer = StringBuffer();

    // Header line: date and payee
    final dateStr = _formatDate(transaction.date);
    buffer.writeln('$dateStr ${transaction.payee}');

    // Transaction-level note as a comment
    if (transaction.note != null && transaction.note!.isNotEmpty) {
      buffer.writeln('    ;; ${transaction.note}');
    }

    // Transaction time as a Ledger tag
    buffer.writeln('    ;; TransactionTime: ${_formatTime(transaction.time)}');

    // Postings: real postings first, then budget mirror postings
    final ordered = [
      ...transaction.realPostings,
      ...transaction.budgetPostings,
    ];

    for (final posting in ordered) {
      buffer.writeln(_formatPosting(posting));
    }

    return buffer.toString();
  }

  /// Formats a list of transactions, separated by blank lines.
  String formatTransactions(List<Transaction> transactions) {
    return transactions.map(formatTransaction).join('\n');
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  String _formatPosting(Posting posting) {
    final accountName = posting.account.ledgerName;
    final amountStr = _formatAmount(posting.amountMilliunits);

    // Pad account name to amountColumn, then append amount
    // Ledger requires at least two spaces between account and amount
    final padding = (amountColumn - 4 - accountName.length)
        .clamp(2, 999);
    final line =
        '    $accountName${' ' * padding}$amountStr';

    // Per-posting memo as inline comment
    if (posting.memo != null && posting.memo!.isNotEmpty) {
      return '$line  ;; ${posting.memo}';
    }
    return line;
  }

  String _formatAmount(int milliunits) {
    final isNegative = milliunits < 0;
    final abs = milliunits.abs();
    final dollars = abs ~/ 1000;
    final cents = (abs % 1000) ~/ 10;
    final formatted =
        '$currencySymbol$dollars.${cents.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }
}
