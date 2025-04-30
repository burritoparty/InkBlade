import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  Book book = Book("", "", [], "", "", "", false, false);
  @override
  Widget build(BuildContext context) {
    // set up the book to modify
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
                  Row(children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FavoriteButton(
                          isFavorite: book.favorite,
                          onFavoriteToggle: (newVal) => setState(() {
                            book.favorite = newVal;
                          }),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ReadLaterButton(
                          isReadLater: book.readLater,
                          onReadLaterToggle: (newVal) => setState(() {
                            book.readLater = newVal;
                          }),
                        ),
                      ),
                    ),
                  ]),
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
        onTap: () {
          setState(() {});
          // TODO: i want to select a folder here
          _folderSelected = true;
        },
        child: _folderSelected
            ? const Placeholder()
            : Icon(
                Icons.add,
                size: 48,
                color: Colors.grey[600],
                
              ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteToggle;
  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onFavoriteToggle(!isFavorite),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
      ),
      label: const Text('Favorite'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFavorite ? Colors.blueAccent : Colors.grey[800],
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}

class ReadLaterButton extends StatelessWidget {
  final bool isReadLater;
  final ValueChanged<bool> onReadLaterToggle;
  const ReadLaterButton({
    Key? key,
    required this.isReadLater,
    required this.onReadLaterToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onReadLaterToggle(!isReadLater),
      icon: Icon(
        isReadLater ? Icons.bookmark_added : Icons.bookmark_add_outlined,
      ),
      label: const Text('Read Later'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isReadLater ? Colors.blueAccent : Colors.grey[800],
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}

class TagEditor extends StatelessWidget {
  final List<String> tags;
  final List<String> allTags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final int flex;

  const TagEditor({
    Key? key,
    required this.tags,
    required this.allTags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.flex = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              final input = textEditingValue.text.toLowerCase();
              return allTags.where((a) => a.toLowerCase().contains(input));
            },
            onSelected: onTagAdded,
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Add tag',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  onFieldSubmitted();
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: tags.map((tag) {
                return InputChip(
                  label: Text(tag),
                  onDeleted: () => onTagRemoved(tag),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}