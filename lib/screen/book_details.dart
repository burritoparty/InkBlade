import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/book.dart';

class BookDetails extends StatefulWidget {
  final Book book;
  const BookDetails({super.key, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  @override
  Widget build(BuildContext context) {
    // controller for text editing field
    final TextEditingController titleController =
        TextEditingController(text: widget.book.name);

    // mock data
    // grab the authors
    List<String> allAuthors = [];
    for (int i = 0; i < 1000; i++) {
      allAuthors.add("authorname$i");
    }
    List<String> allTags = [];
    for (int i = 0; i < 15; i++) {
      allTags.add("tagname$i");
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cover image
            const Expanded(
              // modify flex for how much space is taken
              flex: 1,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Placeholder(),
              ),
            ),
            // details column
            Expanded(
              // modify flex for how much space is taken
              flex: 2,
              // pad out from the image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // name of the book
                children: [
                  // title
                  Padding(
                    // specify padding only from top and bottom
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (newTitle) => setState(() {
                        widget.book.name = newTitle;
                      }),
                    ),
                  ),
                  // author handling
                  Padding(
                    // specify padding only from top and bottom
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Autocomplete<String>(
                      initialValue: TextEditingValue(text: widget.book.author),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return allAuthors.where((a) => a
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (sel) {
                        setState(() {
                          debugPrint('Selected author: $sel');
                          widget.book.author = sel;
                        });
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
                            labelText: 'Author',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            // tell the autocomplete to treat this as a selection
                            onFieldSubmitted();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // tag handling
            // TODO: modify how tags are handled
            Expanded(
              // modify flex for how much space is taken
              flex: 1,
              child: Column(
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return allTags.where((a) => a
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    // when selected
                    onSelected: (sel) => debugPrint('Selected tag: $sel'),
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
                        onSubmitted: (value) => setState(() {
                          widget.book.tags.add(value);
                        }),
                      );
                    },
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: widget.book.tags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InputChip(
                            label: Text(tag),
                            onDeleted: () => setState(() {
                              widget.book.tags.remove(tag);
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
