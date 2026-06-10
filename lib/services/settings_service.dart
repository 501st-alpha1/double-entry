import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// Keys
// ─────────────────────────────────────────────

const _keyYnabToken = 'ynab_token';
const _keyYnabBudgetId = 'ynab_budget_id';
const _keyYnabBudgetName = 'ynab_budget_name';
const _keyLedgerOutputPath = 'ledger_output_path';
const _keyBudgetMovePayee = 'budget_move_payee';

// ─────────────────────────────────────────────
// Settings model
// ─────────────────────────────────────────────

/// Immutable snapshot of all app settings.
class AppSettings {
  /// YNAB personal access token. Null if not yet configured.
  final String? ynabToken;

  /// Selected YNAB budget ID. Null if not yet configured.
  final String? ynabBudgetId;

  /// Selected YNAB budget name, saved alongside the ID for display.
  final String? ynabBudgetName;

  /// Path to the Ledger output file, e.g. "/home/user/Documents/mobile.ledger"
  final String? ledgerOutputPath;

  /// The payee name used for budget move transactions.
  /// Defaults to null (user must enter manually if not set).
  final String? budgetMovePayee;

  const AppSettings({
    this.ynabToken,
    this.ynabBudgetId,
    this.ynabBudgetName,
    this.ledgerOutputPath,
    this.budgetMovePayee,
  });

  bool get isYnabConfigured => ynabToken != null && ynabBudgetId != null;
  bool get isLedgerConfigured => ledgerOutputPath != null;
  bool get isFullyConfigured => isYnabConfigured && isLedgerConfigured;

  AppSettings copyWith({
    String? ynabToken,
    String? ynabBudgetId,
    String? ynabBudgetName,
    String? ledgerOutputPath,
    String? budgetMovePayee,
    bool clearYnabToken = false,
    bool clearYnabBudgetId = false,
    bool clearLedgerOutputPath = false,
    bool clearBudgetMovePayee = false,
  }) {
    return AppSettings(
      ynabToken: clearYnabToken ? null : (ynabToken ?? this.ynabToken),
      ynabBudgetId:
          clearYnabBudgetId ? null : (ynabBudgetId ?? this.ynabBudgetId),
      ynabBudgetName: ynabBudgetName ?? this.ynabBudgetName,
      ledgerOutputPath: clearLedgerOutputPath
          ? null
          : (ledgerOutputPath ?? this.ledgerOutputPath),
      budgetMovePayee: clearBudgetMovePayee
          ? null
          : (budgetMovePayee ?? this.budgetMovePayee),
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
      ynabBudgetName: _prefs.getString(_keyYnabBudgetName),
      ledgerOutputPath: _prefs.getString(_keyLedgerOutputPath),
      budgetMovePayee: _prefs.getString(_keyBudgetMovePayee),
    );
  }

  Future<void> setYnabToken(String token) =>
      _secure.write(key: _keyYnabToken, value: token.trim());

  Future<void> clearYnabToken() =>
      _secure.delete(key: _keyYnabToken);

  Future<void> setYnabBudgetId(String budgetId) =>
      _prefs.setString(_keyYnabBudgetId, budgetId);

  Future<void> setYnabBudget(String budgetId, String budgetName) async {
    await _prefs.setString(_keyYnabBudgetId, budgetId);
    await _prefs.setString(_keyYnabBudgetName, budgetName);
  }

  Future<void> setLedgerOutputPath(String path) =>
      _prefs.setString(_keyLedgerOutputPath, path);

  Future<void> setBudgetMovePayee(String payee) =>
      _prefs.setString(_keyBudgetMovePayee, payee);
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

  Future<void> setYnabBudget(String budgetId, String budgetName) async {
    await _service.setYnabBudget(budgetId, budgetName);
    await load();
  }

  Future<void> setLedgerOutputPath(String path) async {
    await _service.setLedgerOutputPath(path);
    await load();
  }

  Future<void> setBudgetMovePayee(String payee) async {
    await _service.setBudgetMovePayee(payee);
    await load();
  }
}
