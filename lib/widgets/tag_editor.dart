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
              // don't show options until something is typed
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              final input = textEditingValue.text.toLowerCase();
              return allTags.where((a) => a.toLowerCase().contains(input));
            },
            onSelected: onTagAdded,
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
                  // autocomplete logic
                  onFieldSubmitted();
                  // clear what user typed
                  textEditingController.clear();
                  // keep focus
                  focusNode.requestFocus();
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: tags.map((tag) {
                return InputChip(
                  label: Text(tag),
                  onDeleted: () => onTagRemoved(tag),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
