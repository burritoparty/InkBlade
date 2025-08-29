// Third-party package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project-specific imports
import '../controllers/library_controller.dart';
import '../models/book.dart';
import '../router/routes.dart';
import '../widgets/book_grid.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
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
    // access LibraryController
    final libraryController = context.read<LibraryController>();
    // set up all books from LibraryController
    allBooks = libraryController.books;
    // set up filtered books
    filteredBooks = List.from(allBooks);
    // populate filters authors, tags, series, characters
    for (Book book in allBooks) {
      for (String tag in book.tags) {
        if (!allTags.contains(tag)) {
          allTags.add(tag);
        }
      }
      for (String character in book.characters) {
        if (!allCharacters.contains(character)) {
          allCharacters.add(character);
        }
      }
      for (String author in book.authors) {
        if (!allAuthors.contains(author)) {
          allAuthors.add(author);
        }
      }
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
            final matchesSeries = series.isEmpty ||
                series.every((tag) => book.series.contains(tag));
            final matchesTags =
                tags.isEmpty || tags.every((tag) => book.tags.contains(tag));
            final matchesAuthors = authors.isEmpty ||
                authors.every((author) => book.authors.contains(author));
            final matchesCharacters = characters.isEmpty ||
                characters
                    .every((character) => book.characters.contains(character));
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
    // set up the library controller, which holds the list of books
    // it watches for changes to the list of books, and rebuilds the widget tree
    final libraryController = context.watch<LibraryController>();
    allBooks = libraryController.books;
    // will reapply filters when the library changes
    _applyFilters();
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
                arguments: index,
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
