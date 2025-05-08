import 'package:flutter/material.dart';

class DropdownEditor extends StatefulWidget {
  final String name;
  final String initial;
  final List<String> all;
  final ValueChanged<String> onSelected;

  const DropdownEditor({
    Key? key,
    required this.name,
    required this.initial,
    required this.all,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<DropdownEditor> createState() => _DropdownEditorState();
}

class _DropdownEditorState extends State<DropdownEditor> {
  // track unsaved edits
  bool _isDirty = false;
  // track whether we've ever saved
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    // Ensure the list is sorted once during initialization
    widget.all.sort();
  }

  @override
  Widget build(BuildContext context) {
    // pick border/label color:
    // gray on pristine
    // red when dirty
    // green after save
    final Color activeColor = _isDirty
        ? Colors.redAccent
        : (_hasSaved ? Colors.greenAccent : Colors.grey);

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.initial),

      // iterate through each tag
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        final input = textEditingValue.text;
        final lowerInput = input.toLowerCase();

        // find all existing series matching the input
        final matches = widget.all
            .where((a) => a.toLowerCase().contains(lowerInput))
            .toList()
          ..sort();

        // if the exact series isn't in your list yet, offer it first
        if (!widget.all.any((a) => a.toLowerCase() == lowerInput)) {
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
            labelText: widget.name,
            labelStyle: TextStyle(color: activeColor),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: activeColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: activeColor),
            ),
            suffixIcon: textEditingController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: activeColor),
                    onPressed: () {
                      // clear the field
                      textEditingController.clear();
                      // notify parent that they selected “blank”
                      widget.onSelected('');
                      // reset dirty/saved state if you want
                      setState(() {
                        _isDirty = false;
                        _hasSaved = true;
                      });
                    },
                  )
                : null,
          ),
          onChanged: (_) {
            if (!_isDirty) setState(() => _isDirty = true);
            // need to rebuild to show/hide clear button
            setState(() {});
          },
          onSubmitted: (_) {
            // save on enter
            // (will pick the first option)
            if (textEditingController.text.isEmpty) {
              widget.onSelected('');
            } else {
              onFieldSubmitted();
            }

            setState(() {
              _isDirty = false;
              _hasSaved = true;
            });
          },
        );
      },
    );
  }
}
