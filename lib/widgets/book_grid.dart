import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

/*
repository for passing in a list of books to display
*/
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
        // compute how many 300px-wide tiles fit…
        final calculated = (constraints.maxWidth / 300).floor();
        // never go below 2 columns
        final columns = calculated < 2 ? 2 : calculated;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2 / 3, // tweak for tile shape
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
    final badgePosition = Provider.of<SettingsController>(context).badgePosition;
    final badgeFontSize = Provider.of<SettingsController>(context).badgeFontSize;

    Widget? badge;
    if (badgePosition != 'off') {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${book.getPageCount()}',
          style: TextStyle(
            color: Colors.black,
            fontSize: badgeFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Positioned? badgeWidget;
    switch (badgePosition) {
      case 'topLeft':
        badgeWidget = badge != null
            ? Positioned(top: 6, left: 6, child: badge)
            : null;
        break;
      case 'topRight':
        badgeWidget = badge != null
            ? Positioned(top: 6, right: 6, child: badge)
            : null;
        break;
      case 'bottomLeft':
        badgeWidget = badge != null
            ? Positioned(bottom: 6, left: 6, child: badge)
            : null;
        break;
      case 'bottomRight':
        badgeWidget = badge != null
            ? Positioned(bottom: 6, right: 6, child: badge)
            : null;
        break;
      default:
        badgeWidget = null;
    }

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
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          File(book.getCoverPath()),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (badgeWidget != null) badgeWidget,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
