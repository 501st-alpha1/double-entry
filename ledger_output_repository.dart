import '../../models/models.dart';
import 'ledger_formatter.dart';

// ─────────────────────────────────────────────
// ABSTRACT INTERFACE
// ─────────────────────────────────────────────

/// Abstraction over how formatted Ledger entries are delivered.
/// Different implementations handle Git push, local file export, etc.
abstract class LedgerOutputRepository {
  /// Write a list of transactions to the output destination.
  /// Throws [LedgerOutputException] on failure.
  Future<void> write(List<Transaction> transactions);
}

class LedgerOutputException implements Exception {
  final String message;
  final Object? cause;
  LedgerOutputException(this.message, [this.cause]);

  @override
  String toString() => 'LedgerOutputException: $message'
      '${cause != null ? ' ($cause)' : ''}';
}

// ─────────────────────────────────────────────
// LOCAL FILE IMPLEMENTATION (v1 fallback)
// ─────────────────────────────────────────────

/// Writes formatted Ledger entries to a local file, appending each session
/// as a new file (e.g. mobile_2024_01_15_001.ledger).
///
/// This is the v1 implementation. The Git-based implementation will replace
/// or sit alongside this once git2dart is validated.
class LocalFileLedgerOutputRepository implements LedgerOutputRepository {
  final String outputDirectory;
  final LedgerFormatter formatter;

  LocalFileLedgerOutputRepository({
    required this.outputDirectory,
    this.formatter = const LedgerFormatter(),
  });

  @override
  Future<void> write(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;

    final filename = _generateFilename();
    final path = '$outputDirectory/$filename';
    final content = formatter.formatTransactions(transactions);

    // Platform-specific file I/O will be injected here.
    // For now this is a stub — actual File writing requires dart:io
    // which is available on Android and desktop but not web.
    throw UnimplementedError(
      'File I/O not yet wired. Would write ${transactions.length} '
      'transactions to $path:\n\n$content',
    );
  }

  String _generateFilename() {
    final now = DateTime.now();
    final date =
        '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
    return 'mobile_$date.ledger';
  }
}

// ─────────────────────────────────────────────
// GIT IMPLEMENTATION (stub — spike required)
// ─────────────────────────────────────────────

/// Appends formatted Ledger entries to mobile.ledger in a Git repository,
/// then commits and pushes.
///
/// Requires git2dart validation spike before implementation.
/// See: https://pub.dev/packages/git2dart
class GitLedgerOutputRepository implements LedgerOutputRepository {
  final String repositoryPath;
  final String targetFile;
  final LedgerFormatter formatter;

  GitLedgerOutputRepository({
    required this.repositoryPath,
    this.targetFile = 'mobile.ledger',
    this.formatter = const LedgerFormatter(),
  });

  @override
  Future<void> write(List<Transaction> transactions) async {
    throw UnimplementedError(
      'Git integration pending git2dart spike. '
      'Fall back to LocalFileLedgerOutputRepository.',
    );
  }
}
