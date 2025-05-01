import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/models/book.dart';
import '/widgets/widgets.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  Book book = Book("", "", [], "", "", "", false, false);
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
                      book.author = sel;
                      debugPrint('Selected author: $sel');
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
            Expanded(
              child: TagEditor(
                tags: book.tags,
                allTags: allTags,
                onTagAdded: (sel) => setState(() {
                  book.tags.add(sel);
                  debugPrint('Selected tag: $sel');
                }),
                onTagRemoved: (tag) => setState(() {
                  book.tags.remove(tag);
                }),
                flex: 1, // this modifies how much room tags are taking
              ),
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
