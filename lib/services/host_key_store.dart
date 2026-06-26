import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyPrefix = 'git_host_key_';

/// Persists accepted SSH host key fingerprints, keyed by host, so the app
/// can implement trust-on-first-use (TOFU) verification instead of relying
/// on a conventional `~/.ssh/known_hosts` file (which doesn't exist in the
/// Android app sandbox).
///
/// Fingerprints are not sensitive — they're meant to be publicly
/// verifiable — so this uses shared_preferences rather than secure storage,
/// matching how other non-sensitive settings are stored.
class HostKeyStore {
  final SharedPreferences _prefs;

  HostKeyStore(this._prefs);

  /// Returns the stored fingerprint for [host], or null if this host has
  /// never been seen/accepted before.
  String? fingerprintFor(String host) => _prefs.getString('$_keyPrefix$host');

  /// Stores [fingerprint] as the trusted fingerprint for [host].
  Future<void> trust(String host, String fingerprint) =>
      _prefs.setString('$_keyPrefix$host', fingerprint);

  /// Removes the stored fingerprint for [host], e.g. if the user wants to
  /// force re-verification (host key rotated legitimately).
  Future<void> forget(String host) => _prefs.remove('$_keyPrefix$host');
}

final hostKeyStoreProvider = Provider<HostKeyStore>((ref) {
  throw UnimplementedError(
    'hostKeyStoreProvider must be overridden before use. '
    'See main.dart for initialization.',
  );
});

/// Reactive wrapper around [HostKeyStore] for UI that needs to rebuild
/// when a fingerprint is trusted or forgotten (e.g. the settings screen's
/// "Forget" action). [HostKeyStore] itself stays a plain storage class —
/// [GitSyncRepository] doesn't need reactivity, only the UI does.
class TrustedHostKeyNotifier extends StateNotifier<String?> {
  final HostKeyStore _store;
  final String host;

  TrustedHostKeyNotifier(this._store, this.host)
      : super(_store.fingerprintFor(host));

  Future<void> forget() async {
    await _store.forget(host);
    state = null;
  }

  Future<void> trust(String fingerprint) async {
    await _store.trust(host, fingerprint);
    state = fingerprint;
  }
}

/// Family provider keyed by host, so the settings screen can watch the
/// fingerprint for whichever host is currently configured and have it
/// update immediately after "Forget".
final trustedHostKeyProvider = StateNotifierProvider.family<
    TrustedHostKeyNotifier, String?, String>((ref, host) {
  return TrustedHostKeyNotifier(ref.watch(hostKeyStoreProvider), host);
});
