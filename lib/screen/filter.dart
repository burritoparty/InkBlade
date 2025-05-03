import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_repository.dart';
import '../router/routes.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  // TODO need to pass in object with all books
  // filtering tools
  late List<Book> allBooks = [];
  late List<Book> filteredBooks = [];
  late List<String> allAuthors = [];
  late List<String> allTags = [];
  // results
  String title = '';
  late String author = '';
  late List<String> tags = [];
  @override
  void initState() {
    super.initState();
    // set up all books
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

    // loop thru the books get all stuff
    for (Book book in allBooks) {
      if (!allAuthors.contains(book.author)) {
        allAuthors.add(book.author);
      }
    }
    for (Book book in allBooks) {
      for (String tag in book.tags) {
        if (!allTags.contains(tag)) {
          allTags.add(tag);
        }
      }
    }
  }

  // call any time author, or tags change
  void _applyFilters() {
    setState(
      () {
        filteredBooks = allBooks.where(
          (book) {
            // final matchesTitle = title.isEmpty ||
            //     book.title.toLowerCase().contains(title.toLowerCase());
            final matchesAuthor = author.isEmpty ||
                book.author.toLowerCase() == author.toLowerCase();
            final matchesTags =
                tags.isEmpty || tags.every((tag) => book.tags.contains(tag));
            // return matchesTitle && matchesAuthor && matchesTags;
            return matchesAuthor && matchesTags;
          },
        ).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          // align both inputs at the top
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // author field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AuthorSearch(
                  allAuthors: allAuthors,
                  onSelected: (value) {
                    // update the value
                    author = value;
                    // call the function to update filtered
                    _applyFilters();
                  },
                ),
              ),
            ),
            // tag field + chips
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TagSearch(
                  allTags: allTags,
                  onTagAdded: (value) => setState(() {
                    // update the value
                    tags.add(value);
                    // call the function to update filtered
                    _applyFilters();
                  }),
                  onTagRemoved: (value) => setState(
                    () {
                      // update the value
                      tags.remove(value);
                      // call the function to update filtered
                      _applyFilters();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        // grid uses filteredBooks
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
    );
  }
}

// author search field
class AuthorSearch extends StatelessWidget {
  final List<String> allAuthors;
  final ValueChanged<String> onSelected;

  const AuthorSearch({
    Key? key,
    required this.allAuthors,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue txt) {
        if (txt.text.isEmpty) return const Iterable<String>.empty();
        final input = txt.text.toLowerCase();
        return allAuthors.where((a) => a.toLowerCase().contains(input));
      },
      onSelected: onSelected,
      fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Author',
            border: OutlineInputBorder(),
          ),
          // <-- add this
          onChanged: (value) {
            if (value.isEmpty) {
              onSelected(''); // reset your author state
            }
          },
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }
}

// tag search
class TagSearch extends StatefulWidget {
  final List<String> allTags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final int flex;

  const TagSearch({
    Key? key,
    required this.allTags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.flex = 2,
  }) : super(key: key);

  @override
  TagSearchState createState() => TagSearchState();
}

class TagSearchState extends State<TagSearch> {
  // internal list of tags
  final List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            // don't show options until something is typed
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            final input = textEditingValue.text.toLowerCase();
            return widget.allTags.where((a) => a.toLowerCase().contains(input));
          },
          onSelected: (tag) {
            // add tag to internal list
            if (!_tags.contains(tag)) {
              setState(() {
                _tags.add(tag);
              });
              widget.onTagAdded(tag);
            }
          },
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
                labelText: 'Add tag',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                // autocomplete logic
                onFieldSubmitted();
                // clear what user typed
                textEditingController.clear();
                // keep focus
                focusNode.requestFocus();
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _tags.map(
              (tag) {
                return InputChip(
                  label: Text(tag),
                  onDeleted: () {
                    // remove tag from internal list
                    setState(() {
                      _tags.remove(tag);
                    });
                    widget.onTagRemoved(tag);
                  },
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}

// To add later maybe
// class TitleSearch extends StatefulWidget {
//   final String initialValue;
//   final ValueChanged<String> onChanged;

//   const TitleSearch({
//     Key? key,
//     this.initialValue = '',
//     required this.onChanged,
//   }) : super(key: key);

//   @override
//   TitleSearchState createState() => TitleSearchState();
// }

// class TitleSearchState extends State<TitleSearch> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.initialValue);
//   }

//   @override
//   void didUpdateWidget(covariant TitleSearch old) {
//     super.didUpdateWidget(old);
//     if (old.initialValue != widget.initialValue) {
//       // only update if the parent really changed it:
//       _controller.text = widget.initialValue;
//       // place cursor at end
//       _controller.selection = TextSelection.fromPosition(
//         TextPosition(offset: _controller.text.length),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: TextField(
//         controller: _controller,
//         decoration: const InputDecoration(
//           labelText: 'Title',
//           border: OutlineInputBorder(),
//         ),
//         onChanged: widget.onChanged,
//       ),
//     );
//   }
// }
