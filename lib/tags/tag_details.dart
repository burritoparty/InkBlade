import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/widgets/widgets.dart';
import '../router/routes.dart';
import '../services/book_repository.dart';
import '../models/book.dart';

class TagDetails extends StatefulWidget {
  final String tag;
  // const TagDetails({Key? key, required this.tag}) : super(key: key);
  const TagDetails({
    super.key,
    required this.tag,
  });

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
                  child: StringEditor(
                    name: "Rename tag",
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
