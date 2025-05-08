import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import '../../router/routes.dart';
import '../../widgets/widgets.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter_manga_reader/controllers/library_controller.dart';

class BookDetails extends StatefulWidget {
  final Book book;
  const BookDetails({super.key, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late final LibraryController libraryController;
  int imagesPerRow = 10;

  @override
  void initState() {
    super.initState();
    // initialize the library controller
    libraryController = context.read<LibraryController>();
  }

  @override
  Widget build(BuildContext context) {
    // controller for text editing field
    final TextEditingController titleController =
        TextEditingController(text: widget.book.title);
    final TextEditingController linkController =
        TextEditingController(text: widget.book.link);

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CoverImage(book: widget.book),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    // spaces out each row
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: StringEditor(
                                name: "Title",
                                controller: titleController,
                                onSubmitted: (newTitle) => setState(
                                  () {
                                    widget.book.title = newTitle;
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListEditor(
                                name: "author",
                                item: widget.book.authors,
                                // convert set to list for the editor
                                allItems: libraryController.authors.toList(),
                                onAdded: (sel) => setState(() {
                                  // add them if not already in
                                  if (!widget.book.authors.contains(sel)) {
                                    widget.book.authors.add(sel);
                                  }
                                }),
                                onRemoved: (author) => setState(() {
                                  // remove them if already in
                                  widget.book.authors.remove(author);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownEditor(
                                name: "Series",
                                initial: widget.book.series,
                                // convert set to list for the editor
                                all: libraryController.series.toList(),
                                onSelected: (sel) => setState(
                                  () {
                                    // add them if not already in
                                    if (!widget.book.series.contains(sel)) {
                                      widget.book.series = sel;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListEditor(
                                name: "tag",
                                item: widget.book.tags,
                                // convert set to list for the editor
                                allItems: libraryController.tags.toList(),
                                onAdded: (sel) => setState(() {
                                  // if new tag add to list
                                  if (!widget.book.tags.contains(sel)) {
                                    widget.book.tags.add(sel);
                                  }
                                }),
                                onRemoved: (tag) => setState(() {
                                  // remove them if already in
                                  widget.book.tags.remove(tag);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: StringEditor(
                                name: "Link",
                                controller: linkController,
                                onSubmitted: (newLink) => setState(() {
                                  widget.book.link = newLink;
                                }),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListEditor(
                                name: "character",
                                item: widget.book.characters,
                                // convert set to list for the editor
                                allItems:
                                    libraryController.characters.toList(),
                                onAdded: (sel) => setState(() {
                                  // if new character add to list
                                  if (!widget.book.characters.contains(sel)) {
                                    widget.book.characters.add(sel);
                                  }
                                }),
                                onRemoved: (character) => setState(() {
                                  // remove them if already in
                                  widget.book.characters.remove(character);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FavoriteButton(
                                isFavorite: widget.book.favorite,
                                onFavoriteToggle: (newVal) async {
                                  // Update the book's favorite status and save to JSON
                                  final success = await libraryController
                                      .updateFavorite(widget.book, newVal);
                                  if (success) {
                                    setState(
                                      () {
                                        widget.book.favorite =
                                            newVal; // Update the UI
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LaterButton(
                                isReadLater: widget.book.readLater,
                                onReadLaterToggle: (newVal) async {
                                  // Update the book's readLater status and save to JSON
                                  final success = await libraryController
                                      .updateReadLater(widget.book, newVal);
                                  if (success) {
                                    setState(
                                      () {
                                        widget.book.readLater =
                                            newVal; // Update the UI
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          ExplorerButton(
                            onExplorer: () {
                              Process.run("explorer", [widget.book.path]);
                            },
                          ),
                          DeleteButton(
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Book"),
                                  content: const Text(
                                      "Are you sure you want to delete this book?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                          context, false), // Cancel
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                          context, true), // Confirm
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                // Remove the book from the library
                                await libraryController
                                    .removeBook(widget.book);
                  
                                // Delete the book's files from the filesystem
                                final bookDir = Directory(widget.book.path);
                                if (await bookDir.exists()) {
                                  await bookDir.delete(recursive: true);
                                }
                  
                                // Navigate back to the previous screen
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PagesGrid(
                book: widget.book,
                imagesPerRow: imagesPerRow,
                childAspectRatio: 2 / 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoverImage extends StatelessWidget {
  final Book book;
  // requires the book as a param
  const CoverImage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // switch to the bookreader page
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.reader, // path to reader
              arguments: book, // object passed it
            );
          },
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Image.file(File(book.getCoverPath())),
          ),
        ),
      ),
    );
  }
}

class PagesGrid extends StatelessWidget {
  /// The book object
  final Book book;

  /// Images per row
  final int imagesPerRow;

  /// Width / height ratio of each cell
  final double childAspectRatio;

  const PagesGrid({
    super.key,
    required this.book,
    this.imagesPerRow = 3,
    this.childAspectRatio = 2 / 3,
  });

  @override
  Widget build(BuildContext context) {
    // set the files
    final pages = book.getPageFiles();
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imagesPerRow,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: book.getPageCount(),
        itemBuilder: (_, i) {
          return Image.file(
            pages[i],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
