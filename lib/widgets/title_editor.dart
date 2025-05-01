// Comments added based on the original TitleEditor implementation citeturn0file0
import 'package:flutter/material.dart';

// A StatefulWidget that wraps a TextField for editing titles
class TitleEditor extends StatefulWidget {
  // controller to manage text input
  final TextEditingController controller;
  // callback when user submits text
  final ValueChanged<String> onSubmitted;

  const TitleEditor({
    Key? key,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  // create state instance
  @override
  State<TitleEditor> createState() => _TitleEditorState();
}

// State class for TitleEditor
class _TitleEditorState extends State<TitleEditor> {
  // tracks if text has been submitted
  bool _submitted = false;
  // listens to focus changes on the TextField
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // initialize focus node
    _focusNode = FocusNode();
    // redraw when focus changes
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // clean up focus node
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // whether the field is focused
    final bool isFocused = _focusNode.hasFocus;
    // border color based on submission
    final Color borderColor = _submitted ? Colors.green : Colors.grey;
    // focus color for label and border
    final Color focusColor = _submitted
        ? Colors.greenAccent
        : Theme.of(context).colorScheme.primary;

    return Padding(
      // horizontal padding around field
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        // attach focus node to field
        focusNode: _focusNode,
        // attach text controller
        controller: widget.controller,
        decoration: InputDecoration(
          // hint for the field
          labelText: 'Title',
          labelStyle: TextStyle(
            // change label color on focus
            color: isFocused ? focusColor : Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            // border when not focused
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            // border when focused
            borderSide: BorderSide(color: focusColor),
          ),
        ),
        onSubmitted: (value) {
          // flag as submitted
          setState(() {
            _submitted = true;
          });
          // call parent callback with submitted text
          widget.onSubmitted(value);
          // remove focus to show enabledBorder
          _focusNode.unfocus();
        },
      ),
    );
  }
}
