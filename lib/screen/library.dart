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

  @override
  void initState() {
    super.initState();
    // generate dummy books for now
    temporaryBooks = List.generate(
      1,
      (i) => Book(
        "name$i",
        "author",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        false, // favorite?
        false, // readLater?
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // delegate grid layout + tap handling to BookGrid
    return BookGrid(
      books: temporaryBooks,
      onBookTap: (index) async {
        await Navigator.pushNamed(
          context,
          Routes.details, // path to details
          arguments: temporaryBooks[index], // object passed it
        );
        setState(() {/* rebuild to pick up any changes */});
      },
    );
  }
}
