import 'package:flutter/material.dart';
class LinkEditor extends StatelessWidget {
  final String initialLink;
  final ValueChanged<String> onSubmitted;

  const LinkEditor({
    Key? key,
    required this.initialLink,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialLink);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Link',
          border: OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}