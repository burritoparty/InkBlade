import 'package:flutter/material.dart';

// widget for editing entries for given
class StringEditor extends StatefulWidget {
  final String name;
  // text controller
  final TextEditingController controller;
  // submit callback
  final ValueChanged<String> onSubmitted;
  // for following a link
  final VoidCallback? onTap;
  // optional version toggle to mark the current controller text as saved
  final int? savedVersion;

  const StringEditor({
    Key? key,
    required this.name,
    required this.controller,
    required this.onSubmitted,
    this.onTap,
    this.savedVersion,
  }) : super(key: key);

  @override
  State<StringEditor> createState() => _StringEditorsState();
}

class _StringEditorsState extends State<StringEditor> {
  // was last action a submit
  bool _submitted = false;
  // is text changed
  bool _dirty = false;
  // last saved text
  late String _lastSubmittedText;
  // focus node for field
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _lastSubmittedText = widget.controller.text;
    // watch text changes
    widget.controller.addListener(_onTextChanged);
    _focusNode = FocusNode();
    // update on focus change
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // stop watching text
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StringEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent toggles the savedVersion (increments), treat current text as submitted/saved
    if (widget.savedVersion != null &&
        widget.savedVersion != oldWidget.savedVersion) {
      setState(() {
        _submitted = true;
        _lastSubmittedText = widget.controller.text;
        _dirty = false;
      });
    }
  }

  // handle text update
  void _onTextChanged() {
    final current = widget.controller.text;
    final bool isDirty = current != _lastSubmittedText;
    // Only update state when the dirty flag actually changes, or when the
    // text becomes dirty (we should clear the submitted/saved state).
    // This avoids clearing `_submitted` on selection-only updates which
    // also notify the controller.
    if (isDirty != _dirty) {
      setState(() {
        _dirty = isDirty;
        if (isDirty) {
          _submitted = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    // choose border color
    final Color borderColor = _dirty
        ? Colors.redAccent
        : (_submitted ? Colors.greenAccent : Colors.grey);
    // choose focus color
    final Color focusColor = _dirty
        ? Colors.redAccent
        : (_submitted
            ? Colors.greenAccent
            : Theme.of(context).colorScheme.primary);

    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.name,
        labelStyle: TextStyle(
          color: isFocused ? focusColor : Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: focusColor),
        ),
      ),
      // update dirty state on change
      onChanged: (value) => _onTextChanged(),
      onSubmitted: (value) {
        // mark as submitted
        setState(() {
          _submitted = true;
          _lastSubmittedText = value;
          _dirty = false;
        });
        widget.onSubmitted(value);
        _focusNode.unfocus();
      },
      onTap: widget.onTap,
    );
  }
}
