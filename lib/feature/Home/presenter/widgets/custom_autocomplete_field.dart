import 'package:flutter/material.dart';

class CustomAutocompleteField extends StatelessWidget {
  final String label;
  final Future<List<String>> Function() optionsBuilder;
  final void Function(String) onSelected;
  final TextEditingController controller;

  const CustomAutocompleteField({
    super.key,
    required this.label,
    required this.optionsBuilder,
    required this.onSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          final options = await optionsBuilder();
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return options.where((String option) {
            return option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: onSelected,
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          // Sync the internal controller with the external one
          if (fieldTextEditingController.text != controller.text) {
            fieldTextEditingController.text = controller.text;
          }
          
          // Listen to changes to update the external controller
          fieldTextEditingController.addListener(() {
             controller.text = fieldTextEditingController.text;
          });

          return TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          );
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: constraints.maxWidth,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      borderRadius: index == 0 
                          ? const BorderRadius.vertical(top: Radius.circular(12))
                          : index == options.length - 1 
                              ? const BorderRadius.vertical(bottom: Radius.circular(12))
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(option),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
