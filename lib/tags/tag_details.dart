import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/widgets/widgets.dart';
import '../router/routes.dart';
import '../services/book_repository.dart';
import '../models/book.dart';

class TagDetails extends StatefulWidget {
  final String tag;
  const TagDetails({Key? key, required this.tag}) : super(key: key);

  @override
  State<TagDetails> createState() => _TagDetailsState();
}

class _TagDetailsState extends State<TagDetails> {
  late TextEditingController _controller;
  late String _currentTag;
  late String _originalTag;
  final List<String> allTags = List.generate(15, (i) => 'tagname$i');
  late final List<Book> allBooks;
  late final List<Book> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _originalTag = widget.tag;
    _currentTag = widget.tag;
    _controller = TextEditingController(text: _currentTag);

    // TODO: be passed all books, and search for author
    // dummy data
    allBooks = List.generate(
      10,
      (i) => Book(
        "name$i",
        "author",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        // "coverPath",
        false,
        false,
      ),
    );
    // make a book with an author
    allBooks.add(Book(
        "Romance book",
        "author",
        ["Romance"],
        "link",
        "path",
        // "coverPath",
        false,
        false));

    // iterate through all books
    for (final Book book in allBooks) {
      // iterate through each tag
      for (final String tag in book.tags) {
        // if it finds a tag that matches
        if (tag == widget.tag) {
          // add it to the filtered books for the grid
          filteredBooks.add(book);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String newTag) {
    final oldTag = _originalTag;

    // replace tag on every book
    for (final Book book in allBooks) {
      for (int i = 0; i < book.tags.length; i++) {
        // if it finds the old tag, swap it out
        if (book.tags[i] == oldTag) {
          book.tags[i] = newTag;
        }
      }
    }

    // update master tag list
    final int idx = allTags.indexOf(oldTag);
    if (idx != -1) {
      allTags[idx] = newTag;
    }

    // update state and re-filter
    setState(() {
      _originalTag = newTag; // next rename uses this as oldTag
      _currentTag = newTag;
      _controller.text = newTag;
      filteredBooks
        ..clear()
        ..addAll(allBooks.where((b) => b.tags.contains(newTag)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentTag)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // edit tag name
            Row(
              children: [
                Expanded(
                  child: TitleEditor(
                    controller: _controller,
                    onSubmitted: _onSubmitted,
                  ),
                ),
                DeleteButton(onDelete: () {
                  // TODO: delete logic here
                }),
              ],
            ),
            // book grid
            Expanded(
              child: BookGrid(
                books: filteredBooks,
                onBookTap: (index) async {
                  await Navigator.pushNamed(
                    context,
                    Routes.details,
                    arguments: filteredBooks[index],
                  );
                  setState(() {}); // pick up any changes on return
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
