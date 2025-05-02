// tag_editor.dart

import 'package:flutter/material.dart';

class TagEditor extends StatelessWidget {
  final List<String> tags;
  final List<String> allTags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final int flex; // this modifies how much room tags are taking

  const TagEditor({
    Key? key,
    required this.tags,
    required this.allTags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.flex = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              final input = textEditingValue.text;
              if (input.isEmpty) return const Iterable<String>.empty();

              final lowerInput = input.toLowerCase();

              // find all existing tags matching the input
              final matches = allTags
                  .where((t) => t.toLowerCase().contains(lowerInput))
                  .toList();

              // if the exact tag isn't already in your list, offer it first
              if (!allTags.any((t) => t.toLowerCase() == lowerInput)) {
                matches.insert(0, input);
              }

              return matches;
            },

            onSelected: (tag) {
              onTagAdded(tag);
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
                decoration: const InputDecoration(
                  labelText: 'Add tag',
                  border: OutlineInputBorder(),
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

          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: tags.map((tag) {
              return InputChip(
                label: Text(tag),
                onDeleted: () => onTagRemoved(tag),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
