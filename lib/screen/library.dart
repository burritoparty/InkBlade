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
    allBooks = [
      Book(
        "C:\\", // path
        "Full Metal Alchemist Brotherhood", // title
        "link", // link
        "Full Metal Alchemist", // series
        ["Hiromu Arakawa"], // author
        ["Adventure", "Fantasy"], // tags
        ["Edward", "Alphonse", "Winry"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 1", // title
        "link", // link
        "My Dress Up Darling", // series
        ["Shinichi Fukuda"], // author
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 2", // title
        "link", // link
        "My Dress Up Darling", // series
        ["Shinichi Fukuda"], // author
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Wakana Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "Komi Can't Communicate: Volume 1", // title
        "link", // link
        "Komi Can't Communicate", // series
        ["Tomohito Oda"], // author
        ["Romance", "Comedy", "Slice of Life"], // tags
        ["Komi Shoko", "Tadano Hitohito"], // characters
        false, // favorite
        true, // read later
      ),
      Book(
        "C:\\", // path
        "Hokkaido Gals Are Super Adorable: Volume 1", // title
        "link", // link
        "Hokkaido Gals Are Super Adorable", // series
        ["Ikada Kai"], // author
        ["Romance", "Comedy"], // tags
        ["Fuyuki Minami", "Akino Sayuri", "Shiki Tsubasa"], // characters
        false, // favorite
        true, // read later
      ),
    ];

    // show all to start
    filteredBooks = List.of(allBooks);

    // controller to whenever the text changes, refilter
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
