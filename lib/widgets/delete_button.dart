import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteButton({
    Key? key,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Book'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          );
  }
}