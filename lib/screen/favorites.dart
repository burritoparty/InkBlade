import 'package:flutter/material.dart';
import '../services/book_repository.dart';
import '../models/book.dart';
import '../router/routes.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  // TODO need to pass in object with all books
  late List<Book> allBooks = [];
  late List<Book> filteredBooks = [];
  @override
  void initState() {
    super.initState();
    // set up all books, make one a fave
    allBooks = [
      Book(
        "name1",
        "Shinichi Fukuda",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
      ),
      Book(
        "name2",
        "Shinichi Fukuda",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        true,
        true,
      ),
      Book(
        "name1",
        "Hiromu Arakawa",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
      ),
    ];

    // loop thru the books, if its a fave,
    // add it to the filtered
    for (Book book in allBooks) {
      if (book.favorite) {
        filteredBooks.add(book);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Favorites"),
      // ),
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
                setState(() {}); // pick up any changes on return
              },
            ),
          )
        ],
      ),
    );
    ;
  }
}
