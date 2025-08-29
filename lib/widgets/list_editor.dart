import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/router/routes.dart';

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
            final input = textEditingValue.text.trim();
            if (input.isEmpty) return const Iterable<String>.empty();

            final lowerInput = input.toLowerCase();

            // grab all existing tags that contain the input
            // ignore case then sort them
            final filtered = allItems
                .where((t) => t.toLowerCase().contains(lowerInput))
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

            // if there's no exact case-insensitive match
            // prepend the raw input as “new tag”
            if (!filtered.any((t) => t.toLowerCase() == lowerInput)) {
              return [input, ...filtered];
            }

            // otherwise just return the existing matches
            return filtered;
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
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: TextField(
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
              ),
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
              onPressed: () {
                if (name == "author") {
                  Navigator.pushNamed(
                    context,
                    Routes.author,
                    // pass as a map
                    arguments: {'author': item, 'allAuthors': allItems},
                  );
                } else if (name == "tag") {
                  Navigator.pushNamed(
                    context,
                    Routes.tag,
                    // pass as a map
                    arguments: {'tag': item, 'allTags': allItems},
                  );
                } else if (name == "character") {
                  Navigator.pushNamed(
                    context,
                    Routes.character,
                    // pass as a map
                    arguments: {'character': item, 'allCharacters': allItems},
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
