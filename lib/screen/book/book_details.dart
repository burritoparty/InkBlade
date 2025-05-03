import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import 'package:flutter_manga_reader/widgets/character_editor.dart';
import 'package:flutter_manga_reader/widgets/series_editor.dart';
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
  int totalPages = 30;

  @override
  void initState() {
    super.initState();

    // set up all books, make one a fave
    allBooks = [
      Book(
        "C:\\", // path
        "Full Metal Alchemist Brotherhood", // title
        "Hiromu Arakawa", // author
        "link", // link
        "Full Metal Alchemist", // series
        ["Adventure", "Fantasy"], // tags
        ["Edward", "Alphonse", "Winry"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 1", // title
        "Shinichi Fukuda", // author
        "link", // link
        "My Dress Up Darling", // series
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 2", // title
        "Shinichi Fukuda", // author
        "link", // link
        "My Dress Up Darling", // series
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Wakana Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "Komi Can't Communicate: Volume 1", // title
        "Tomohito Oda", // author
        "link", // link
        "Komi Can't Communicate", // series
        ["Romance", "Comedy", "Slice of Life"], // tags
        ["Komi Shoko", "Tadano Hitohito"], // characters
        false, // favorite
        true, // read later
      ),
      Book(
        "C:\\", // path
        "Hokkaido Gals Are Super Adorable: Volume 1", // title
        "Ikada Kai", // author
        "link", // link
        "Hokkaido Gals Are Super Adorable", // series
        ["Romance", "Comedy"], // tags
        ["Fuyuki Minami", "Akino Sayuri", "Shiki Tsubasa"], // characters
        false, // favorite
        true, // read later
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

      // add author if not already in
      if (!allAuthors.contains(book.author)) {
        allAuthors.add(book.author);
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
                        // title
                        TitleEditor(
                          controller: titleController,
                          onSubmitted: (newTitle) => setState(() {
                            widget.book.title = newTitle;
                          }),
                        ),
                        SeriesEditor(
                          initialSeries: widget.book.series,
                          allSeries: allSeries,
                          onSelected: (sel) => setState(() {
                            // add sel to book.tags if it’s not already there
                            if (widget.book.series != sel) {
                              widget.book.series = sel;
                            }
                            // TODO: this prob needs changed when implementing database
                            if (!allSeries.contains(sel)) allSeries.add(sel);
                          }),
                        ),
                        AuthorEditor(
                          initialAuthor: widget.book.author,
                          allAuthors: allAuthors,
                          onSelected: (sel) => setState(() {
                            // add sel to book.tags if it’s not already there
                            if (widget.book.author != sel) {
                              widget.book.author = sel;
                            }
                            // TODO: this prob needs changed when implementing database
                            if (!allAuthors.contains(sel)) allAuthors.add(sel);
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
                  // tag handling
                  Expanded(
                    child: Column(
                      children: [
                        TagEditor(
                          tags: widget.book.tags,
                          allTags: allTags,
                          onTagAdded: (sel) => setState(() {
                            // add sel to book.tags if it’s not already there
                            if (!widget.book.tags.contains(sel)) {
                              widget.book.tags.add(sel);
                            }
                            // TODO: this prob needs changed when implementing database
                            if (!allTags.contains(sel)) allTags.add(sel);
                          }),
                          onTagRemoved: (tag) => setState(() {
                            widget.book.tags.remove(tag);
                          }),
                          flex: 2,
                        ),
                        CharacterEditor(
                          characters: widget.book.characters,
                          allCharacters: allCharacters,
                          onCharacterAdded: (sel) => setState(() {
                            // add sel to book.chars if it’s not already there
                            if (!widget.book.characters.contains(sel)) {
                              widget.book.characters.add(sel);
                            }
                            // TODO: this prob needs changed when implementing database
                            if (!allCharacters.contains(sel))
                              allCharacters.add(sel);
                          }),
                          onCharacterRemoved: (character) => setState(() {
                            widget.book.characters.remove(character);
                          }),
                          flex: 2,
                        ),
                      ],
                    ),
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
