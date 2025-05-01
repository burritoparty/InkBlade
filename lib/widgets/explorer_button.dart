import 'package:flutter/material.dart';

class ExplorerButton extends StatelessWidget {
  final VoidCallback onExplorer;

  const ExplorerButton({
    Key? key,
    required this.onExplorer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: onExplorer,
          icon: const Icon(Icons.folder),
          label: const Text('Explorer'),
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
