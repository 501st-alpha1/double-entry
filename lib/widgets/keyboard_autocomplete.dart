import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper around [Autocomplete] that adds keyboard navigation:
/// - Tab or Enter selects the first (or highlighted) option and closes the menu
/// - After selection, Tab moves focus to the next field as normal
///
/// [T] is the option type. [displayStringForOption], [optionsBuilder], and
/// [onSelected] mirror the standard [Autocomplete] parameters.
/// [fieldViewBuilder] receives the same arguments as [Autocomplete.fieldViewBuilder].
class KeyboardAutocomplete<T extends Object> extends StatefulWidget {
  final String Function(T) displayStringForOption;
  final Future<Iterable<T>> Function(TextEditingValue) optionsBuilder;
  final void Function(T) onSelected;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) fieldViewBuilder;
  final TextEditingValue? initialValue;

  const KeyboardAutocomplete({
    super.key,
    required this.displayStringForOption,
    required this.optionsBuilder,
    required this.onSelected,
    required this.fieldViewBuilder,
    this.initialValue,
  });

  @override
  State<KeyboardAutocomplete<T>> createState() =>
      _KeyboardAutocompleteState<T>();
}

class _KeyboardAutocompleteState<T extends Object>
    extends State<KeyboardAutocomplete<T>> {
  // Holds the most recent options list so Tab/Enter can select from it.
  Iterable<T> _lastOptions = const [];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      displayStringForOption: widget.displayStringForOption,
      initialValue: widget.initialValue,
      optionsBuilder: (value) async {
        final options = await widget.optionsBuilder(value);
        _lastOptions = options;
        return options;
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return KeyboardListener(
          focusNode: FocusNode(skipTraversal: true),
          onKeyEvent: (event) {
            if (event is! KeyDownEvent) return;

            final isTab = event.logicalKey == LogicalKeyboardKey.tab;
            final isEnter =
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter;

            if ((isTab || isEnter) && _lastOptions.isNotEmpty) {
              // Select the first option
              final selected = _lastOptions.first;
              widget.onSelected(selected);

              // Update the text field to show the selected value
              controller.text = widget.displayStringForOption(selected);
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length,
              );

              // Clear options so the menu closes
              _lastOptions = const [];

              if (isTab) {
                // Move focus to next field
                focusNode.nextFocus();
              } else {
                // Enter just closes the menu, stays in field
                focusNode.requestFocus();
              }
            }
          },
          child: widget.fieldViewBuilder(
            context,
            controller,
            focusNode,
            onFieldSubmitted,
          ),
        );
      },
    );
  }
}
