import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import '../services/book_repository.dart';
import '../models/book.dart';
// import '../router/routes.dart';
import '../widgets/widgets.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
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
    // controller for text editing field
    return const Row(
      children: [
        Expanded(child: TitleSearch()),
      ],
    );
  }
}

class TitleSearch extends StatelessWidget {
  const TitleSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        labelText: "Title",
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
