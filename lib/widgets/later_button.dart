import 'package:flutter/material.dart';
class LaterButton extends StatelessWidget {
  final bool isReadLater;
  final ValueChanged<bool> onReadLaterToggle;
  const LaterButton({
    Key? key,
    required this.isReadLater,
    required this.onReadLaterToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onReadLaterToggle(!isReadLater),
      icon: Icon(
        isReadLater ? Icons.bookmark_added : Icons.bookmark_add_outlined,
      ),
      label: const Text('Read Later'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isReadLater ? Colors.blueAccent : Colors.grey[800],
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}