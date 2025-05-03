import 'package:flutter/material.dart';
import '../models/book.dart';

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
        "Full Metal Alchemist",
        "Hiromu Arakawa",
        ["Adventure", "Fantasy"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
      ),
      Book(
        "My Dress Up Darling",
        "Shinichi Fukuda",
        ["Romance", "Comedy", "Cosplay"],
        "link",
        "C:\\path",
        "coverPath",
        true,
        true,
      ),
      Book(
        "Komi Can't Communicate",
        "Tomohito Oda",
        ["Romance", "Comedy"],
        "link",
        "C:\\path",
        "coverPath",
        false,
        false,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TitleSearch(initialValue: title,
          onChanged: (value) {
            title = value;
          },),
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
                      author = value;
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
                      tags.add(value);
                    }),
                    onTagRemoved: (value) => setState(() {
                      tags.remove(value);
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Make TitleSearch a *stateless* widget that just reflects
// the value you hand in, and tells you whenever it changes:

class TitleSearch extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const TitleSearch({
    Key? key,
    this.initialValue = '',
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // create a controller so the textfield shows the current title
    final controller = TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Title',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}


// author search field
class AuthorSearch extends StatelessWidget {
  // final String initialAuthor;
  final List<String> allAuthors;
  final ValueChanged<String> onSelected;

  const AuthorSearch({
    Key? key,
    // required this.initialAuthor,
    required this.allAuthors,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // initialValue: TextEditingValue(text: initialAuthor),
      optionsBuilder: (TextEditingValue textEditingValue) {
        // don't show options until something is typed
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final input = textEditingValue.text.toLowerCase();
        return allAuthors.where((a) => a.toLowerCase().contains(input));
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
            return widget.allTags
                .where((a) => a.toLowerCase().contains(input));
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
