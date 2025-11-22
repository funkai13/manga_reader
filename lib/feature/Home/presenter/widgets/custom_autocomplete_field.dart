import 'package:flutter/material.dart';
import 'package:manga_reader/core/theme/colors.dart';

class CustomAutocompleteField extends StatelessWidget {
  final String label;
  final Future<List<String>> Function() optionsBuilder;
  final void Function(String) onSelected;
  final TextEditingController controller;
  final IconData? icon;
  final double scale;
  final bool isDark;

  const CustomAutocompleteField({
    super.key,
    required this.label,
    required this.optionsBuilder,
    required this.onSelected,
    required this.controller,
    this.icon,
    this.scale = 1.0,
    this.isDark = false,
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
            style: TextStyle(
              fontSize: 16 * scale,
              color: isDark ? AppColorsDark.textColor : AppColorsLight.textColor,
            ),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null
                  ? Icon(
                      icon,
                      color: isDark
                          ? AppColorsDark.accentColor
                          : AppColorsLight.accentColor,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12 * scale),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12 * scale),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColorsDark.accentColor
                      : AppColorsLight.accentColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? AppColorsDark.cardColor
                  : AppColorsLight.cardColor.withValues(alpha: 0.5),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16 * scale, vertical: 14 * scale),
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
