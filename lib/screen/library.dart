import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/controllers/library_controller.dart';
import 'package:flutter_manga_reader/models/book.dart';
import 'package:provider/provider.dart';

import '../router/routes.dart';
import '../widgets/book_grid.dart';

// main library screen, holds state for the list of books
class Library extends StatefulWidget {
  const Library({super.key});

  @override
  LibraryState createState() => LibraryState();
}

class LibraryState extends State<Library> {
  late final LibraryController libraryController;
  late List<Book> filteredBooks;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // get the library controller from the provider
    libraryController = context.read<LibraryController>();

    // show all to start
    filteredBooks = List.of(libraryController.books);

    // rebuild any time controller changes
    libraryController.addListener(_onLibraryChanged);

    // controller to whenever the text changes, refilter
    _searchController.addListener(
      () {
        final q = _searchController.text.toLowerCase();
        setState(
          () {
            filteredBooks = libraryController.books
                .where((b) => b.title.toLowerCase().contains(q))
                .toList();
          },
        );
      },
    );
  }

  // clean up the controller when the widget is disposed
  void _onLibraryChanged() {
    if (!mounted) return; // don’t do anything if we’ve been disposed
    final q = _searchController.text.toLowerCase();
    setState(
      () {
        filteredBooks = libraryController.books
            .where((b) => b.title.toLowerCase().contains(q))
            .toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Search books...',
            onChanged: (value) {
              final q = value.toLowerCase();
              setState(
                () {
                  filteredBooks = libraryController.books
                      .where((b) => b.title.toLowerCase().contains(q))
                      .toList();
                },
              );
            },
          ),
        ),

        // grid uses filteredBooks
        Expanded(
          child: BookGrid(
            books: filteredBooks,
            onBookTap: (index) async {
              await Navigator.pushNamed(
                context,
                Routes.details,
                arguments: filteredBooks[index],
              );
              setState(() {}); // pick up any changes on return
            },
          ),
        ),
      ],
    );
  }
}
