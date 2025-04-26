import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';

import '../router/routes.dart';
import '../services/book_repository.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => SearchState();
}

class SearchState extends State<Search> {
  // temporary in‐memory list until we load from JSON
  late List<Book> temporaryBooks;

  late final List<Book> allBooks;
  late List<Book> filteredBooks;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // generate dummy books for now
    temporaryBooks = List.generate(
      10,
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

    super.initState();
    // 1) build your dummy data once
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
    // 2) start by showing all of them
    filteredBooks = List.of(allBooks);

    // 3) whenever the text changes, refilter
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      setState(() {
        filteredBooks =
            allBooks.where((b) => b.title.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // replace your const SearchField with a real TextField
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

        // the grid now uses filteredBooks
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
