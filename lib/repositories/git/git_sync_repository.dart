import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git2dart/git2dart.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../services/settings_service.dart';

class GitSyncException implements Exception {
  final String message;
  final Object? cause;
  GitSyncException(this.message, [this.cause]);

  @override
  String toString() =>
      'GitSyncException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Manages a local single-branch clone of the mobile-sync branch.
class GitSyncRepository {
  final String remoteUrl;
  final String branch;
  final String targetFile;
  final String privateKeyPem;
  final String publicKeyOpenSsh;

  GitSyncRepository({
    required this.remoteUrl,
    required this.branch,
    required this.targetFile,
    required this.privateKeyPem,
    required this.publicKeyOpenSsh,
  });

  // ─────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────

  /// Returns the path to the local repo clone in app storage.
  static Future<String> localRepoPath() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, 'git_repo');
  }

  /// True if the local clone already exists.
  static Future<bool> isCloned() async {
    final path = await localRepoPath();
    return Directory(p.join(path, '.git')).exists();
  }

  /// Clones the remote repo (single branch) if not already cloned.
  /// Creates the branch as an orphan if it doesn't exist on the remote.
  Future<void> ensureCloned() async {
    if (await isCloned()) return;
    await _clone();
  }

  /// Commits the current state of the target file and pushes to remote.
  /// Call after the Ledger file has already been written by LedgerSyncRepository.
  Future<void> commitAndPush({
    required String authorName,
    required String authorEmail,
  }) async {
    await ensureCloned();
    final repoPath = await localRepoPath();

    // Pull latest before committing
    await _pull(repoPath);

    // Stage, commit, push
    final repo = Repository.open(repoPath);
    try {
      _stageFile(repo, targetFile);
      _commit(repo, authorName: authorName, authorEmail: authorEmail);
      await _push(repo);
    } finally {
      repo.free();
    }
  }

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  KeypairFromMemory get _credentials => KeypairFromMemory(
        username: 'git',
        pubKey: publicKeyOpenSsh,
        privateKey: privateKeyPem,
        passPhrase: '',
      );

  Future<void> _clone() async {
    final repoPath = await localRepoPath();
    await Directory(repoPath).create(recursive: true);

    // Use init + fetch with a single refspec for true single-branch clone.
    final repo = Repository.init(path: repoPath);
    try {
      final remote = Remote.create(
        repo: repo,
        name: 'origin',
        url: remoteUrl,
      );

      bool branchExists = true;
      try {
        remote.fetch(
          refspecs: ['+refs/heads/$branch:refs/remotes/origin/$branch'],
          callbacks: Callbacks(credentials: _credentials),
        );
      } on Git2DartError catch (e) {
        // Only swallow "branch not found" — rethrow anything unexpected
        if (!e.message.contains('not found') &&
            !e.message.contains('Could not find remote branch') &&
            !e.message.contains('Reference') &&
            !e.message.contains('reference')) {
          rethrow;
        }
        branchExists = false;
      }

      // Set HEAD to track our branch
      repo.setHead('refs/heads/$branch');

      if (branchExists) {
        try {
          final remoteRef = Reference.lookup(
              repo: repo, name: 'refs/remotes/origin/$branch');
          final commit = Commit.lookup(repo: repo, oid: remoteRef.target);

          Branch.create(repo: repo, name: branch, target: commit);

          // Check out working tree using reset
          repo.reset(oid: remoteRef.target, resetType: GitReset.hard);

          remoteRef.free();
          commit.free();
        } on Git2DartError {
          // Nothing to check out yet
        }
      }

      remote.free();
    } finally {
      repo.free();
    }
  }

  Future<void> _pull(String repoPath) async {
    final repo = Repository.open(repoPath);
    try {
      final remote = Remote.lookup(repo: repo, name: 'origin');
      try {
        remote.fetch(
          refspecs: ['+refs/heads/$branch:refs/remotes/origin/$branch'],
          callbacks: Callbacks(credentials: _credentials),
        );

        // Fast-forward by resetting to remote ref
        try {
          final remoteRef = Reference.lookup(
              repo: repo, name: 'refs/remotes/origin/$branch');
          repo.reset(oid: remoteRef.target, resetType: GitReset.hard);
          remoteRef.free();
        } on Git2DartError {
          // Already up to date
        }
      } on Git2DartError {
        // Pull failure is non-fatal
      }
      remote.free();
    } finally {
      repo.free();
    }
  }

  void _stageFile(Repository repo, String relativePath) {
    final index = repo.index;
    index.read();
    index.add(relativePath);
    index.write();
    index.free();
  }

  void _commit(
    Repository repo, {
    required String authorName,
    required String authorEmail,
  }) {
    final index = repo.index;
    index.read();
    final treeOid = index.writeTree();
    index.free();

    final tree = Tree.lookup(repo: repo, oid: treeOid);
    final now = DateTime.now();
    final sig = Signature.create(
      name: authorName,
      email: authorEmail,
      time: now.millisecondsSinceEpoch ~/ 1000,
      offset: now.timeZoneOffset.inMinutes,
    );

    final message =
        'Double Entry sync ${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    // Get parent commit if branch exists
    Commit? parent;
    try {
      final head = repo.head;
      parent = Commit.lookup(repo: repo, oid: head.target);
      head.free();
    } on Git2DartError {
      // No commits yet (orphan branch)
    }

    Commit.create(
      repo: repo,
      message: message,
      author: sig,
      committer: sig,
      tree: tree,
      parents: parent != null ? [parent] : [],
      updateRef: 'HEAD',
    );

    parent?.free();
    tree.free();
    sig.free();
  }

  Future<void> _push(Repository repo) async {
    final remote = Remote.lookup(repo: repo, name: 'origin');
    remote.push(
      refspecs: ['refs/heads/$branch:refs/heads/$branch'],
      callbacks: Callbacks(credentials: _credentials),
    );
    remote.free();
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

/// Async provider that loads the private key and constructs the repository.
final gitSyncProvider = FutureProvider<GitSyncRepository?>((ref) async {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null || !settings.isGitConfigured) return null;
  if (settings.gitPublicKey == null) return null;

  final privateKey =
      await ref.watch(settingsServiceProvider).loadGitPrivateKey();
  if (privateKey == null) return null;

  return GitSyncRepository(
    remoteUrl: settings.gitRemoteUrl!,
    branch: settings.gitBranch ?? 'mobile-sync',
    targetFile: settings.gitTargetFile ?? 'mobile.ledger',
    privateKeyPem: privateKey,
    publicKeyOpenSsh: settings.gitPublicKey!,
  );
});
