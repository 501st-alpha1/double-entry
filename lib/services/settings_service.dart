import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// Keys
// ─────────────────────────────────────────────

const _keyYnabToken = 'ynab_token';
const _keyYnabBudgetId = 'ynab_budget_id';
const _keyLedgerOutputPath = 'ledger_output_path';

// ─────────────────────────────────────────────
// Settings model
// ─────────────────────────────────────────────

/// Immutable snapshot of all app settings.
class AppSettings {
  /// YNAB personal access token. Null if not yet configured.
  final String? ynabToken;

  /// Selected YNAB budget ID. Null if not yet configured.
  final String? ynabBudgetId;

  /// Path to the Ledger output file, e.g. "/home/user/Documents/mobile.ledger"
  final String? ledgerOutputPath;

  const AppSettings({
    this.ynabToken,
    this.ynabBudgetId,
    this.ledgerOutputPath,
  });

  bool get isYnabConfigured => ynabToken != null && ynabBudgetId != null;
  bool get isLedgerConfigured => ledgerOutputPath != null;
  bool get isFullyConfigured => isYnabConfigured && isLedgerConfigured;

  AppSettings copyWith({
    String? ynabToken,
    String? ynabBudgetId,
    String? ledgerOutputPath,
    bool clearYnabToken = false,
    bool clearYnabBudgetId = false,
    bool clearLedgerOutputPath = false,
  }) {
    return AppSettings(
      ynabToken: clearYnabToken ? null : (ynabToken ?? this.ynabToken),
      ynabBudgetId:
          clearYnabBudgetId ? null : (ynabBudgetId ?? this.ynabBudgetId),
      ledgerOutputPath: clearLedgerOutputPath
          ? null
          : (ledgerOutputPath ?? this.ledgerOutputPath),
    );
  }
}

// ─────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────

/// Manages reading and writing app settings.
/// Sensitive values (YNAB token) go to flutter_secure_storage.
/// Non-sensitive values go to shared_preferences.
class SettingsService {
  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  SettingsService(this._secure, this._prefs);

  /// Loads all settings into an [AppSettings] snapshot.
  Future<AppSettings> load() async {
    final token = await _secure.read(key: _keyYnabToken);
    return AppSettings(
      ynabToken: token?.trim(),
      ynabBudgetId: _prefs.getString(_keyYnabBudgetId),
      ledgerOutputPath: _prefs.getString(_keyLedgerOutputPath),
    );
  }

  Future<void> setYnabToken(String token) =>
      _secure.write(key: _keyYnabToken, value: token.trim());

  Future<void> clearYnabToken() =>
      _secure.delete(key: _keyYnabToken);

  Future<void> setYnabBudgetId(String budgetId) =>
      _prefs.setString(_keyYnabBudgetId, budgetId);

  Future<void> setLedgerOutputPath(String path) =>
      _prefs.setString(_keyLedgerOutputPath, path);
}

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────

/// Initialized before runApp — see main.dart.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError(
    'settingsServiceProvider must be overridden before use. '
    'See main.dart for initialization.',
  );
});

/// Provides the current settings as an async value.
/// Use [settingsProvider.notifier] to trigger a reload after saving.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier(ref.watch(settingsServiceProvider));
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.load());
  }

  Future<void> setYnabToken(String token) async {
    await _service.setYnabToken(token);
    await load();
  }

  Future<void> clearYnabToken() async {
    await _service.clearYnabToken();
    await load();
  }

  Future<void> setYnabBudgetId(String budgetId) async {
    await _service.setYnabBudgetId(budgetId);
    await load();
  }

  Future<void> setLedgerOutputPath(String path) async {
    await _service.setLedgerOutputPath(path);
    await load();
  }
}
