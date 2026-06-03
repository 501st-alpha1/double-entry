import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/transaction/transaction_screen.dart';
import '../screens/transaction/transaction_detail_screen.dart';

// Route path constants — use these everywhere instead of raw strings.
class Routes {
  static const home = '/';
  static const newTransaction = '/transaction/new';
  static const editTransaction = '/transaction/:id';

  static String editTransactionPath(String id) => '/transaction/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.newTransaction,
        builder: (context, state) => const TransactionScreen(),
      ),
      GoRoute(
        path: Routes.editTransaction,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: id);
        },
      ),
    ],
    // Simple error page for unmatched routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
