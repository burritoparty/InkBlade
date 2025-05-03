import 'package:flutter/material.dart';
import '../services/book_repository.dart';
import '../models/book.dart';
import '../router/routes.dart';
import '../widgets/widgets.dart';

class AuthorDetails extends StatefulWidget {
  final String author;
  final List<String> allAuthors;

  const AuthorDetails({
    super.key,
    required this.author,
    required this.allAuthors,
  });

  @override
  State<AuthorDetails> createState() => AuthorDetailsState();
}

class AuthorDetailsState extends State<AuthorDetails> {
  late String _author;
  late List<String> allAuthors = [];
  late final List<Book> allBooks;
  late List<Book> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _author = widget.author;

    // get all the books
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

    // look through the books and only load up the ones with author
    for (Book book in allBooks) {
      // iterate thru every books authors
      for (String author in book.authors) {
        // if new author add to list
        if (!allAuthors.contains(author)) {
          allAuthors.add(author);
        }
        // if author matches author add to list
        // TODO this may cause an error when changing the author name
        if (author == _author) {
          filteredBooks.add(book);
        }
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_author),
      ),
      body: Column(
        children: [
          // AuthorAutocompleteField(
          //   initialAuthor: _author,
          //   allAuthors: widget.allAuthors,
          //   onSelected: (sel) {
          //     setState(() {
          //       _author = sel;
          //       debugPrint('Selected author: $sel');
          //     });
          //   },
          // ),

          AuthorEditor(
            initialAuthor: _author,
            allAuthors: [],
            onSelected: (sel) => setState(() {
              // add sel to book.tags if it’s not already there
              if (_author != sel) {
                _author = sel;
              }
              // TODO: this prob needs changed when implementing database
              if (!allAuthors.contains(sel)) allAuthors.add(sel);
            }),
          ),

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
  }
}