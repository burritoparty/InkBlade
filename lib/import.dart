import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  @override
  Widget build(BuildContext context) {
    // set up the book to modify
    Book book = Book("", "", [], "", "", "", false, false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import a book...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // add button
            const Expanded(child: CoverImage()),
            // details column
            Expanded(
              child: Column(
                // adjust expanding with screen here
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FavoriteReadLaterButtons(
                    isFavorite: book.favorite,
                    isReadLater: book.readLater,
                    onFavoriteToggle: (newVal) => setState(() {
                      book.favorite = newVal;
                    }),
                    onReadLaterToggle: (newVal) => setState(() {
                      book.readLater = newVal;
                    }),
                  ),
                  const TitleEntry(),
                  const AuthorEntry(),
                  const LinkEntry(),
                ],
              ),
            ),
            // tags here
            const Expanded(
              child: Text("temp"),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleEntry extends StatelessWidget {
  const TitleEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Title",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class AuthorEntry extends StatelessWidget {
  const AuthorEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Author",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class LinkEntry extends StatelessWidget {
  const LinkEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Link",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class CoverImage extends StatefulWidget {
  const CoverImage({super.key});

  @override
  State<CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage> {
  // keep track of when folder selected should be a plus
  bool _folderSelected = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // switch to the bookreader page
        onTap: () {
          setState(() {});
          // TODO: i want to select a folder here
          _folderSelected = true;
        },
        child: _folderSelected
            ? const Placeholder()
            : Center(
                child: Icon(
                  Icons.add,
                  size: 48,
                  color: Colors.grey[600],
                ),
              ),
      ),
    );
  }
}

class FavoriteReadLaterButtons extends StatelessWidget {
  final bool isFavorite;
  final bool isReadLater;
  final ValueChanged<bool> onFavoriteToggle;
  final ValueChanged<bool> onReadLaterToggle;

  const FavoriteReadLaterButtons({
    Key? key,
    required this.isFavorite,
    required this.isReadLater,
    required this.onFavoriteToggle,
    required this.onReadLaterToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          // Favorite button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onFavoriteToggle(!isFavorite),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.heart_broken_outlined,
              ),
              label: const Text('Favorite'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 5,
              ),
            ),
          ),

          // Read Later button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => onReadLaterToggle(!isReadLater),
                icon: Icon(
                  isReadLater
                      ? Icons.bookmark_added
                      : Icons.bookmark_add_outlined,
                ),
                label: const Text('Read Later'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
