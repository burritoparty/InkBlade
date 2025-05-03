import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import '/widgets/widgets.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  Book book = Book("", "", [], "", "", false, false);
  List<String> allAuthors = [];
  List<String> allTags = [];

  @override
  void initState() {
    super.initState();
    // mock data
    // grab the authors
    for (int i = 0; i < 1000; i++) {
      allAuthors.add("authorname$i");
    }
    for (int i = 0; i < 15; i++) {
      allTags.add("tagname$i");
    }
  }

  @override
  Widget build(BuildContext context) {
    // controller for text editing field
    final TextEditingController titleController =
        TextEditingController(text: book.title);
    // set up the book to modify
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // ← makes the whole title widget centered
        title: Row(
          mainAxisSize:
              MainAxisSize.min, // ← shrink‐wrap so Row itself is centered
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
                        child: LaterButton(
                          isReadLater: book.readLater,
                          onReadLaterToggle: (newVal) => setState(() {
                            book.readLater = newVal;
                          }),
                        ),
                      ),
                    ),
                  ]),
                  // title handling
                  TitleEditor(
                      controller: titleController,
                      onSubmitted: (newTitle) => setState(() {
                            book.title = newTitle;
                          })),
                  // author handling
                  AuthorEditor(
                    initialAuthor: book.author,
                    allAuthors: allAuthors,
                    onSelected: (sel) => setState(() {
                      // TODO: may need to update all authors here?
                      // only add don't remove?
                      book.author = sel;
                      // add if it doesnt exist
                      if (!allAuthors.contains(sel)) {
                        allAuthors.add(sel);
                      }
                    }),
                  ),
                  // link handling
                  LinkEditor(
                    initialLink: book.link,
                    onSubmitted: (newLink) => setState(() {
                      book.link = newLink;
                    }),
                  ),
                ],
              ),
            ),
            // tags here
            TagEditor(
              tags: book.tags,
              allTags: allTags,
              onTagAdded: (sel) => setState(() {
                // add sel to book.tags if it’s not already there
                if (!book.tags.contains(sel)) {
                  book.tags.add(sel);
                }
                // TODO: this prob needs changed when implementing database
                if (!allTags.contains(sel)) allTags.add(sel);
              }),
              onTagRemoved: (tag) => setState(() {
                book.tags.remove(tag);
              }),
              flex: 1, // this modifies how much room tags are taking
            ),
          ],
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
