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
  // mock data
  // grab the books
  List<Book> allBooks = [];
  // grab the authors
  List<String> allAuthors = [];
  // grab the tags
  List<String> allTags = [];
  // grab the series
  List<String> allSeries = [];
  // grab the characters
  List<String> allCharacters = [];
  int imagesPerRow = 10;

  @override
  void initState() {
    super.initState();

    // set up all books, make one a fave
    final allBooks = [
      Book(
        path: "C:\\",
        title: "Full Metal Alchemist Brotherhood",
        link: "link",
        series: "Full Metal Alchemist",
        authors: ["Hiromu Arakawa"],
        tags: ["Adventure", "Fantasy"],
        characters: ["Edward", "Alphonse", "Winry"],
        favorite: true,
        readLater: false,
      ),
      Book(
        path: "C:\\",
        title: "My Dress Up Darling: Volume 1",
        link: "link",
        series: "My Dress Up Darling",
        authors: ["Shinichi Fukuda"],
        tags: ["Romance", "Comedy", "Cosplay"],
        characters: ["Marin Kitagawa", "Gojo"],
        favorite: true,
        readLater: false,
      ),
      Book(
        path: "C:\\",
        title: "My Dress Up Darling: Volume 2",
        link: "link",
        series: "My Dress Up Darling",
        authors: ["Shinichi Fukuda"],
        tags: ["Romance", "Comedy", "Cosplay"],
        characters: ["Marin Kitagawa", "Wakana Gojo"],
        favorite: true,
        readLater: false,
      ),
      Book(
        path: "C:\\",
        title: "Komi Can't Communicate: Volume 1",
        link: "link",
        series: "Komi Can't Communicate",
        authors: ["Tomohito Oda"],
        tags: ["Romance", "Comedy", "Slice of Life"],
        characters: ["Komi Shoko", "Tadano Hitohito"],
        favorite: false,
        readLater: true,
      ),
      Book(
        path: "C:\\",
        title: "Hokkaido Gals Are Super Adorable: Volume 1",
        link: "link",
        series: "Hokkaido Gals Are Super Adorable",
        authors: ["Ikada Kai"],
        tags: ["Romance", "Comedy"],
        characters: ["Fuyuki Minami", "Akino Sayuri", "Shiki Tsubasa"],
        favorite: false,
        readLater: true,
      ),
    ];

    // iterate each book
    for (Book book in allBooks) {
      // iterate through the books tags
      for (String tag in book.tags) {
        // add them if not already in
        if (!allTags.contains(tag)) {
          allTags.add(tag);
        }
      }

      // iterate trhough the books characters
      for (String character in book.characters) {
        // add them if not already in
        if (!allCharacters.contains(character)) {
          allCharacters.add(character);
        }
      }

      // iterate trhough the books characters
      for (String author in book.authors) {
        // add them if not already in
        if (!allAuthors.contains(author)) {
          allAuthors.add(author);
        }
      }

      // add series if not already in
      if (!allSeries.contains(book.series)) {
        allSeries.add(book.series);
      }
    }
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
                            all: allSeries,
                            onSelected: (sel) => setState(() {
                              // add sel to book.tags if it’s not already there
                              if (widget.book.series != sel) {
                                widget.book.series = sel;
                              }
                              // TODO: this prob needs changed when implementing database
                              if (!allSeries.contains(sel)) allSeries.add(sel);
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
                            allItems: allAuthors,
                            onAdded: (sel) => setState(() {
                              // add sel to book.authors if it’s not already there
                              if (!widget.book.authors.contains(sel)) {
                                widget.book.authors.add(sel);
                              }
                              // TODO: this prob needs changed when implementing database
                              if (!allAuthors.contains(sel))
                                allAuthors.add(sel);
                            }),
                            onRemoved: (author) => setState(() {
                              widget.book.authors.remove(author);
                            }),
                          ),
                        ),
                        // tags
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "tag",
                            item: widget.book.tags,
                            allItems: allTags,
                            onAdded: (sel) => setState(() {
                              // add sel to book.tags if it’s not already there
                              if (!widget.book.tags.contains(sel)) {
                                widget.book.tags.add(sel);
                              }
                              // TODO: this prob needs changed when implementing database
                              if (!allTags.contains(sel)) allTags.add(sel);
                            }),
                            onRemoved: (tag) => setState(() {
                              widget.book.tags.remove(tag);
                            }),
                          ),
                        ),
                        // characters
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "character",
                            item: widget.book.characters,
                            allItems: allCharacters,
                            onAdded: (sel) => setState(() {
                              // add sel to book.chars if it’s not already there
                              if (!widget.book.characters.contains(sel)) {
                                widget.book.characters.add(sel);
                              }
                              // TODO: this prob needs changed when implementing database
                              if (!allCharacters.contains(sel))
                                allCharacters.add(sel);
                            }),
                            onRemoved: (character) => setState(() {
                              widget.book.characters.remove(character);
                            }),
                          ),
                        ),
                        // explorer and delete
                        Row(
                          children: [
                            ExplorerButton(onExplorer: () {
                              Process.run("explorer", [widget.book.path]);
                            }),
                            DeleteButton(onDelete: () {
                              // delete logic here
                            }),
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
