import 'package:flutter/material.dart';

import '../resources/colors.dart';

/// CustomMaterialDropdown is a wrapper for Flutter's default DropdownButtonFormField.
///
/// This widget displays a label (optional) and a dropdown menu.
/// It allows customization of item appearance, selected item appearance, expansion,
/// placeholder text (hint), item height, and supports a callback when a value is selected.
class CustomMaterialDropdown<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T> onSelected;
  final String? label;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final T? value;
  final bool isExpanded;
  final String? hint;
  final double? itemHeight;
  final Widget Function(BuildContext context, T item)? selectedItemBuilder;

  const CustomMaterialDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.label,
    this.itemBuilder,
    this.isExpanded = true,
    this.hint,
    this.itemHeight,
    this.selectedItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<T?>(
            value: items.contains(value) ? value : null,
            isExpanded: isExpanded,
            hint: hint != null ? Text(hint!) : null,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            menuMaxHeight: 700,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            selectedItemBuilder:
                selectedItemBuilder != null
                    ? (context) => [
                      for (final item in items)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: selectedItemBuilder!(context, item),
                        ),
                    ]
                    : null,
            items:
                items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        alignment: Alignment.centerLeft,
                        child: itemBuilder?.call(context, item) ?? Text(item.toString()),
                      ),
                    )
                    .toList(),
            onChanged: (mode) {
              if (mode != null) onSelected(mode);
            },
          ),
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T> onSelected;
  final String? label;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final T? value;
  final bool isExpanded;
  final double itemHeight;
  final double dropdownMaxHeight;
  final String? hint;
  final Widget Function(BuildContext context, T item)? selectedItemBuilder;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.label,
    this.itemBuilder,
    this.isExpanded = true,
    this.itemHeight = 36,
    this.dropdownMaxHeight = 500,
    this.selectedItemBuilder,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: items.contains(value) ? value : null,
                isExpanded: isExpanded,
                icon: const Icon(Icons.expand_more_rounded),
                style: theme.textTheme.bodyLarge,
                hint: hint != null ? Text(hint!) : null,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: theme.colorScheme.surface,
                menuMaxHeight: dropdownMaxHeight,
                items:
                    items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        alignment: Alignment.centerLeft,
                        child: itemBuilder?.call(context, item) ?? Text(item.toString()),
                      );
                    }).toList(),
                selectedItemBuilder:
                    selectedItemBuilder != null
                        ? (context) =>
                            items
                                .map(
                                  (item) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: selectedItemBuilder!(context, item),
                                  ),
                                )
                                .toList()
                        : null,
                onChanged: (selected) {
                  if (selected != null) onSelected(selected);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const SearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        // color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search',
          filled: true,
          prefixIcon: const Icon(Icons.search_rounded),
          fillColor: AppColors.borderColor.withValues(alpha: 0.25),
          hintStyle: const TextStyle(fontSize: 13, height: 1.2),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
