import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao_providers.dart';
import '../models/models.dart';

/// Typeahead field for account/category selection.
/// Searches accounts by partial match on ledgerName or ynabName.
class AccountTypeahead extends ConsumerWidget {
  final String initialValue;
  final ValueChanged<Account> onSelected;
  final String labelText;

  const AccountTypeahead({
    super.key,
    required this.initialValue,
    required this.onSelected,
    this.labelText = 'Account',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountDao = ref.read(accountDaoProvider);

    return Autocomplete<Account>(
      initialValue: TextEditingValue(text: initialValue),
      displayStringForOption: (a) => a.displayName,
      optionsBuilder: (textEditingValue) async {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return [];
        return accountDao.search(query);
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: 'Search accounts',
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final account = options.elementAt(index);
                  return ListTile(
                    title: Text(account.displayName),
                    subtitle: account.ynabName != null
                        ? Text(
                            account.ledgerName,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    onTap: () => onSelected(account),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
