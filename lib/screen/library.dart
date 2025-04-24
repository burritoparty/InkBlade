import 'package:flutter/material.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // setting button size
        final double maxWidth = constraints.maxWidth;
        int columns = (maxWidth / 200).floor();
        if (columns < 1) columns = 1;

        // setting up example data
        final List<String> items = List.generate(200, (i) => 'Button ${i + 1}');
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3, // adjust for button shape
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                // TODO: button action
              },
              child: Text(items[index]),
            );
          },
        );
      },
    );
  }
}
