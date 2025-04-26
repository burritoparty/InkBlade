import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/book.dart';
import 'book_details.dart';

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
      20,
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
        // open details, then refresh when returned
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetails(book: temporaryBooks[index]),
          ),
        );
        setState(() { /* rebuild to pick up any changes */ });
      },
    );
  }
}

// single book tile: title, image, ripple efx
class BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookTile({
    Key? key,
    required this.book,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // rounded corners if you want
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // book title at top, ellipsize if too long
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 4.0, horizontal: 8.0),
                child: Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // placeholder for cover
              const Expanded(child: Placeholder()),
            ],
          ),
        ),
      ),
    );
  }
}

// responsive grid of BookTiles
class BookGrid extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<int> onBookTap;

  const BookGrid({
    Key? key,
    required this.books,
    required this.onBookTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // calculate how many columns fit at ~300px each
        int columns = (constraints.maxWidth / 300).floor().clamp(1, books.length);

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2/3, // tweak for tile shape
          ),
          itemCount: books.length,
          itemBuilder: (context, i) => BookTile(
            book: books[i],
            onTap: () => onBookTap(i),
          ),
        );
      },
    );
  }
}
