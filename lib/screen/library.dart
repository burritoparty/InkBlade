import 'package:flutter/material.dart';

import 'package:flutter_manga_reader/book.dart';
import 'book_details.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // setting button size
        final double maxWidth = constraints.maxWidth;
        int columns = (maxWidth / 300).floor(); // modify the maxWidth / number to change size
        if (columns < 1) columns = 1;

        // setting up example data
        // replace this with loading a json
        List<Book> temporaryBooks = [];

        for (int i = 0; i < 20; i++) {
          var book = Book("name$i",
          "author", "link", ["tag1", "tag2", "tag3"],
           "coverPath", false, false);
           temporaryBooks.add(book);
        }

        // make the gridview
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.667, // adjust for button shape
          ),
          itemCount: temporaryBooks.length,
          // building the buttons
          itemBuilder: (context, index) {
            return ClipRRect(
              // borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  // pulls up the book details
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetails(book: temporaryBooks[index]),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // book title at the top
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: Text(
                          temporaryBooks[index].name,
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
                      const Expanded(
                        child: Placeholder(),
                      )
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
