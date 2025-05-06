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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
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
                        // title handling
                        Padding(
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownEditor(
                            name: "Series",
                            initial: widget.book.series,
                            all: libraryController.series.toList(),
                            onSelected: (sel) => setState(() {
                              // add sel to book.series if it’s not already there
                              if (widget.book.series != sel) {
                                widget.book.series = sel;
                              }
                              // TODO: this prob needs changed when implementing database
                              if (!libraryController.series.contains(sel)) {
                                libraryController.series.add(sel);
                              }
                            }),
                          ),
                        ),
                        // link handling
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StringEditor(
                            name: "Link",
                            controller: linkController,
                            onSubmitted: (newLink) => setState(
                              () {
                                widget.book.link = newLink;
                              },
                            ),
                          ),
                        ),
                        // favorite and read later
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FavoriteButton(
                                  isFavorite: widget.book.favorite,
                                  onFavoriteToggle: (newVal) => setState(
                                    () {
                                      widget.book.favorite = newVal;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LaterButton(
                                isReadLater: widget.book.readLater,
                                onReadLaterToggle: (newVal) => setState(() {
                                  widget.book.readLater = newVal;
                                }),
                              ),
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                  // tag handling
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // authors
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "author",
                            item: widget.book.authors,
                            allItems: libraryController.authors.toList(),
                            onAdded: (sel) async {
                              if (!widget.book.authors.contains(sel)) {
                                // Update the book's authors and save to JSON
                                final success = await libraryController
                                    .updateAuthors(widget.book, sel, false);
                                if (success) {
                                  setState(() {}); // Just update the UI
                                }
                              }
                            },
                            onRemoved: (author) async {
                              if (widget.book.authors.contains(author)) {
                                // Update the book's authors and save to JSON
                                final success = await libraryController
                                    .updateAuthors(widget.book, author, true);
                                if (success) {
                                  setState(
                                    () {
                                      widget.book.authors.remove(author);
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        // tags
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "tag",
                            item: widget.book.tags,
                            allItems: libraryController.tags.toList(),
                            onAdded: (sel) async {
                              if (!widget.book.tags.contains(sel)) {
                                // Update the book's tags and save to JSON
                                final success = await libraryController
                                    .updateTags(widget.book, sel, false);
                                if (success) {
                                  setState(() {}); // Just update the UI
                                }
                              }
                            },
                            onRemoved: (tag) async {
                              if (widget.book.tags.contains(tag)) {
                                // Update the book's tags and save to JSON
                                final success = await libraryController
                                    .updateTags(widget.book, tag, true);
                                if (success) {
                                  setState(
                                    () {
                                      widget.book.tags.remove(tag);
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        // characters
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "character",
                            item: widget.book.characters,
                            allItems: libraryController.characters.toList(),
                            onAdded: (sel) async {
                              if (!widget.book.characters.contains(sel)) {
                                // Update the book's characters and save to JSON
                                final success = await libraryController
                                    .updateCharacters(widget.book, sel, false);
                                if (success) {
                                  setState(() {}); // Just update the UI
                                }
                              }
                            },
                            onRemoved: (character) async {
                              if (widget.book.characters.contains(character)) {
                                // Update the book's characters and save to JSON
                                final success =
                                    await libraryController.updateCharacters(
                                        widget.book, character, true);
                                if (success) {
                                  setState(
                                    () {
                                      widget.book.characters.remove(character);
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        // explorer and delete
                        Row(
                          children: [
                            ExplorerButton(
                              onExplorer: () {
                                Process.run("explorer", [widget.book.path]);
                              },
                            ),
                            DeleteButton(
                              onDelete: () {
                                // delete logic here
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PagesGrid(
              book: widget.book,
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
