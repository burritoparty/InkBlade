import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import '../../router/routes.dart';
import '../../widgets/widgets.dart';
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
                        TitleEditor(
                          controller: titleController,
                          onSubmitted: (newTitle) => setState(() {
                            widget.book.title = newTitle;
                          }),
                        ),
                        AuthorEditor(
                          initialAuthor: widget.book.author,
                          allAuthors: allAuthors,
                          onSelected: (sel) => setState(() {
                            widget.book.author = sel;
                            debugPrint('Selected author: $sel');
                          }),
                        ),
                        // link handling
                        LinkEditor(
                          initialLink: widget.book.link,
                          onSubmitted: (newLink) => setState(() {
                            widget.book.link = newLink;
                          }),
                        ),
                        // favorite and read later 
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FavoriteButton(
                                  isFavorite: widget.book.favorite,
                                  onFavoriteToggle: (newVal) => setState(() {
                                    widget.book.favorite = newVal;
                                  }),
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
                        // explorer and delete
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ExplorerButton(onExplorer: () {
                                Process.run("explorer", [widget.book.path]);
                              }),
                              DeleteButton(onDelete: () {
                                // delete logic here
                              }),
                            ],
                          ),
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
            PagesGrid(
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
  const CoverImage({Key? key, required this.book}) : super(key: key);

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
          child: const AspectRatio(
            aspectRatio: 2 / 3,
            child: Placeholder(),
          ),
        ),
      ),
    );
  }
}

class PagesGrid extends StatelessWidget {
  /// How many “pages” (placeholders) to show
  final int totalPages;

  /// Images per row
  final int imagesPerRow;

  /// Width / height ratio of each cell
  final double childAspectRatio;

  const PagesGrid({
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
