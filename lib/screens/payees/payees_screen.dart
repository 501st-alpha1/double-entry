import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/dao_providers.dart';
import '../../database/database.dart';

bool get _isDesktop =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────

final _payeeSearchProvider = StateProvider<String>((ref) => '');

final _payeesProvider = StreamProvider<List<PayeeRow>>((ref) {
  final query = ref.watch(_payeeSearchProvider);
  return ref.watch(payeeDaoProvider).watchSearch(query);
});

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class PayeesScreen extends ConsumerWidget {
  const PayeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payeesAsync = ref.watch(_payeesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payees')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search payees...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  ref.read(_payeeSearchProvider.notifier).state = v,
            ),
          ),

          // List
          Expanded(
            child: payeesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (payees) => payees.isEmpty
                  ? const Center(child: Text('No payees found.'))
                  : ListView.separated(
                      itemCount: payees.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _PayeeTile(payee: payees[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Payee tile
// ─────────────────────────────────────────────

class _PayeeTile extends ConsumerWidget {
  final PayeeRow payee;
  const _PayeeTile({required this.payee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(payee.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          ref.read(payeeDaoProvider).deletePayee(payee.id),
      child: ListTile(
        title: Text(payee.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Rename',
              onPressed: () => _showRenameDialog(context, ref),
            ),
            if (_isDesktop)
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error),
                tooltip: 'Delete',
                onPressed: () async {
                  final confirmed = await _confirmDelete(context);
                  if (confirmed == true) {
                    await ref.read(payeeDaoProvider).deletePayee(payee.id);
                  }
                },
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
        title: const Text('Delete payee?'),
        content: Text(
          'Delete "${payee.name}"? Existing transactions referencing '
          'this payee will keep the name but lose the link.',
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

  Future<void> _showRenameDialog(
      BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: payee.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Payee'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != payee.name) {
                await ref.read(payeeDaoProvider).rename(payee.id, name);
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
