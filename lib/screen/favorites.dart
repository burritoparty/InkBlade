import 'package:flutter/material.dart';
import '../widgets/book_grid.dart';
import '../router/routes.dart';

import '../controllers/library_controller.dart';
import 'package:provider/provider.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  Widget build(BuildContext context) {
    // set up the library controller, which holds the list of books
    // it watches for changes to the list of books, and rebuilds the widget tree
    final libraryController = context.watch<LibraryController>();
    // Filter the books dynamically
    final filteredBooks =
        libraryController.books.where((book) => book.favorite).toList();
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
