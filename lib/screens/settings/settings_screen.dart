import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../repositories/ynab/ynab_client.dart';
import '../../routing/router.dart';
import '../../services/settings_service.dart';
import '../../services/ssh_key_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading settings: $e')),
        data: (settings) => ListView(
          children: [
            // ── YNAB ──────────────────────────────────────
            const _SectionHeader(title: 'YNAB'),
            _YnabTokenTile(token: settings.ynabToken),
            _YnabBudgetTile(
              token: settings.ynabToken,
              budgetId: settings.ynabBudgetId,
              budgetName: settings.ynabBudgetName,
            ),

            // ── Ledger ────────────────────────────────────
            const _SectionHeader(title: 'Ledger'),
            _LedgerPathTile(path: settings.ledgerOutputPath),

            // ── Transactions ──────────────────────────────
            const _SectionHeader(title: 'Transactions'),
            _BudgetMovePayeeTile(payee: settings.budgetMovePayee),

            // ── Data management ───────────────────────────
            const _SectionHeader(title: 'Data'),
            ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: const Text('Accounts & Categories'),
              subtitle: const Text('Rename, delete, or link to YNAB'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.accounts),
            ),
            ListTile(
              leading: const Icon(Icons.store_outlined),
              title: const Text('Payees'),
              subtitle: const Text('Rename or delete payees'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.payees),
            ),

            // ── Git (Android only) ────────────────────────
            if (!Platform.isLinux &&
                !Platform.isMacOS &&
                !Platform.isWindows) ...[
              const _SectionHeader(title: 'Git Sync (Android)'),
              _GitRemoteUrlTile(url: settings.gitRemoteUrl),
              _GitBranchTile(branch: settings.gitBranch),
              _GitTargetFileTile(file: settings.gitTargetFile),
              _GitSshKeyTile(settings: settings),
            ],

            // ── Status ────────────────────────────────────
            const _SectionHeader(title: 'Status'),
            ListTile(
              leading: Icon(
                settings.isFullyConfigured
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: settings.isFullyConfigured
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
              title: Text(settings.isFullyConfigured
                  ? 'Ready to sync'
                  : 'Setup incomplete'),
              subtitle: !settings.isFullyConfigured
                  ? Text(_missingItems(settings))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _missingItems(AppSettings settings) {
    final missing = <String>[];
    if (settings.ynabToken == null) missing.add('YNAB token');
    if (settings.ynabBudgetId == null) missing.add('YNAB budget');
    if (settings.ledgerOutputPath == null) missing.add('Ledger output path');
    return 'Missing: ${missing.join(', ')}';
  }
}

// ─────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YNAB token tile
// ─────────────────────────────────────────────

class _YnabTokenTile extends ConsumerWidget {
  final String? token;
  const _YnabTokenTile({required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.key_outlined),
      title: const Text('Personal Access Token'),
      subtitle: Text(token != null ? '••••••••${token!.substring(token!.length - 4)}' : 'Not set'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showTokenDialog(context, ref),
    );
  }

  Future<void> _showTokenDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: token);
    final notifier = ref.read(settingsProvider.notifier);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YNAB Access Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate a token at app.ynab.com → Account Settings → Developer Settings.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Token',
                hintText: 'Paste your token here',
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          if (token != null)
            TextButton(
              onPressed: () async {
                await notifier.clearYnabToken();
                if (context.mounted) Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await notifier.setYnabToken(value);
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

// ─────────────────────────────────────────────
// YNAB budget tile
// ─────────────────────────────────────────────

class _YnabBudgetTile extends ConsumerWidget {
  final String? token;
  final String? budgetId;
  final String? budgetName;

  const _YnabBudgetTile({
    required this.token,
    required this.budgetId,
    required this.budgetName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = token != null;
    final subtitle = budgetName != null
        ? budgetName!
        : (budgetId != null ? budgetId! : 'Not selected');

    return ListTile(
      leading: const Icon(Icons.account_balance_wallet_outlined),
      title: const Text('Budget'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      enabled: isEnabled,
      onTap: isEnabled ? () => _showBudgetPicker(context, ref) : null,
    );
  }

  Future<void> _showBudgetPicker(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(settingsProvider.notifier);
    final client = ref.read(ynabClientProvider);
    if (client == null) return;

    // Show loading dialog while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading budgets...'),
          ],
        ),
      ),
    );

    try {
      final budgets = await client.getBudgets();
      if (!context.mounted) return;
      Navigator.pop(context); // dismiss loading

      if (budgets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No budgets found for this token.')),
        );
        return;
      }

      // If only one budget, select it automatically
      if (budgets.length == 1) {
        await notifier.setYnabBudget(budgets.first.id, budgets.first.name);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: ${budgets.first.name}')),
          );
        }
        return;
      }

      // Multiple budgets — show picker
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Budget'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return ListTile(
                  title: Text(budget.name),
                  subtitle: Text(budget.id),
                  selected: budget.id == budgetId,
                  onTap: () async {
                    await notifier.setYnabBudget(budget.id, budget.name);
                    if (context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch budgets: $e')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────
// Budget move payee tile
// ─────────────────────────────────────────────

class _BudgetMovePayeeTile extends ConsumerWidget {
  final String? payee;
  const _BudgetMovePayeeTile({required this.payee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.swap_horiz_outlined),
      title: const Text('Budget Move Payee'),
      subtitle: Text(payee ?? 'Not set — payee field will be shown'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDialog(context, ref),
    );
  }

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: payee);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Budget Move Payee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This payee is used automatically for budget move transactions, '
              'hiding the payee field from the form.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Payee name',
                hintText: 'e.g. Your Name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await ref
                    .read(settingsProvider.notifier)
                    .setBudgetMovePayee(value);
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

class _LedgerPathTile extends ConsumerWidget {
  final String? path;
  const _LedgerPathTile({required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: const Text('Output File Path'),
      subtitle: Text(path ?? 'Not set'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Platform.isAndroid
          ? _showAndroidPicker(context, ref)
          : _showDesktopDialog(context, ref),
    );
  }

  /// Android: list existing *.ledger files in app docs dir + option to create new.
  Future<void> _showAndroidPicker(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(settingsProvider.notifier);
    final docsDir = await getApplicationDocumentsDirectory();

    // Find existing .ledger files
    final existing = docsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ledger'))
        .map((f) => p.basename(f.path))
        .toList()
      ..sort();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) =>
          _AndroidLedgerPickerDialog(existing: existing, notifier: notifier),
    );
  }

  /// Desktop: plain text input (path can be anywhere).
  Future<void> _showDesktopDialog(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(settingsProvider.notifier);
    final controller = TextEditingController(text: path);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ledger Output Path'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full path to the Ledger file the app should append to, '
              'e.g. ~/Documents/mobile.ledger',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'File path',
                hintText: '~/Documents/mobile.ledger',
              ),
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await notifier.setLedgerOutputPath(value);
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

class _AndroidLedgerPickerDialog extends StatefulWidget {
  final List<String> existing;
  final SettingsNotifier notifier;

  const _AndroidLedgerPickerDialog({
    required this.existing,
    required this.notifier,
  });

  @override
  State<_AndroidLedgerPickerDialog> createState() =>
      _AndroidLedgerPickerDialogState();
}

class _AndroidLedgerPickerDialogState
    extends State<_AndroidLedgerPickerDialog> {
  bool _showNewField = false;
  final _newNameController = TextEditingController(text: 'mobile.ledger');

  @override
  void dispose() {
    _newNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ledger Output File'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.existing.isNotEmpty) ...[
              Text('Existing files:',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              ...widget.existing.map((name) => ListTile(
                    dense: true,
                    title: Text(name),
                    leading: const Icon(Icons.description_outlined),
                    onTap: () async {
                      await widget.notifier.setLedgerOutputPath(name);
                      if (context.mounted) Navigator.pop(context);
                    },
                  )),
              const Divider(),
            ],
            if (!_showNewField)
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create new file'),
                onPressed: () => setState(() => _showNewField = true),
              )
            else ...[
              Text('New file name:',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              TextField(
                controller: _newNameController,
                decoration: const InputDecoration(
                  hintText: 'mobile.ledger',
                  suffixText: '.ledger',
                ),
                autocorrect: false,
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        setState(() => _showNewField = false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      var name = _newNameController.text.trim();
                      if (name.isEmpty) return;
                      if (!name.endsWith('.ledger')) name = '$name.ledger';
                      await widget.notifier.setLedgerOutputPath(name);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Git settings tiles
// ─────────────────────────────────────────────

class _GitRemoteUrlTile extends ConsumerWidget {
  final String? url;
  const _GitRemoteUrlTile({required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: const Text('Remote URL'),
      subtitle: Text(url ?? 'Not set'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDialog(context, ref),
    );
  }

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: url);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Git Remote URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SSH remote URL for your Gitea repository.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Remote URL',
                hintText: 'git@gitea.example.com:user/ledger.git',
              ),
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await ref.read(settingsProvider.notifier).setGitRemoteUrl(value);
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

class _GitBranchTile extends ConsumerWidget {
  final String? branch;
  const _GitBranchTile({required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.alt_route_outlined),
      title: const Text('Branch'),
      subtitle: Text(branch ?? 'mobile-sync (default)'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDialog(context, ref),
    );
  }

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: branch ?? 'mobile-sync');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Git Branch'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Branch name',
            hintText: 'mobile-sync',
          ),
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await ref.read(settingsProvider.notifier).setGitBranch(value);
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

class _GitTargetFileTile extends ConsumerWidget {
  final String? file;
  const _GitTargetFileTile({required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('Target File'),
      subtitle: Text(file ?? 'mobile.ledger (default)'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDialog(context, ref),
    );
  }

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: file ?? 'mobile.ledger');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Target File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File path in repo',
            hintText: 'mobile.ledger',
          ),
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await ref.read(settingsProvider.notifier).setGitTargetFile(value);
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

class _GitSshKeyTile extends ConsumerWidget {
  final AppSettings settings;
  const _GitSshKeyTile({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasKey = settings.gitPrivateKeyExists;
    return ListTile(
      leading: Icon(
        Icons.vpn_key_outlined,
        color: hasKey ? Theme.of(context).colorScheme.primary : null,
      ),
      title: const Text('SSH Key'),
      subtitle: Text(hasKey
          ? 'Key generated — add public key to Gitea'
          : 'Not generated'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showKeyDialog(context, ref),
    );
  }

  Future<void> _showKeyDialog(BuildContext context, WidgetRef ref) async {
    if (!settings.gitPrivateKeyExists) {
      // Generate a new key pair
      await showDialog(
        context: context,
        builder: (context) => _GenerateKeyDialog(),
      );
    } else {
      // Show public key for copying
      await showDialog(
        context: context,
        builder: (context) => _ShowPublicKeyDialog(
          publicKey: settings.gitPublicKey ?? '',
        ),
      );
    }
  }
}

class _GenerateKeyDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GenerateKeyDialog> createState() =>
      _GenerateKeyDialogState();
}

class _GenerateKeyDialogState extends ConsumerState<_GenerateKeyDialog> {
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate SSH Key'),
      content: _generating
          ? const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Generating key pair...'),
              ],
            )
          : const Text(
              'Generate a new Ed25519 SSH key pair. '
              'You will then add the public key to your Gitea account.',
            ),
      actions: [
        TextButton(
          onPressed: _generating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _generating ? null : () => _generate(context),
          child: const Text('Generate'),
        ),
      ],
    );
  }

  Future<void> _generate(BuildContext context) async {
    setState(() => _generating = true);
    try {
      final keyPair = await SshKeyService.generateKeyPair();
      await ref.read(settingsProvider.notifier).saveGitKeyPair(
            privateKeyPem: keyPair.privateKeyPem,
            publicKeyOpenSsh: keyPair.publicKeyOpenSsh,
          );
      if (context.mounted) {
        Navigator.pop(context);
        await showDialog(
          context: context,
          builder: (_) => _ShowPublicKeyDialog(
              publicKey: keyPair.publicKeyOpenSsh),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate key: $e')),
        );
      }
    }
  }
}

class _ShowPublicKeyDialog extends StatelessWidget {
  final String publicKey;
  const _ShowPublicKeyDialog({required this.publicKey});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SSH Public Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add this public key to your Gitea account under '
            'Settings → SSH/GPG Keys.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              publicKey,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
