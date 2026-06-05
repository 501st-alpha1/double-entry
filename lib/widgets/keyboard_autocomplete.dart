import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper around [Autocomplete] that adds keyboard navigation:
/// - Tab or Enter selects the first option and closes the menu
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

  // Used to programmatically dismiss the options overlay.
  final _optionsController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      displayStringForOption: widget.displayStringForOption,
      initialValue: widget.initialValue,
      optionsBuilder: (value) async {
        final options = await widget.optionsBuilder(value);
        if (mounted) {
          setState(() => _lastOptions = options);
        }
        return options;
      },
      onSelected: (option) {
        setState(() => _lastOptions = const []);
        widget.onSelected(option);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Focus(
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;

            final isTab = event.logicalKey == LogicalKeyboardKey.tab;
            final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter;

            if ((isTab || isEnter) && _lastOptions.isNotEmpty) {
              // Select the first option
              final selected = _lastOptions.first;

              // Update the text field to show the selected value
              controller.text = widget.displayStringForOption(selected);
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length,
              );

              // Fire onSelected and clear options
              widget.onSelected(selected);
              setState(() => _lastOptions = const []);

              if (isTab) {
                // Move focus to next field
                focusNode.nextFocus();
              }

              // Handled — don't propagate so the Tab doesn't also
              // move focus a second time via the normal traversal.
              return KeyEventResult.handled;
            }

            return KeyEventResult.ignored;
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
