import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';

import '../router/routes.dart';
import '../services/book_repository.dart';

// main library screen, holds state for the list of books
class Library extends StatefulWidget {
  const Library({super.key});

  @override
  LibraryState createState() => LibraryState();
}

class LibraryState extends State<Library> {
  // temporary in‐memory list until we load from JSON
  late List<Book> temporaryBooks;
  late final List<Book> allBooks;
  late List<Book> filteredBooks;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // dummy data
    allBooks = List.generate(
      10,
      (i) => Book(
        "name$i",
        "author",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
      ),
    );
    // show all
    filteredBooks = List.of(allBooks);

    // whenever the text changes, refilter
    _searchController.addListener(
      () {
        final q = _searchController.text.toLowerCase();
        setState(() {
          filteredBooks =
              allBooks.where((b) => b.title.toLowerCase().contains(q)).toList();
        });
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
              setState(() {
                filteredBooks = allBooks
                    .where((b) => b.title.toLowerCase().contains(q))
                    .toList();
              });
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
