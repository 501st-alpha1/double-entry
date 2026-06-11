import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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

    final resolvedPath = await _resolvePath(outputPath);
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

  /// Resolves the output path:
  /// - Absolute paths starting with / are used as-is
  /// - ~ is expanded to the home directory (desktop)
  /// - Relative paths (no leading /) are resolved relative to the
  ///   app documents directory (works on both Android and desktop)
  Future<String> _resolvePath(String path) async {
    if (path.startsWith('~/')) {
      final home = Platform.environment['HOME'];
      if (home != null) return '$home/${path.substring(2)}';
    }
    if (path.startsWith('/')) return path;

    // Relative path — resolve against app documents directory
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, path);
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
/// On Android with Git configured, writes to the git repo working directory.
/// Otherwise writes to the configured output path.
final ledgerOutputRepositoryProvider =
    Provider<LedgerOutputRepository?>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null) return null;

  // On Android with Git configured, use git repo path + target file
  final isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  if (!isDesktop && settings.isGitConfigured) {
    // Path will be resolved at write time using git repo location
    final targetFile = settings.gitTargetFile ?? 'mobile.ledger';
    return _GitPathLedgerOutputRepository(targetFile: targetFile);
  }

  final path = settings.ledgerOutputPath;
  if (path == null) return null;
  return LocalFileLedgerOutputRepository(outputPath: path);
});

/// Writes to the git repo working directory, resolved at write time.
class _GitPathLedgerOutputRepository implements LedgerOutputRepository {
  final String targetFile;
  final LedgerFormatter formatter;

  _GitPathLedgerOutputRepository({
    required this.targetFile,
    this.formatter = const LedgerFormatter(),
  });

  @override
  Future<void> write(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;
    final repoPath = await GitSyncRepository.localRepoPath();
    final delegate = LocalFileLedgerOutputRepository(
      outputPath: p.join(repoPath, targetFile),
      formatter: formatter,
    );
    await delegate.write(transactions);
  }
}
