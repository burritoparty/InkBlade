// Third-party package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project-specific imports
import '../controllers/library_controller.dart';
import '../router/routes.dart';
import '../widgets/book_grid.dart';

class Later extends StatefulWidget {
  const Later({super.key});

  @override
  State<Later> createState() => _LaterState();
}

class _LaterState extends State<Later> {
  @override
  Widget build(BuildContext context) {
    // set up the library controller, which holds the list of books
    // it watches for changes to the list of books, and rebuilds the widget tree
    final libraryController = context.watch<LibraryController>();
    // Filter the books dynamically
    final filteredBooks =
        libraryController.books.where((book) => book.readLater).toList();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BookGrid(
              books: filteredBooks,
              onBookTap: (index) async {
                await Navigator.pushNamed(
                  context,
                  Routes.details,
                  arguments: filteredBooks[index],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
