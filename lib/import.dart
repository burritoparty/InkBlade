import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import '/widgets/widgets.dart';
import '../controllers/library_controller.dart';
import 'package:provider/provider.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  late final LibraryController libraryController;
  // controller for text editing field
  final TextEditingController titleController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  Book newBook = Book(
    path: "",
    title: "",
    authors: [],
    series: "",
    tags: [],
    characters: [],
    link: "",
    favorite: false,
    readLater: false,
  );

  @override
  void initState() {
    super.initState();
    // initialize the library controller
    libraryController = context.read<LibraryController>();
    // controller for text editing field
    titleController.text = newBook.title;
    linkController.text = newBook.link;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.check,
                size: 24, // Slightly larger icon
              ),
              onPressed: () {},
              label: const Text(
                "Import book",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
            )
          ],
        ),
      ),
      body: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            // column for the left side
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // row for the favorite and read later buttons
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FavoriteButton(
                          isFavorite: newBook.favorite,
                          onFavoriteToggle: (newVal) => setState(
                            () {
                              newBook.favorite = newVal;
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LaterButton(
                          isReadLater: newBook.readLater,
                          onReadLaterToggle: (newVal) => setState(
                            () {
                              newBook.readLater = newVal;
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CoverImage(),
                )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              // pad from bottom to allow for the dropdown to be visible
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 200),
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
                            onSubmitted: (newTitle) => setState(() {
                              newBook.title = newTitle;
                            }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "author",
                            item: newBook.authors,
                            // convert set to list for the editor
                            allItems: libraryController.authors.toList(),
                            onAdded: (sel) => setState(() {
                              // add them if not already in
                              if (!newBook.authors.contains(sel)) {
                                newBook.authors.add(sel);
                              }
                            }),
                            onRemoved: (author) => setState(() {
                              // remove them if already in
                              newBook.authors.remove(author);
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
                            initial: newBook.series,
                            // convert set to list for the editor
                            all: libraryController.series.toList(),
                            onSelected: (sel) => setState(() {}),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "tag",
                            item: newBook.tags,
                            // convert set to list for the editor
                            allItems: libraryController.tags.toList(),
                            onAdded: (sel) => setState(() {
                              // if new tag add to list
                              if (!newBook.tags.contains(sel)) {
                                newBook.tags.add(sel);
                              }
                            }),
                            onRemoved: (tag) => setState(() {
                              // remove them if already in
                              newBook.tags.remove(tag);
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
                              newBook.link = newLink;
                            }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "character",
                            item: newBook.characters,
                            // convert set to list for the editor
                            allItems: libraryController.characters.toList(),
                            onAdded: (sel) => setState(() {
                              // if new character add to list
                              if (!newBook.characters.contains(sel)) {
                                newBook.characters.add(sel);
                              }
                            }),
                            onRemoved: (character) => setState(() {
                              // remove them if already in
                              newBook.characters.remove(character);
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
      color: Colors.grey[800],
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
