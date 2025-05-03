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
        "C:\\", // path
        "Full Metal Alchemist Brotherhood", // title
        "Hiromu Arakawa", // author
        "link", // link
        "Full Metal Alchemist", // series
        ["Adventure", "Fantasy"], // tags
        ["Edward", "Alphonse", "Winry"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 1", // title
        "Shinichi Fukuda", // author
        "link", // link
        "My Dress Up Darling", // series
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 2", // title
        "Shinichi Fukuda", // author
        "link", // link
        "My Dress Up Darling", // series
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Wakana Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "Komi Can't Communicate: Volume 1", // title
        "Tomohito Oda", // author
        "link", // link
        "Komi Can't Communicate", // series
        ["Romance", "Comedy", "Slice of Life"], // tags
        ["Komi Shoko", "Tadano Hitohito"], // characters
        false, // favorite
        true, // read later
      ),
      Book(
        "C:\\", // path
        "Hokkaido Gals Are Super Adorable: Volume 1", // title
        "Ikada Kai", // author
        "link", // link
        "Hokkaido Gals Are Super Adorable", // series
        ["Romance", "Comedy"], // tags
        ["Fuyuki Minami", "Akino Sayuri", "Shiki Tsubasa"], // characters
        false, // favorite
        true, // read later
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
  }
}
