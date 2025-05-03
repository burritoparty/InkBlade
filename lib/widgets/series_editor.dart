import 'package:flutter/material.dart';

class SeriesEditor extends StatefulWidget {
  final String initialSeries;
  final List<String> allSeries;
  final ValueChanged<String> onSelected;

  const SeriesEditor({
    Key? key,
    required this.initialSeries,
    required this.allSeries,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SeriesEditor> createState() => _SeriesEditorState();
}

class _SeriesEditorState extends State<SeriesEditor> {
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
        initialValue: TextEditingValue(text: widget.initialSeries),

        // iterate through each tag
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }

          final input = textEditingValue.text;
          final lowerInput = input.toLowerCase();

          // find all existing series matching the input
          final matches = widget.allSeries
              .where((a) => a.toLowerCase().contains(lowerInput))
              .toList();

          // if the exact series isn't in your list yet, offer it first
          if (!widget.allSeries.any((a) => a.toLowerCase() == lowerInput)) {
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
              labelText: 'Series',
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
