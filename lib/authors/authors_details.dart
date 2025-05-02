import 'package:flutter/material.dart';
import '../services/book_repository.dart';
import '../models/book.dart';
import '../router/routes.dart';

class AuthorDetails extends StatefulWidget {
  final String author;
  final List<String> allAuthors;

  const AuthorDetails({
    super.key,
    required this.author,
    required this.allAuthors,
  });

  @override
  State<AuthorDetails> createState() => AuthorDetailsState();
}

class AuthorDetailsState extends State<AuthorDetails> {
  late String _author;
  late final List<Book> allBooks;
  late List<Book> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _author = widget.author;

    // get all the books
    allBooks = [
      Book(
        "name1",
        "Shinichi Fukuda",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
      ),
      Book(
        "name2",
        "Shinichi Fukuda",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
      ),
      Book(
        "name1",
        "Hiromu Arakawa",
        ["tag1", "tag2", "tag3"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
      ),
    ];

    // look through the books and only load up the ones with author
    // for (int i = 0; i < allBooks.length; i++) {
    //   if () {

    //   }
    // }
    for (Book book in allBooks) {
      if (book.author == _author) {
        filteredBooks.add(book);
      }
    }
    // filteredBooks = List.of(allBooks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_author),
      ),
      body: Column(
        children: [
          AuthorAutocompleteField(
            initialAuthor: _author,
            allAuthors: widget.allAuthors,
            onSelected: (sel) {
              setState(() {
                _author = sel;
                debugPrint('Selected author: $sel');
              });
            },
          ),
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
          )
        ],
      ),
    );
  }
}

class AuthorAutocompleteField extends StatelessWidget {
  final String initialAuthor;
  final List<String> allAuthors;
  final ValueChanged<String> onSelected;

  const AuthorAutocompleteField({
    Key? key,
    required this.initialAuthor,
    required this.allAuthors,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: initialAuthor),
        optionsBuilder: (TextEditingValue textEditingValue) {
          final input = textEditingValue.text.toLowerCase();
          return allAuthors.where(
            (a) => a.toLowerCase().contains(input),
          );
        },
        onSelected: onSelected,
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Author',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onFieldSubmitted(),
          );
        },
      ),
    );
  }
}
