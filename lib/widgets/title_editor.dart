import 'package:flutter/material.dart';
class TitleEditor extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const TitleEditor({
    Key? key,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: "Title",
          border: OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}