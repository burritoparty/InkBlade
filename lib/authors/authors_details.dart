import 'package:flutter/material.dart';
import '../services/book_repository.dart';
import '../models/book.dart';
import '../router/routes.dart';
import '../widgets/widgets.dart';

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
  late List<String> allAuthors = [];
  late final List<Book> allBooks;
  late List<Book> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _author = widget.author;

    // get all the books
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

    // look through the books and only load up the ones with author
    for (Book book in allBooks) {
      // add every author to the dropdown
      if (!allAuthors.contains(book.author)) {
        allAuthors.add(book.author);
      }
      // if author matches author add to list
      // TODO this may cause an error when changing the author name
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
          // AuthorAutocompleteField(
          //   initialAuthor: _author,
          //   allAuthors: widget.allAuthors,
          //   onSelected: (sel) {
          //     setState(() {
          //       _author = sel;
          //       debugPrint('Selected author: $sel');
          //     });
          //   },
          // ),

          AuthorEditor(
            initialAuthor: _author,
            allAuthors: [],
            onSelected: (sel) => setState(() {
              // add sel to book.tags if it’s not already there
              if (_author != sel) {
                _author = sel;
              }
              // TODO: this prob needs changed when implementing database
              if (!allAuthors.contains(sel)) allAuthors.add(sel);
            }),
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

// class AuthorAutocompleteField extends StatelessWidget {
//   final String initialAuthor;
//   final List<String> allAuthors;
//   final ValueChanged<String> onSelected;

//   const AuthorAutocompleteField({
//     Key? key,
//     required this.initialAuthor,
//     required this.allAuthors,
//     required this.onSelected,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Autocomplete<String>(
//         initialValue: TextEditingValue(text: initialAuthor),
//         optionsBuilder: (TextEditingValue textEditingValue) {
//           final input = textEditingValue.text.toLowerCase();
//           return allAuthors.where(
//             (a) => a.toLowerCase().contains(input),
//           );
//         },
//         onSelected: onSelected,
//         fieldViewBuilder: (
//           BuildContext context,
//           TextEditingController textEditingController,
//           FocusNode focusNode,
//           VoidCallback onFieldSubmitted,
//         ) {
//           return TextField(
//             controller: textEditingController,
//             focusNode: focusNode,
//             decoration: const InputDecoration(
//               labelText: 'Author',
//               border: OutlineInputBorder(),
//             ),
//             onSubmitted: (_) => onFieldSubmitted(),
//           );
//         },
//       ),
//     );
//   }
// }
