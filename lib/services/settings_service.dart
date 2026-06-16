import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/dao_providers.dart';

// ─────────────────────────────────────────────
// Keys
// ─────────────────────────────────────────────

const _keyYnabToken = 'ynab_token';
const _keyYnabBudgetId = 'ynab_budget_id';
const _keyYnabBudgetName = 'ynab_budget_name';
const _keyLedgerOutputPath = 'ledger_output_path';
const _keyBudgetMovePayee = 'budget_move_payee';
const _keyGitRemoteUrl = 'git_remote_url';
const _keyGitBranch = 'git_branch';
const _keyGitTargetFile = 'git_target_file';
const _keyGitPrivateKey = 'git_private_key'; // stored in secure storage
const _keyGitPublicKey = 'git_public_key';   // non-sensitive, prefs

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
  final String? budgetMovePayee;

  /// Git remote URL, e.g. git@gitea.example.com:user/ledger.git
  final String? gitRemoteUrl;

  /// Git branch the app manages, e.g. mobile-sync
  final String? gitBranch;

  /// Path to the ledger file within the repo, e.g. mobile.ledger
  final String? gitTargetFile;

  /// The generated public key (OpenSSH format), for display/copying to Gitea.
  final String? gitPublicKey;

  /// Whether the private key has been generated (key itself is in secure storage).
  final bool gitPrivateKeyExists;

  const AppSettings({
    this.ynabToken,
    this.ynabBudgetId,
    this.ynabBudgetName,
    this.ledgerOutputPath,
    this.budgetMovePayee,
    this.gitRemoteUrl,
    this.gitBranch,
    this.gitTargetFile,
    this.gitPublicKey,
    this.gitPrivateKeyExists = false,
  });

  bool get isYnabConfigured => ynabToken != null && ynabBudgetId != null;
  bool get isLedgerConfigured => ledgerOutputPath != null;
  bool get isGitConfigured =>
      gitRemoteUrl != null && gitPrivateKeyExists;

  /// Effective branch name — uses stored value or default.
  String get effectiveGitBranch => gitBranch ?? 'mobile-sync';

  /// Effective target file — uses stored value or default.
  String get effectiveGitTargetFile => gitTargetFile ?? 'mobile.ledger';
  bool get isFullyConfigured => isYnabConfigured && isLedgerConfigured;

  AppSettings copyWith({
    String? ynabToken,
    String? ynabBudgetId,
    String? ynabBudgetName,
    String? ledgerOutputPath,
    String? budgetMovePayee,
    String? gitRemoteUrl,
    String? gitBranch,
    String? gitTargetFile,
    String? gitPublicKey,
    bool? gitPrivateKeyExists,
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
      gitRemoteUrl: gitRemoteUrl ?? this.gitRemoteUrl,
      gitBranch: gitBranch ?? this.gitBranch,
      gitTargetFile: gitTargetFile ?? this.gitTargetFile,
      gitPublicKey: gitPublicKey ?? this.gitPublicKey,
      gitPrivateKeyExists: gitPrivateKeyExists ?? this.gitPrivateKeyExists,
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
    final privateKey = await _secure.read(key: _keyGitPrivateKey);
    return AppSettings(
      ynabToken: token?.trim(),
      ynabBudgetId: _prefs.getString(_keyYnabBudgetId),
      ynabBudgetName: _prefs.getString(_keyYnabBudgetName),
      ledgerOutputPath: _prefs.getString(_keyLedgerOutputPath),
      budgetMovePayee: _prefs.getString(_keyBudgetMovePayee),
      gitRemoteUrl: _prefs.getString(_keyGitRemoteUrl),
      gitBranch: _prefs.getString(_keyGitBranch),
      gitTargetFile: _prefs.getString(_keyGitTargetFile),
      gitPublicKey: _prefs.getString(_keyGitPublicKey),
      gitPrivateKeyExists: privateKey != null,
    );
  }

  Future<String?> loadGitPrivateKey() =>
      _secure.read(key: _keyGitPrivateKey);

  Future<void> saveGitKeyPair({
    required String privateKeyPem,
    required String publicKeyOpenSsh,
  }) async {
    await _secure.write(key: _keyGitPrivateKey, value: privateKeyPem);
    await _prefs.setString(_keyGitPublicKey, publicKeyOpenSsh);
  }

  Future<void> setGitRemoteUrl(String url) =>
      _prefs.setString(_keyGitRemoteUrl, url);

  Future<void> setGitBranch(String branch) =>
      _prefs.setString(_keyGitBranch, branch);

  Future<void> setGitTargetFile(String file) =>
      _prefs.setString(_keyGitTargetFile, file);

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
  return SettingsNotifier(ref.watch(settingsServiceProvider), ref);
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsService _service;
  final Ref _ref;

  SettingsNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  /// Constructs with a pre-loaded value so the provider never starts loading.
  SettingsNotifier.withInitial(this._service, this._ref, AppSettings initial)
      : super(AsyncValue.data(initial));

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
    // If the budget is changing, clear all account YNAB links since they
    // are budget-specific and will no longer be valid.
    final currentId = state.valueOrNull?.ynabBudgetId;
    if (currentId != null && currentId != budgetId) {
      await _ref.read(accountDaoProvider).clearAllYnabLinks();
    }
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

  Future<void> saveGitKeyPair({
    required String privateKeyPem,
    required String publicKeyOpenSsh,
  }) async {
    await _service.saveGitKeyPair(
      privateKeyPem: privateKeyPem,
      publicKeyOpenSsh: publicKeyOpenSsh,
    );
    await load();
  }

  Future<void> setGitRemoteUrl(String url) async {
    await _service.setGitRemoteUrl(url);
    await load();
  }

  Future<void> setGitBranch(String branch) async {
    await _service.setGitBranch(branch);
    await load();
  }

  Future<void> setGitTargetFile(String file) async {
    await _service.setGitTargetFile(file);
    await load();
  }

  Future<String?> loadGitPrivateKey() => _service.loadGitPrivateKey();
}
