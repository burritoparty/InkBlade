import 'package:flutter/material.dart';
import '../widgets/book_grid.dart';
import '../models/book.dart';
import '../router/routes.dart';

class Later extends StatefulWidget {
  const Later({super.key});

  @override
  State<Later> createState() => _LaterState();
}

class _LaterState extends State<Later> {
  // TODO need to pass in object with all books
  late List<Book> allBooks = [];
  late List<Book> filteredBooks = [];
  @override
  void initState() {
    super.initState();
    // set up all books, make one a later
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

    // loop thru the books, if its a later,
    // add it to the filtered
    for (Book book in allBooks) {
      if (book.readLater) {
        filteredBooks.add(book);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
