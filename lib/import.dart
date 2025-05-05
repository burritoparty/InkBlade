import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import '/widgets/widgets.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  Book book = Book("", "", "", "", [], [], [], false, false);
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

  @override
  void initState() {
    super.initState();

    // set up all books, make one a fave
    allBooks = [
      Book(
        "C:\\", // path
        "Full Metal Alchemist Brotherhood", // title
        "link", // link
        "Full Metal Alchemist", // series
        ["Hiromu Arakawa"], // author
        ["Adventure", "Fantasy"], // tags
        ["Edward", "Alphonse", "Winry"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 1", // title
        "link", // link
        "My Dress Up Darling", // series
        ["Shinichi Fukuda"], // author
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "My Dress Up Darling: Volume 2", // title
        "link", // link
        "My Dress Up Darling", // series
        ["Shinichi Fukuda"], // author
        ["Romance", "Comedy", "Cosplay"], // tags
        ["Marin Kitagawa", "Wakana Gojo"], // characters
        true, // favorite
        false, // read later
      ),
      Book(
        "C:\\", // path
        "Komi Can't Communicate: Volume 1", // title
        "link", // link
        "Komi Can't Communicate", // series
        ["Tomohito Oda"], // author
        ["Romance", "Comedy", "Slice of Life"], // tags
        ["Komi Shoko", "Tadano Hitohito"], // characters
        false, // favorite
        true, // read later
      ),
      Book(
        "C:\\", // path
        "Hokkaido Gals Are Super Adorable: Volume 1", // title
        "link", // link
        "Hokkaido Gals Are Super Adorable", // series
        ["Ikada Kai"], // author
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
        TextEditingController(text: book.title);
    final TextEditingController linkController =
        TextEditingController(text: book.link);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              onPressed: () {},
              label: const Text("Import book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                // minimumSize: const Size.fromHeight(48),
              ),
            )
          ],
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // add button
          const Expanded(child: CoverImage()),
          // details column
          Expanded(
            flex: 2,
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                        child: LaterButton(
                          isReadLater: book.readLater,
                          onReadLaterToggle: (newVal) => setState(() {
                            book.readLater = newVal;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: StringEditor(
                            name: "Title",
                            controller: titleController,
                            onSubmitted: (newTitle) => setState(() {
                              book.title = newTitle;
                            }),
                          ),
                        ),
                        Expanded(
                          child: DropdownEditor(
                            name: "Series",
                            initial: book.series,
                            all: allSeries,
                            onSelected: (sel) => setState(() {
                              book.series = sel;
                              if (!allSeries.contains(sel)) {
                                allSeries.add(sel);
                              }
                            }),
                          ),
                        ),
                        Expanded(
                          child: StringEditor(
                            name: "Link",
                            controller: linkController,
                            onSubmitted: (newLink) => setState(() {
                              book.link = newLink;
                            }),
                          ),
                        ),
                        Expanded(
                          child: ListEditor(
                            name: "author",
                            item: book.authors,
                            allItems: allAuthors,
                            onAdded: (sel) => setState(() {
                              if (!book.authors.contains(sel)) {
                                book.authors.add(sel);
                              }
                              if (!allAuthors.contains(sel)) allAuthors.add(sel);
                            }),
                            onRemoved: (author) => setState(() {
                              book.authors.remove(author);
                            }),
                          ),
                        ),
                        Expanded(
                          child: ListEditor(
                            name: "tag",
                            item: book.tags,
                            allItems: allTags,
                            onAdded: (sel) => setState(() {
                              if (!book.tags.contains(sel)) {
                                book.tags.add(sel);
                              }
                              if (!allTags.contains(sel)) allTags.add(sel);
                            }),
                            onRemoved: (tag) => setState(() {
                              book.tags.remove(tag);
                            }),
                          ),
                        ),
                        Expanded(
                          child: ListEditor(
                            name: "character",
                            item: book.characters,
                            allItems: allCharacters,
                            onAdded: (sel) => setState(() {
                              if (!book.characters.contains(sel)) {
                                book.characters.add(sel);
                              }
                              if (!allCharacters.contains(sel)) {
                                allCharacters.add(sel);
                              }
                            }),
                            onRemoved: (character) => setState(() {
                              book.characters.remove(character);
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
