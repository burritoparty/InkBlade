import 'package:flutter/material.dart';

import 'package:flutter_manga_reader/book.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // setting button size
        final double maxWidth = constraints.maxWidth;
        int columns = (maxWidth / 325).floor(); // modify the maxWidth / number to change size
        if (columns < 1) columns = 1;

        // setting up example data
        // replace this with loading a json 
        var book1 = Book(
            "Book Name1",
            "Author Name",
            "Link to book",
            ["tag1", "tag2"],
            "C:\\Placeholder\\Path",
            false,
            true);
        var book2 = Book(
            "Book Name2",
            "Author Name",
            "Link to book",
            ["tag1", "tag2"],
            "C:\\Placeholder\\Path",
            false,
            true);

        List<Book> books = [];
        books.add(book1);
        books.add(book2);

        // make the gridview
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.667, // adjust for button shape
          ),
          itemCount: books.length,
          // building the buttons
          itemBuilder: (context, index) {
            return ClipRRect(
              // borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  // set the function to be called
                  onTap: () {
                    debugPrint('tapped on ${books[index].name}');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // book title at the top
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: Text(
                          books[index].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // cover, filling remaining space
                      const Expanded(child: Placeholder(),)
                      // uncomment this to actually get the image
                      // Expanded(
                      //   child: Image.file(
                      //     File(books[index].coverPath),
                      //     width: double.infinity,
                      //     // height is defined by Expanded
                      //     fit: BoxFit.contain,
                      //     alignment: Alignment.bottomCenter,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
