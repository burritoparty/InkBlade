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
  _AuthorEditorState createState() => _AuthorEditorState();
}

class _AuthorEditorState extends State<AuthorEditor> {
  // tracks unsaved edits
  bool _isDirty = false;
  // tracks whether we've ever saved
  bool _hasSaved = false;

  @override
  Widget build(BuildContext context) {
    // pick border/label color: gray on pristine, red when dirty, green after save
    final Color activeColor = _isDirty
        ? Colors.red
        : (_hasSaved ? Colors.green : Colors.grey);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: widget.initialAuthor),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          final input = textEditingValue.text.toLowerCase();
          return widget.allAuthors
              .where((a) => a.toLowerCase().contains(input));
        },
        onSelected: (value) {
          // mark saved on dropdown select
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
              // label color matches border
              labelStyle: TextStyle(color: activeColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: activeColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: activeColor),
              ),
            ),
            onChanged: (_) {
              // turn dirty on any change
              if (!_isDirty) {
                setState(() {
                  _isDirty = true;
                });
              }
            },
            onSubmitted: (_) {
              // save on enter
              onFieldSubmitted();
              setState(() {
                _isDirty = false;
                _hasSaved = true;
              });
              widget.onSelected(textEditingController.text);
            },
          );
        },
      ),
    );
  }
}
