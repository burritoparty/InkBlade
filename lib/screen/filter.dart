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
  // grab the authors
  List<String> allAuthors = [];
  // grab the tags
  List<String> allTags = [];
  // grab the series
  List<String> allSeries = [];
  // grab the characters
  List<String> allCharacters = [];

  // results
  String title = '';
  late List<String> authors = [];
  late List<String> tags = [];
  late List<String> characters = [];
  late List<String> series = [];

  @override
  void initState() {
    super.initState();
    // set up all books
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
    // set up filtered books
    filteredBooks = List.from(allBooks);

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

  // call any time author, or tags change
  void _applyFilters() {
    setState(
      () {
        filteredBooks = allBooks.where(
          (book) {
            // final matchesTitle = title.isEmpty ||
            //     book.title.toLowerCase().contains(title.toLowerCase());
            // final matchesAuthor = author.isEmpty ||
            //     book.authors.toLowerCase() == author.toLowerCase();
            final matchesSeries = book.series.isEmpty ||
                series.every((series) => book.series.contains(series));
            final matchesTags =
                tags.isEmpty || tags.every((tag) => book.tags.contains(tag));
            final matchesAuthors = authors.isEmpty ||
                authors.every((author) => book.authors.contains(author));
            final matchesCharacters = characters.isEmpty ||
                characters
                    .every((character) => book.characters.contains(character));
            // return matchesTitle && matchesAuthor && matchesTags;
            return matchesAuthors &&
                matchesSeries &&
                matchesTags &&
                matchesCharacters;
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StringSearch(
                  name: "Series",
                  all: allSeries,
                  onSelected: (value) {
                    // update the value
                    series.clear();
                    series.add(value);
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
                child: ListSearch(
                  name: "Tags",
                  all: allTags,
                  onAdded: (value) => setState(() {
                    // update the value
                    tags.add(value);
                    // call the function to update filtered
                    _applyFilters();
                  }),
                  onRemoved: (value) => setState(
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListSearch(
                  name: "Authors",
                  all: allAuthors,
                  onAdded: (value) => setState(() {
                    // update the value
                    authors.add(value);
                    // call the function to update filtered
                    _applyFilters();
                  }),
                  onRemoved: (value) => setState(
                    () {
                      // update the value
                      authors.remove(value);
                      // call the function to update filtered
                      _applyFilters();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListSearch(
                  name: "Characters",
                  all: allCharacters,
                  onAdded: (value) => setState(() {
                    // update the value
                    characters.add(value);
                    // call the function to update filtered
                    _applyFilters();
                  }),
                  onRemoved: (value) => setState(
                    () {
                      // update the value
                      characters.remove(value);
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

// search field
class StringSearch extends StatelessWidget {
  final String name;
  final List<String> all;
  final ValueChanged<String> onSelected;

  const StringSearch({
    Key? key,
    required this.name,
    required this.all,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue txt) {
        if (txt.text.isEmpty) return const Iterable<String>.empty();
        final input = txt.text.toLowerCase();
        return all.where((a) => a.toLowerCase().contains(input));
      },
      onSelected: onSelected,
      fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: name,
            border: const OutlineInputBorder(),
          ),
          // <-- add this
          onChanged: (value) {
            if (value.isEmpty) {
              onSelected(''); // reset state
            }
          },
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }
}

// list search
class ListSearch extends StatefulWidget {
  final String name;
  final List<String> all;
  final ValueChanged<String> onAdded;
  final ValueChanged<String> onRemoved;
  final int flex;

  const ListSearch({
    Key? key,
    required this.name,
    required this.all,
    required this.onAdded,
    required this.onRemoved,
    this.flex = 2,
  }) : super(key: key);

  @override
  ListSearchState createState() => ListSearchState();
}

class ListSearchState extends State<ListSearch> {
  // internal list
  final List<String> _all = [];

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
            return widget.all.where((a) => a.toLowerCase().contains(input));
          },
          onSelected: (item) {
            // add to internal list
            if (!_all.contains(item)) {
              setState(() {
                _all.add(item);
              });
              widget.onAdded(item);
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
              decoration: InputDecoration(
                labelText: widget.name,
                border: const OutlineInputBorder(),
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
            children: _all.map(
              (item) {
                return InputChip(
                  label: Text(item),
                  onDeleted: () {
                    // remove from internal list
                    setState(() {
                      _all.remove(item);
                    });
                    widget.onRemoved(item);
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
