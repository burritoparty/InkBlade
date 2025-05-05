import 'package:flutter/material.dart';

class ListEditor extends StatelessWidget {
  final String name;
  final List<String> item;
  final List<String> allItems;
  final ValueChanged<String> onAdded;
  final ValueChanged<String> onRemoved;
  final int flex; // this modifies how much room items are taking

  const ListEditor({
    Key? key,
    required this.name,
    required this.item,
    required this.allItems,
    required this.onAdded,
    required this.onRemoved,
    this.flex = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            final input = textEditingValue.text;
            if (input.isEmpty) return const Iterable<String>.empty();

            final lowerInput = input.toLowerCase();

            // find all existing items matching the input
            final matches = allItems
                .where((t) => t.toLowerCase().contains(lowerInput))
                .toList();

            // if the exact item isn't already in your list, offer it first
            if (!allItems.any((t) => t.toLowerCase() == lowerInput)) {
              matches.insert(0, input);
            }

            return matches;
          },
          onSelected: (item) {
            onAdded(item);
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Add $name',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                // pick the top option (which is your raw input if new)
                onFieldSubmitted();
                // clear the text field and keep focus
                textEditingController.clear();
                focusNode.requestFocus();
              },
            );
          },
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: item.map((item) {
            return InputChip(
              label: Text(item),
              onDeleted: () => onRemoved(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
