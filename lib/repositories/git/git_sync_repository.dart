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

/// Manages a local clone of the mobile-sync branch and pushes commits to it.
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
  /// Call this after the Ledger file has already been written by LedgerSyncRepository.
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

  Credentials get _credentials => KeypairFromMemory(
        username: 'git',
        pubKey: publicKeyOpenSsh,
        privateKey: privateKeyPem,
        passPhrase: '',
      );

  Future<void> _clone() async {
    final repoPath = await localRepoPath();
    await Directory(repoPath).create(recursive: true);

    // Use init + remote add + fetch instead of Repository.clone so we can
    // specify a single-branch refspec and avoid downloading the entire repo.
    final repo = Repository.init(path: repoPath);
    try {
      final remote = Remote.create(
        repo: repo,
        name: 'origin',
        url: remoteUrl,
      );

      try {
        remote.fetch(
          refspecs: ['+refs/heads/$branch:refs/remotes/origin/$branch'],
          callbacks: RemoteCallbacks(
            credentials: (url, username, types) => _credentials,
          ),
        );
      } on LibGit2Error catch (e) {
        // Branch doesn't exist on remote yet — that's fine, leave repo empty
        if (!e.message.contains('not found') &&
            !e.message.contains('Could not find remote branch')) {
          rethrow;
        }
        // Orphan branch — nothing to check out, leave as empty repo
        repo.setHead('refs/heads/$branch');
        remote.free();
        return;
      }

      // Set HEAD to track our branch
      repo.setHead('refs/heads/$branch');

      // Check out the branch from the fetched remote ref
      try {
        final remoteRef = Reference.lookup(
            repo: repo, name: 'refs/remotes/origin/$branch');
        final commit = Commit.lookup(repo: repo, oid: remoteRef.target);

        // Create local branch pointing to remote commit
        Branch.create(
          repo: repo,
          name: branch,
          commit: commit,
          force: true,
        );

        // Checkout working tree
        repo.checkout(refName: 'refs/heads/$branch');

        remoteRef.free();
        commit.free();
      } on LibGit2Error {
        // Remote branch was empty — leave as orphan
      }

      remote.free();
    } finally {
      repo.free();
    }
  }

  Future<void> _initOrphanBranch(String repoPath) async {
    // No-op — _clone now handles missing branches as orphans directly
  }

  Future<void> _pull(String repoPath) async {
    final repo = Repository.open(repoPath);
    try {
      final remote = Remote.lookup(repo: repo, name: 'origin');
      remote.fetch(
        refspecs: ['+refs/heads/$branch:refs/remotes/origin/$branch'],
        callbacks: RemoteCallbacks(
          credentials: (url, username, types) => _credentials,
        ),
      );

      // Fast-forward merge if remote is ahead
      try {
        final remoteRef = Reference.lookup(
            repo: repo, name: 'refs/remotes/origin/$branch');
        final remoteCommit =
            Commit.lookup(repo: repo, oid: remoteRef.target);
        repo.mergeFastForward(commit: remoteCommit, setHead: true);
        remoteRef.free();
        remoteCommit.free();
      } on LibGit2Error {
        // Already up to date or nothing to fast-forward — fine
      }

      remote.free();
    } catch (e) {
      // Pull failure is non-fatal — we'll push anyway and let the
      // user resolve if there's a conflict
    } finally {
      repo.free();
    }
  }

  void _stageFile(Repository repo, String relativePath) {
    final index = repo.index;
    index.read();
    index.addByPath(relativePath);
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
    final sig = Signature.create(
      name: authorName,
      email: authorEmail,
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      offset: DateTime.now().timeZoneOffset.inMinutes,
    );

    final now = DateTime.now();
    final message =
        'Double Entry sync ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Get parent commit if branch exists
    Commit? parent;
    try {
      final head = repo.head;
      parent = Commit.lookup(repo: repo, oid: head.target);
      head.free();
    } on LibGit2Error {
      // No commits yet (orphan branch) — that's fine
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
      callbacks: RemoteCallbacks(
        credentials: (url, username, types) => _credentials,
      ),
    );
    remote.free();
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final gitSyncRepositoryProvider = Provider<GitSyncRepository?>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null || !settings.isGitConfigured) return null;
  if (settings.gitPublicKey == null) return null;

  // Private key is loaded async — handled in GitSyncNotifier
  return null; // constructed lazily via gitSyncNotifierProvider
});

/// Async provider that loads the private key and constructs the repository.
final gitSyncProvider =
    FutureProvider<GitSyncRepository?>((ref) async {
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
