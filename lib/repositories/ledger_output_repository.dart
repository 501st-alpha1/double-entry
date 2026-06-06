import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../services/settings_service.dart';
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
  String toString() =>
      'LedgerOutputException: $message${cause != null ? ' ($cause)' : ''}';
}

// ─────────────────────────────────────────────
// LOCAL FILE IMPLEMENTATION
// ─────────────────────────────────────────────

/// Appends formatted Ledger entries to a single configured output file.
/// The file is created if it doesn't exist; entries are appended with a
/// blank line separator so the file stays valid Ledger syntax.
class LocalFileLedgerOutputRepository implements LedgerOutputRepository {
  final String outputPath;
  final LedgerFormatter formatter;

  LocalFileLedgerOutputRepository({
    required this.outputPath,
    this.formatter = const LedgerFormatter(),
  });

  @override
  Future<void> write(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;

    // Expand ~ to the home directory
    final resolvedPath = outputPath.startsWith('~/')
        ? '${Platform.environment['HOME']}/${outputPath.substring(2)}'
        : outputPath;

    final file = File(resolvedPath);

    try {
      // Create parent directories if they don't exist
      await file.parent.create(recursive: true);

      final content = formatter.formatTransactions(transactions);

      // If the file already exists and is non-empty, ensure we start
      // on a new line with a blank separator.
      String prefix = '';
      if (await file.exists()) {
        final existing = await file.readAsString();
        if (existing.isNotEmpty && !existing.endsWith('\n\n')) {
          prefix = existing.endsWith('\n') ? '\n' : '\n\n';
        }
      }

      await file.writeAsString(
        '$prefix$content',
        mode: FileMode.append,
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw LedgerOutputException(
        'Failed to write to $resolvedPath',
        e,
      );
    }
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

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

/// Provides the configured [LedgerOutputRepository].
/// Returns null if no output path is configured.
final ledgerOutputRepositoryProvider =
    Provider<LedgerOutputRepository?>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  final path = settings?.ledgerOutputPath;
  if (path == null) return null;
  return LocalFileLedgerOutputRepository(outputPath: path);
});
