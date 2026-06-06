import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
import '../../widgets/ynab_mapping_sheet.dart';

class UnlinkedAccountsScreen extends ConsumerWidget {
  const UnlinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlinkedAsync = ref.watch(_unlinkedAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Accounts to YNAB'),
      ),
      body: unlinkedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) => accounts.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: Colors.green),
                    SizedBox(height: 12),
                    Text('All accounts are linked to YNAB.'),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return ListTile(
                    leading: const Icon(Icons.link_off),
                    title: Text(account.ledgerName),
                    subtitle: const Text('Tap to link to YNAB'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        showYnabMappingSheet(context, ref, account),
                  );
                },
              ),
      ),
    );
  }
}

final _unlinkedAccountsProvider =
    StreamProvider<List<AccountRow>>((ref) {
  return ref
      .watch(accountDaoProvider)
      .watchUnlinkedAccountsInPendingTransactions();
});
