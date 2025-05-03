// character_editor.dart

import 'package:flutter/material.dart';

class CharacterEditor extends StatelessWidget {
  final List<String> characters;
  final List<String> allCharacters;
  final ValueChanged<String> onCharacterAdded;
  final ValueChanged<String> onCharacterRemoved;
  final int flex; // this modifies how much room characters are taking

  const CharacterEditor({
    Key? key,
    required this.characters,
    required this.allCharacters,
    required this.onCharacterAdded,
    required this.onCharacterRemoved,
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

              // find all existing characters matching the input
              final matches = allCharacters
                  .where((t) => t.toLowerCase().contains(lowerInput))
                  .toList();

              // if the exact character isn't already in your list, offer it first
              if (!allCharacters.any((t) => t.toLowerCase() == lowerInput)) {
                matches.insert(0, input);
              }

              return matches;
            },
            onSelected: (character) {
              onCharacterAdded(character);
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
                  labelText: 'Add character',
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
            children: characters.map((character) {
              return InputChip(
                label: Text(character),
                onDeleted: () => onCharacterRemoved(character),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
