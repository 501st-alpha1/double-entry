import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git2dart/git2dart.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../services/host_key_store.dart';
import '../../services/settings_service.dart';

class GitSyncException implements Exception {
  final String message;
  final Object? cause;
  GitSyncException(this.message, [this.cause]);

  @override
  String toString() =>
      'GitSyncException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Thrown when [GitSyncRepository] encounters a host it has no stored
/// fingerprint for. Carries the fingerprint so the caller can show it to
/// the user and decide whether to trust it (via [GitSyncRepository.trustHost])
/// before retrying the operation.
class UnknownHostKeyException implements Exception {
  final String host;
  final String fingerprint;
  UnknownHostKeyException(this.host, this.fingerprint);

  @override
  String toString() =>
      'UnknownHostKeyException: unrecognized host key for $host '
      '(SHA256:$fingerprint)';
}

/// Thrown when a host's certificate doesn't match the previously-trusted
/// fingerprint — this is the case TOFU pinning exists to catch (a
/// legitimate key rotation, or a potential MITM attack).
class HostKeyMismatchException implements Exception {
  final String host;
  final String expectedFingerprint;
  final String actualFingerprint;
  HostKeyMismatchException(
      this.host, this.expectedFingerprint, this.actualFingerprint);

  @override
  String toString() =>
      'HostKeyMismatchException: host key for $host changed! '
      'Expected SHA256:$expectedFingerprint, got SHA256:$actualFingerprint. '
      'This could mean the server was reconfigured, or it could indicate '
      'a man-in-the-middle attack.';
}

/// Manages a local single-branch clone of the mobile-sync branch.
class GitSyncRepository {
  final String remoteUrl;
  final String branch;
  final String targetFile;
  final String privateKeyPem;
  final String publicKeyOpenSsh;
  final HostKeyStore hostKeyStore;

  GitSyncRepository({
    required this.remoteUrl,
    required this.branch,
    required this.targetFile,
    required this.privateKeyPem,
    required this.publicKeyOpenSsh,
    required this.hostKeyStore,
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
    if (await isCloned()) {
      await _syncRemoteUrl();
      return;
    }
    await _clone();
  }

  /// Ensures the 'origin' remote URL matches the configured remoteUrl.
  /// Settings may have changed since the repo was first cloned.
  Future<void> _syncRemoteUrl() async {
    final repoPath = await localRepoPath();
    final repo = Repository.open(repoPath);
    try {
      final remote = Remote.lookup(repo: repo, name: 'origin');
      if (remote.url != remoteUrl) {
        debugPrint('Git: remote URL changed from ${remote.url} to $remoteUrl, updating');
        Remote.setUrl(repo: repo, remote: 'origin', url: remoteUrl);
      }
      remote.free();
    } finally {
      repo.free();
    }
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

  KeypairFromMemory get _credentials {
    debugPrint('Git: building KeypairFromMemory, pubKey starts=${publicKeyOpenSsh.substring(0, 20)}..., privKey length=${privateKeyPem.length}');
    return KeypairFromMemory(
      username: 'git',
      pubKey: publicKeyOpenSsh,
      privateKey: privateKeyPem,
      passPhrase: '',
    );
  }

  // ─────────────────────────────────────────────
  // SSH host key verification (TOFU pinning)
  // ─────────────────────────────────────────────

  /// Extracts the bare host from [remoteUrl]. Handles both
  /// "git@host:port/path" (no real port support, kept for compatibility)
  /// and "ssh://git@host:port/path" forms.
  static String hostFromUrl(String url) {
    if (url.startsWith('ssh://')) {
      final withoutScheme = url.substring('ssh://'.length);
      final afterAt = withoutScheme.contains('@')
          ? withoutScheme.substring(withoutScheme.indexOf('@') + 1)
          : withoutScheme;
      final hostPart = afterAt.split('/').first;
      // Strip a port if present (host:port)
      return hostPart.split(':').first;
    }
    // git@host:path/to/repo.git form
    final afterAt = url.contains('@') ? url.substring(url.indexOf('@') + 1) : url;
    return afterAt.split(':').first;
  }

  String get _host => hostFromUrl(remoteUrl);

  /// Formats raw host key bytes as a colon-separated hex fingerprint,
  /// e.g. "AB:CD:EF:...". This is the conventional SSH fingerprint display
  /// format (what `ssh-keygen -lf` and most SSH clients show).
  static String _formatFingerprint(Uint8List bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  /// Picks the best available hash from a [CertificateHostkey], preferring
  /// sha256 > sha1 > md5 > raw, since that's libssh2's own preference order
  /// for which hashes a given build actually has available.
  static String _bestFingerprint(CertificateHostkey cert) {
    if (cert.available.contains(GitCertificateSsh.sha256) &&
        cert.sha256.isNotEmpty) {
      return _formatFingerprint(cert.sha256);
    }
    if (cert.available.contains(GitCertificateSsh.sha1) &&
        cert.sha1.isNotEmpty) {
      return _formatFingerprint(cert.sha1);
    }
    if (cert.available.contains(GitCertificateSsh.md5) &&
        cert.md5.isNotEmpty) {
      return _formatFingerprint(cert.md5);
    }
    // Last-resort fallback: raw key bytes, with no GitCertificateSsh.raw
    // membership check (sha256/sha1/md5 are unavailable by this point on
    // virtually every real libssh2 build; if rawHostkey is also empty
    // here, _formatFingerprint just yields an empty string rather than
    // throwing, which is an acceptable degenerate case for this fallback).
    return _formatFingerprint(cert.rawHostkey);
  }

  /// Builds the certificateCheck callback used on every clone/fetch/push.
  ///
  /// Behavior:
  /// - Host has a stored, matching fingerprint → accept silently.
  /// - Host has a stored fingerprint that DOESN'T match → reject and let
  ///   the resulting Git2DartError surface; callers should treat this
  ///   distinctly from a first-time-unknown host (it usually indicates a
  ///   real problem, not just "needs confirmation").
  /// - Host has never been seen before → reject (so the connection aborts
  ///   immediately, before any auth/data exchange) but first stash the
  ///   fingerprint where [_pendingUnknownHostKey] can report it. Callers
  ///   catch the resulting error, read [fingerprint] off it via
  ///   [UnknownHostKeyException], show it to the user, and call
  ///   [trustHost] + retry if accepted.
  ///
  /// libgit2's certificateCheck callback must be synchronous, which is why
  /// this can't simply await a confirmation dialog — the two-phase
  /// reject-then-retry flow above is the correct way to surface an
  /// interactive prompt around a fundamentally synchronous native callback.
  bool Function(CertificateHostkey, {required bool valid, required String host})
      _certificateCheck() {
    return (cert, {required valid, required host}) {
      debugPrint('Git: certificateCheck callback invoked for host=$host valid=$valid');
      final fingerprint = _bestFingerprint(cert);
      final stored = hostKeyStore.fingerprintFor(host);

      if (stored == null) {
        debugPrint('Git: unknown host key for $host (SHA256:$fingerprint)');
        _pendingUnknownHostKey = UnknownHostKeyException(host, fingerprint);
        return false;
      }

      if (stored != fingerprint) {
        debugPrint(
            'Git: HOST KEY MISMATCH for $host! expected=$stored actual=$fingerprint');
        _pendingHostKeyMismatch =
            HostKeyMismatchException(host, stored, fingerprint);
        return false;
      }

      return true;
    };
  }

  /// Set by [_certificateCheck] when it rejects an unrecognized host, so
  /// the calling method can throw a typed exception with the fingerprint
  /// after the synchronous git2dart call unwinds with its generic error.
  UnknownHostKeyException? _pendingUnknownHostKey;

  /// Set by [_certificateCheck] when a host's fingerprint doesn't match
  /// what's stored — a real change since last time, not just "unseen".
  HostKeyMismatchException? _pendingHostKeyMismatch;

  /// Wraps a git2dart operation, translating a certificateCheck rejection
  /// (which libgit2 reports as a generic Git2DartError) into the specific
  /// [UnknownHostKeyException] or [HostKeyMismatchException] that was
  /// actually responsible, if any.
  T _withCertificateCheckTranslation<T>(T Function() operation) {
    _pendingUnknownHostKey = null;
    _pendingHostKeyMismatch = null;
    try {
      return operation();
    } on Git2DartError {
      if (_pendingHostKeyMismatch != null) {
        throw _pendingHostKeyMismatch!;
      }
      if (_pendingUnknownHostKey != null) {
        throw _pendingUnknownHostKey!;
      }
      rethrow;
    }
  }

  /// Records [host] as trusted with [fingerprint], so future connections
  /// pass certificateCheck silently. Call this after the user has reviewed
  /// and accepted the fingerprint from a caught [UnknownHostKeyException].
  Future<void> trustHost(String host, String fingerprint) =>
      hostKeyStore.trust(host, fingerprint);

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
        _withCertificateCheckTranslation(() => remote.fetch(
              refspecs: ['+refs/heads/$branch:refs/remotes/origin/$branch'],
              callbacks: Callbacks(
                credentials: _credentials,
                certificateCheck: _certificateCheck(),
              ),
            ));
      } on UnknownHostKeyException {
        rethrow;
      } on HostKeyMismatchException {
        rethrow;
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
    debugPrint('Git: _pull starting, repoPath=$repoPath');
    final repo = Repository.open(repoPath);
    try {
      debugPrint('Git: looking up remote origin');
      final remote = Remote.lookup(repo: repo, name: 'origin');
      debugPrint('Git: remote url=${remote.url}');
      try {
        debugPrint('Git: starting fetch, refspec=+refs/heads/$branch:refs/remotes/origin/$branch');
        _withCertificateCheckTranslation(() => remote.fetch(
              refspecs: ['+refs/heads/$branch:refs/remotes/origin/$branch'],
              callbacks: Callbacks(
                credentials: _credentials,
                certificateCheck: _certificateCheck(),
              ),
            ));

        final remoteRef = Reference.lookup(
            repo: repo, name: 'refs/remotes/origin/$branch');
        final theirHead = AnnotatedCommit.lookup(
            repo: repo, oid: remoteRef.target);

        final analysis = Merge.analysis(
            repo: repo, theirHead: remoteRef.target);

        if (analysis.result.contains(GitMergeAnalysis.upToDate)) {
          // Nothing to do
        } else if (analysis.result.contains(GitMergeAnalysis.fastForward)) {
          // Fast-forward: just move HEAD to the remote commit
          repo.reset(oid: remoteRef.target, resetType: GitReset.hard);
        } else if (analysis.result.contains(GitMergeAnalysis.normal)) {
          // Normal merge — since we're the only writer to this branch
          // this shouldn't happen, but handle it gracefully
          Merge.commit(repo: repo, commit: theirHead);
          // Auto-commit the merge result
          _commit(repo,
              authorName: 'Double Entry',
              authorEmail: 'double_entry@localhost');
        }

        theirHead.free();
        remoteRef.free();
      } on UnknownHostKeyException {
        // Must NOT be swallowed — propagate so the caller can prompt and
        // retry. Continuing on to push without verifying the host would
        // defeat the entire purpose of TOFU pinning.
        rethrow;
      } on HostKeyMismatchException {
        rethrow;
      } on Git2DartError catch (e) {
        // Other pull failures are non-fatal — log and continue
        debugPrint('Git pull failed: $e');
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
    _withCertificateCheckTranslation(() => remote.push(
          refspecs: ['refs/heads/$branch:refs/heads/$branch'],
          callbacks: Callbacks(
            credentials: _credentials,
            certificateCheck: _certificateCheck(),
          ),
        ));
    remote.free();
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

/// Async provider that loads the private key and constructs the repository.
final gitSyncProvider = FutureProvider<GitSyncRepository?>((ref) async {
  final settings = ref.watch(settingsProvider).valueOrNull;
  debugPrint('gitSyncProvider: settings=$settings, isGitConfigured=${settings?.isGitConfigured}');
  if (settings == null || !settings.isGitConfigured) return null;
  if (settings.gitPublicKey == null) {
    debugPrint('gitSyncProvider: gitPublicKey is null');
    return null;
  }

  final privateKey =
      await ref.watch(settingsServiceProvider).loadGitPrivateKey();
  debugPrint('gitSyncProvider: privateKey exists=${privateKey != null}');
  if (privateKey == null) return null;

  debugPrint('gitSyncProvider: creating GitSyncRepository url=${settings.gitRemoteUrl} branch=${settings.gitBranch}');
  return GitSyncRepository(
    remoteUrl: settings.gitRemoteUrl!,
    branch: settings.effectiveGitBranch,
    targetFile: settings.effectiveGitTargetFile,
    privateKeyPem: privateKey,
    publicKeyOpenSsh: settings.gitPublicKey!,
    hostKeyStore: ref.watch(hostKeyStoreProvider),
  );
});
