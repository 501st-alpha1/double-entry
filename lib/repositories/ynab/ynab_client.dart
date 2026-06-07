import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/settings_service.dart';
import 'ynab_models.dart';

const _baseUrl = 'https://api.ynab.com/v1';

/// Low-level YNAB API client built on Dio.
/// All methods throw [YnabApiException] on API errors.
class YnabClient {
  final Dio _dio;

  YnabClient(String token)
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    debugPrint('YnabClient: token length=${token.length}, '
        'starts="${token.substring(0, token.length.clamp(0, 8))}..."');
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ));
    }
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        final response = error.response;
        if (response != null) {
          final errorData = response.data?['error'] as Map<String, dynamic>?;
          throw YnabApiException(
            statusCode: response.statusCode ?? 0,
            errorId: errorData?['id'] as String? ?? 'unknown',
            detail: errorData?['detail'] as String? ?? error.message ?? 'Unknown error',
          );
        }
        handler.next(error);
      },
    ));
  }

  // ─────────────────────────────────────────────
  // Budgets / Plans
  // ─────────────────────────────────────────────

  /// Fetches all budgets (plans) accessible with the current token.
  Future<List<YnabBudget>> getBudgets() async {
    final response = await _dio.get('/budgets');
    final budgets = response.data['data']['budgets'] as List<dynamic>;
    return budgets
        .map((b) => YnabBudget.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────
  // Accounts
  // ─────────────────────────────────────────────

  /// Fetches all accounts for a budget.
  Future<List<YnabAccount>> getAccounts(String budgetId) async {
    final response = await _dio.get('/budgets/$budgetId/accounts');
    final accounts = response.data['data']['accounts'] as List<dynamic>;
    return accounts
        .map((a) => YnabAccount.fromJson(a as Map<String, dynamic>))
        .where((a) => !a.deleted)
        .toList();
  }

  // ─────────────────────────────────────────────
  // Categories
  // ─────────────────────────────────────────────

  /// Fetches all categories for a budget, flattened from their groups.
  Future<List<YnabCategory>> getCategories(String budgetId) async {
    final response = await _dio.get('/budgets/$budgetId/categories');
    final groups = response.data['data']['category_groups'] as List<dynamic>;

    final categories = <YnabCategory>[];
    for (final group in groups) {
      final groupName = group['name'] as String;
      final cats = group['categories'] as List<dynamic>;
      for (final cat in cats) {
        final category = YnabCategory.fromJson(
            cat as Map<String, dynamic>, groupName);
        if (!category.deleted) {
          categories.add(category);
        }
      }
    }
    return categories;
  }

  // ─────────────────────────────────────────────
  // Transactions
  // ─────────────────────────────────────────────

  /// Posts a batch of transactions to YNAB.
  /// Returns the list of created transaction IDs.
  Future<List<String>> postTransactions(
    String budgetId,
    List<YnabSaveTransaction> transactions,
  ) async {
    final response = await _dio.post(
      '/budgets/$budgetId/transactions',
      data: {
        'transactions': transactions.map((t) => t.toJson()).toList(),
      },
    );

    final transactionIds =
        response.data['data']['transaction_ids'] as List<dynamic>;
    return transactionIds.cast<String>();
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

/// Provides a [YnabClient] configured with the current token.
/// Returns null if no token is configured.
final ynabClientProvider = Provider<YnabClient?>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.whenOrNull(
    data: (settings) =>
        settings.ynabToken != null ? YnabClient(settings.ynabToken!) : null,
  );
});
