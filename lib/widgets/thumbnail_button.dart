import 'package:flutter/material.dart';

class ThumbnailButton extends StatelessWidget {
  final VoidCallback onAdd;
  const ThumbnailButton({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.image),
          label: const Text('Add Thumbnail'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
    );
  }
}
