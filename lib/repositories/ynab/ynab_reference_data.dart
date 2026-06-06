import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/settings_service.dart';
import 'ynab_client.dart';
import 'ynab_models.dart';

/// Holds YNAB accounts and categories fetched once per app session.
class YnabReferenceData {
  final List<YnabAccount> accounts;
  final List<YnabCategory> categories;

  const YnabReferenceData({
    required this.accounts,
    required this.categories,
  });

  /// All accounts that are on-budget and not closed.
  List<YnabAccount> get activeAccounts =>
      accounts.where((a) => a.onBudget && !a.closed).toList();

  /// All categories, grouped by group name.
  Map<String, List<YnabCategory>> get categoriesByGroup {
    final map = <String, List<YnabCategory>>{};
    for (final cat in categories) {
      map.putIfAbsent(cat.groupName, () => []).add(cat);
    }
    return map;
  }
}

/// Fetches and caches YNAB accounts + categories for the current budget.
/// Returns null if YNAB is not configured.
/// Automatically refetches if the budget ID changes.
final ynabReferenceDataProvider =
    FutureProvider<YnabReferenceData?>((ref) async {
  final client = ref.watch(ynabClientProvider);
  if (client == null) return null;

  // Watch settings so we re-fetch if budget changes
  final budgetId = ref.watch(ynabBudgetIdProvider);
  if (budgetId == null) return null;

  final results = await Future.wait([
    client.getAccounts(budgetId),
    client.getCategories(budgetId),
  ]);

  return YnabReferenceData(
    accounts: results[0] as List<YnabAccount>,
    categories: results[1] as List<YnabCategory>,
  );
});

/// Convenience provider for just the budget ID.
final ynabBudgetIdProvider = Provider<String?>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.ynabBudgetId;
});
