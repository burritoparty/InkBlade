import 'package:flutter/material.dart';

// widget for editing links
class LinkEditor extends StatefulWidget {
  // initial link text
  final String initialLink;
  // callback when link is submitted
  final ValueChanged<String> onSubmitted;

  const LinkEditor({
    Key? key,
    required this.initialLink,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<LinkEditor> createState() => _LinkEditorState();
}

class _LinkEditorState extends State<LinkEditor> {
  // controller for text field
  late TextEditingController _controller;
  // focus node to watch focus changes
  late FocusNode _focusNode;
  // whether last action was a submit
  bool _submitted = false;
  // whether text has changed since last submit
  bool _dirty = false;
  // text that was last submitted
  late String _lastSubmittedText;

  @override
  void initState() {
    super.initState();
    // initialize controller and track its changes
    _controller = TextEditingController(text: widget.initialLink);
    _lastSubmittedText = widget.initialLink;
    _controller.addListener(_onTextChanged);

    // initialize focus node to trigger rebuild on focus change
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // clean up listeners
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  // update dirty flag when text changes
  void _onTextChanged() {
    final current = _controller.text;
    final bool isDirty = current != _lastSubmittedText;
    if (isDirty != _dirty || _submitted) {
      setState(() {
        _dirty = isDirty;
        _submitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;

    // pick border color: red if dirty, green if just submitted, grey otherwise
    final Color borderColor =
        _dirty ? Colors.red : (_submitted ? Colors.green : Colors.grey);

    // pick focus color similarly
    final Color focusColor = _dirty
        ? Colors.red
        : (_submitted ? Colors.green : Theme.of(context).colorScheme.primary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Link',
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
        // trigger dirty logic on every change
        onChanged: (_) => _onTextChanged(),
        onSubmitted: (value) {
          // mark as submitted: clear dirty and update last text
          setState(() {
            _submitted = true;
            _lastSubmittedText = value;
            _dirty = false;
          });
          widget.onSubmitted(value);
          _focusNode.unfocus();
        },
      ),
    );
  }
}
