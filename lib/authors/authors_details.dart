import 'package:flutter/material.dart';
import '../widgets/book_grid.dart';
import '../models/book.dart';
import '../router/routes.dart';
import '../widgets/widgets.dart';

class AuthorDetails extends StatefulWidget {
  final String author;

  const AuthorDetails({
    super.key,
    required this.author,
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
    final allBooks = [
      Book(
        path: "C:\\",
        title: "Full Metal Alchemist Brotherhood",
        link: "link",
        series: "Full Metal Alchemist",
        authors: ["Hiromu Arakawa"],
        tags: ["Adventure", "Fantasy"],
        characters: ["Edward", "Alphonse", "Winry"],
        favorite: true,
        readLater: false,
      ),
      Book(
        path: "C:\\",
        title: "My Dress Up Darling: Volume 1",
        link: "link",
        series: "My Dress Up Darling",
        authors: ["Shinichi Fukuda"],
        tags: ["Romance", "Comedy", "Cosplay"],
        characters: ["Marin Kitagawa", "Gojo"],
        favorite: true,
        readLater: false,
      ),
      Book(
        path: "C:\\",
        title: "My Dress Up Darling: Volume 2",
        link: "link",
        series: "My Dress Up Darling",
        authors: ["Shinichi Fukuda"],
        tags: ["Romance", "Comedy", "Cosplay"],
        characters: ["Marin Kitagawa", "Wakana Gojo"],
        favorite: true,
        readLater: false,
      ),
      Book(
        path: "C:\\",
        title: "Komi Can't Communicate: Volume 1",
        link: "link",
        series: "Komi Can't Communicate",
        authors: ["Tomohito Oda"],
        tags: ["Romance", "Comedy", "Slice of Life"],
        characters: ["Komi Shoko", "Tadano Hitohito"],
        favorite: false,
        readLater: true,
      ),
      Book(
        path: "C:\\",
        title: "Hokkaido Gals Are Super Adorable: Volume 1",
        link: "link",
        series: "Hokkaido Gals Are Super Adorable",
        authors: ["Ikada Kai"],
        tags: ["Romance", "Comedy"],
        characters: ["Fuyuki Minami", "Akino Sayuri", "Shiki Tsubasa"],
        favorite: false,
        readLater: true,
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
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownEditor(
                    name: "Rename Author",
                    initial: _author,
                    all: allAuthors,
                    onSelected: (sel) => setState(() {
                      // add sel to book.tags if it’s not already there
                      if (_author != sel) {
                        _author = sel;
                      }
                      // TODO: this prob needs changed when implementing database
                      if (!allAuthors.contains(sel)) allAuthors.add(sel);
                    }),
                  ),
                ),
              ),
              DeleteButton(onDelete: () {}),
            ],
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
