import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';
import '../../widgets/ynab_mapping_sheet.dart';

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────

final _accountSearchProvider = StateProvider<String>((ref) => '');

final _accountsProvider = StreamProvider<List<AccountRow>>((ref) {
  final query = ref.watch(_accountSearchProvider);
  return ref.watch(accountDaoProvider).watchSearch(query);
});

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(_accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts & Categories')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search accounts...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  ref.read(_accountSearchProvider.notifier).state = v,
            ),
          ),

          // List
          Expanded(
            child: accountsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (accounts) => accounts.isEmpty
                  ? const Center(child: Text('No accounts found.'))
                  : ListView.separated(
                      itemCount: accounts.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _AccountTile(account: accounts[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Account tile
// ─────────────────────────────────────────────

class _AccountTile extends ConsumerWidget {
  final AccountRow account;
  const _AccountTile({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLinked = account.ynabId != null;

    return Dismissible(
      key: ValueKey(account.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          ref.read(accountDaoProvider).delete(account.id),
      child: ListTile(
        title: Text(account.ledgerName),
        subtitle: isLinked
            ? Text('YNAB: ${account.ynabName}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12))
            : const Text('Not linked to YNAB',
                style: TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isLinked)
              IconButton(
                icon: const Icon(Icons.link, size: 20),
                tooltip: 'Link to YNAB',
                onPressed: () =>
                    showYnabMappingSheet(context, ref, account),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Rename',
              onPressed: () => _showRenameDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: Text(
          'Delete "${account.ledgerName}"? This may affect existing '
          'transactions that reference this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final controller =
        TextEditingController(text: account.ledgerName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Account'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Ledger name'),
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != account.ledgerName) {
                await ref
                    .read(accountDaoProvider)
                    .rename(account.id, name);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
