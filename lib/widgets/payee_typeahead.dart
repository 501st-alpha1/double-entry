import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao_providers.dart';
import '../models/models.dart';

/// Typeahead field for payee selection.
/// Searches existing payees by partial name match.
/// Allows entering a new payee name that doesn't exist yet.
class PayeeTypeahead extends ConsumerWidget {
  final String initialValue;

  /// Called when a payee is selected from suggestions, or when the field
  /// text changes. [payee] is null if the name doesn't match an existing payee.
  final void Function(Payee? payee, String name) onSelected;

  const PayeeTypeahead({
    super.key,
    required this.initialValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payeeDao = ref.read(payeeDaoProvider);

    return Autocomplete<Payee>(
      initialValue: TextEditingValue(text: initialValue),
      displayStringForOption: (p) => p.name,
      optionsBuilder: (textEditingValue) async {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return [];
        return payeeDao.search(query);
      },
      onSelected: (payee) => onSelected(payee, payee.name),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Payee',
            hintText: 'Search or enter new payee',
          ),
          onChanged: (value) => onSelected(null, value),
          textCapitalization: TextCapitalization.words,
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
                  final payee = options.elementAt(index);
                  return ListTile(
                    title: Text(payee.name),
                    onTap: () => onSelected(payee),
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
