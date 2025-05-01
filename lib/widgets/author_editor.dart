import 'package:flutter/material.dart';
class AuthorEditor extends StatelessWidget {
  final String initialAuthor;
  final List<String> allAuthors;
  final ValueChanged<String> onSelected;

  const AuthorEditor({
    Key? key,
    required this.initialAuthor,
    required this.allAuthors,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: initialAuthor),
        optionsBuilder: (TextEditingValue textEditingValue) {
          final input = textEditingValue.text.toLowerCase();
          return allAuthors.where((a) => a.toLowerCase().contains(input));
        },
        onSelected: onSelected,
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
              labelText: 'Author',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onFieldSubmitted(),
          );
        },
      ),
    );
  }
}