import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller; // controller for the search input
  final String hintText; // e.g., "books", "authors"
  final int count; // number of items to display

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    // format the number of items with commas
    final formatted = NumberFormat('#,###').format(count);

    // Build the search bar with formatted count
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        // Return the SearchBar widget
        return SearchBar(
          controller: controller,
          hintText: 'Search $formatted $hintText...',
          leading: const Icon(Icons.search),
          trailing: [
            if (hasText)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear',
                onPressed: controller.clear,
              ),
          ],
        );
      },
    );
  }
}
