import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/book.dart';
import 'book_reader.dart';
import 'dart:io';

class BookDetails extends StatefulWidget {
  final Book book;
  const BookDetails({super.key, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  @override
  Widget build(BuildContext context) {
    // controller for text editing field
    final TextEditingController titleController =
        TextEditingController(text: widget.book.title);

    // mock data
    // grab the authors
    List<String> allAuthors = [];
    for (int i = 0; i < 1000; i++) {
      allAuthors.add("authorname$i");
    }
    List<String> allTags = [];
    for (int i = 0; i < 15; i++) {
      allTags.add("tagname$i");
    }
    int imagesPerRow = 10;
    int totalPages = 30;

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverImage(book: widget.book),
                  Expanded(
                    // modify flex for how much space is taken
                    flex: 2,
                    // pad out from the image
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // name of the book
                      children: [
                        // title
                        BookTitleField(
                          controller: titleController,
                          onSubmitted: (newTitle) => setState(() {
                            widget.book.title = newTitle;
                          }),
                        ),
                        AuthorAutocompleteField(
                          initialAuthor: widget.book.author,
                          allAuthors: allAuthors,
                          onSelected: (sel) => setState(() {
                            widget.book.author = sel;
                            debugPrint('Selected author: $sel');
                          }),
                        ),
                        // link handling
                        LinkInputField(
                          initialLink: widget.book.link,
                          onSubmitted: (newLink) => setState(() {
                            widget.book.link = newLink;
                          }),
                        ),
                        // favorite and read later button
                        FavoriteReadLaterButtons(
                          isFavorite: widget.book.favorite,
                          isReadLater: widget.book.readLater,
                          onFavoriteToggle: (newVal) => setState(() {
                            widget.book.favorite = newVal;
                          }),
                          onReadLaterToggle: (newVal) => setState(() {
                            widget.book.readLater = newVal;
                          }),
                        ),
                        // explorer and delete book
                        ExplorerDeleteButtons(
                          onExplorer: () {
                            Process.run("explorer", [widget.book.path]);
                          },
                          onDelete: () {
                            setState(() {
                              // perform deletion logic here
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // tag handling
                  TagEditor(
                    tags: widget.book.tags,
                    allTags: allTags,
                    onTagAdded: (sel) => setState(() {
                      widget.book.tags.add(sel);
                      debugPrint('Selected tag: $sel');
                    }),
                    onTagRemoved: (tag) => setState(() {
                      widget.book.tags.remove(tag);
                    }),
                    flex: 2,
                  ),
                ],
              ),
            ),
            PagesPlaceholderGrid(
              totalPages: totalPages,
              imagesPerRow: imagesPerRow,
            ),
          ],
        ),
      ),
    );
  }
}


class CoverImage extends StatelessWidget {
  final Book book;
  // requires the book as a param
  const CoverImage({ Key? key, required this.book }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // switch to the bookreader page
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookReader(book: book)),
            );
          },
          child: const AspectRatio(
            aspectRatio: 2 / 3,
            child: Placeholder(),
          ),
        ),
      ),
    );
  }
}



class BookTitleField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const BookTitleField({
    Key? key,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: "Title",
          border: OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class AuthorAutocompleteField extends StatelessWidget {
  final String initialAuthor;
  final List<String> allAuthors;
  final ValueChanged<String> onSelected;

  const AuthorAutocompleteField({
    Key? key,
    required this.initialAuthor,
    required this.allAuthors,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: initialAuthor),
        optionsBuilder: (TextEditingValue textEditingValue) {
          final input = textEditingValue.text.toLowerCase();
          return allAuthors.where((a) => a.toLowerCase().contains(input));
        },
        onSelected: onSelected,
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
              labelText: 'Author',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onFieldSubmitted(),
          );
        },
      ),
    );
  }
}

class LinkInputField extends StatelessWidget {
  final String initialLink;
  final ValueChanged<String> onSubmitted;

  const LinkInputField({
    Key? key,
    required this.initialLink,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialLink);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Link',
          border: OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted,
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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

class ExplorerDeleteButtons extends StatelessWidget {
  final VoidCallback onExplorer;
  final VoidCallback onDelete;

  const ExplorerDeleteButtons({
    Key? key,
    required this.onExplorer,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          // Open file location
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: onExplorer,
                icon: const Icon(Icons.folder),
                label: const Text('Explorer'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),

          // Delete book
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Book'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

class PagesPlaceholderGrid extends StatelessWidget {
  /// How many “pages” (placeholders) to show
  final int totalPages;

  /// Images per row
  final int imagesPerRow;

  /// Width / height ratio of each cell
  final double childAspectRatio;

  const PagesPlaceholderGrid({
    Key? key,
    required this.totalPages,
    this.imagesPerRow = 3,
    this.childAspectRatio = 2 / 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imagesPerRow,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: totalPages,
        itemBuilder: (context, index) {
          return const Placeholder();
        },
      ),
    );
  }
}
