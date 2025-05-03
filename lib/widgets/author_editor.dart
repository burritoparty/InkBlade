import 'package:flutter/material.dart';

class AuthorEditor extends StatefulWidget {
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
  State<AuthorEditor> createState() => _AuthorEditorState();
}

class _AuthorEditorState extends State<AuthorEditor> {
  // track unsaved edits
  bool _isDirty = false;
  // track whether we've ever saved
  bool _hasSaved = false;

  @override
  Widget build(BuildContext context) {
    // pick border/label color: 
    // gray on pristine
    // red when dirty 
    // green after save
    final Color activeColor = _isDirty
        ? Colors.redAccent
        : (_hasSaved ? Colors.greenAccent : Colors.grey);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: widget.initialAuthor),

        // iterate through each tag
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }

          final input = textEditingValue.text;
          final lowerInput = input.toLowerCase();

          // find all existing authors matching the input
          final matches = widget.allAuthors
              .where((a) => a.toLowerCase().contains(lowerInput))
              .toList();

          // if the exact author isn't in your list yet, offer it first
          if (!widget.allAuthors.any((a) => a.toLowerCase() == lowerInput)) {
            matches.insert(0, input);
          }

          return matches;
        },

        // if they tap a suggestion (whether new or existing)
        onSelected: (value) {
          setState(() {
            _isDirty = false;
            _hasSaved = true;
          });
          widget.onSelected(value);
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
              labelText: 'Author',
              labelStyle: TextStyle(color: activeColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: activeColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: activeColor),
              ),
            ),
            onChanged: (_) {
              if (!_isDirty) {
                setState(() => _isDirty = true);
              }
            },
            onSubmitted: (_) {
              // save on enter 
              // (will pick the first option)
              onFieldSubmitted();
              setState(() {
                _isDirty = false;
                _hasSaved = true;
              });
            },
          );
        },
      ),
    );
  }
}
