import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao_providers.dart';
import '../database/database.dart';
import '../repositories/ynab/ynab_reference_data.dart';
import '../repositories/ynab/ynab_models.dart';

/// Shows a bottom sheet to map a local [AccountRow] to a YNAB account
/// or category. Updates the account's ynabId in the DB on selection.
///
/// Returns true if a mapping was made, false if dismissed.
Future<bool> showYnabMappingSheet(
  BuildContext context,
  WidgetRef ref,
  AccountRow account,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _YnabMappingSheet(account: account),
  );
  return result ?? false;
}

class _YnabMappingSheet extends ConsumerWidget {
  final AccountRow account;

  const _YnabMappingSheet({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refDataAsync = ref.watch(ynabReferenceDataProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link to YNAB',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.ledgerName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),

            // Content
            Expanded(
              child: refDataAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Failed to load YNAB data: $e'),
                ),
                data: (refData) {
                  if (refData == null) {
                    return const Center(
                      child: Text('YNAB not configured.'),
                    );
                  }
                  return _MappingList(
                    account: account,
                    refData: refData,
                    scrollController: scrollController,
                    ref: ref,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MappingList extends StatelessWidget {
  final AccountRow account;
  final YnabReferenceData refData;
  final ScrollController scrollController;
  final WidgetRef ref;

  const _MappingList({
    required this.account,
    required this.refData,
    required this.scrollController,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final categoriesByGroup = refData.categoriesByGroup;

    return ListView(
      controller: scrollController,
      children: [
        // ── Accounts section ───────────────────
        _SectionHeader(title: 'Accounts (${refData.activeAccounts.length})'),
        ...refData.activeAccounts.map((a) => ListTile(
              title: Text(a.name),
              onTap: () => _save(context, ynabId: a.id, ynabName: a.name),
            )),

        // ── Categories section ─────────────────
        _SectionHeader(title: 'Categories'),
        ...categoriesByGroup.entries.expand((entry) => [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              ...entry.value.map((cat) => ListTile(
                    title: Text(cat.name),
                    onTap: () =>
                        _save(context, ynabId: cat.id, ynabName: cat.name),
                  )),
            ]),

        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _save(
    BuildContext context, {
    required String ynabId,
    required String ynabName,
  }) async {
    await ref.read(accountDaoProvider).upsert(
          AccountsCompanion(
            id: Value(account.id),
            ledgerName: Value(account.ledgerName),
            ynabId: Value(ynabId),
            ynabName: Value(ynabName),
          ),
        );
    if (context.mounted) Navigator.pop(context, true);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
