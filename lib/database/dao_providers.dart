import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'database_provider.dart';

/// Provides the AccountDao. Use this in screens and repositories
/// instead of accessing the database directly.
final accountDaoProvider = Provider<AccountDao>((ref) {
  return ref.watch(databaseProvider).accountDao;
});

/// Provides the PayeeDao.
final payeeDaoProvider = Provider<PayeeDao>((ref) {
  return ref.watch(databaseProvider).payeeDao;
});

/// Provides the TransactionDao.
final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return ref.watch(databaseProvider).transactionDao;
});
