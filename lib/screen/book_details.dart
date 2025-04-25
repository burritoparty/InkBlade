import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/book.dart';

class BookDetails extends StatelessWidget {
  final Book book;
  const BookDetails({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // controller for text editing field
    final TextEditingController titleController =
        TextEditingController(text: book.name);

    // mock data
    // grab the authors
    List<String> authors = [];
    for (int i = 0; i < 1000; i++) {
      authors.add("authorname$i");
    }
    List<String> tags = [];
    for (int i = 0; i < 15; i++) {
      tags.add("tagname$i");
    }

    return Scaffold(
      appBar: AppBar(title: Text(book.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cover image
            const Flexible(
              child: FractionallySizedBox(
                widthFactor: 0.3, // 30% of the rows width
                child: AspectRatio(
                  // use your cover’s width/height ratio, e.g. 100/150 == 2/3
                  aspectRatio: 2 / 3,
                  // TODO insert actual image
                  child: Placeholder(),
                ),
              ),
            ),
            // details column
            Expanded(
              // pad out from the image
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // name of the book
                  children: [
                    // title
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (newTitle) {
                          debugPrint(newTitle);
                          // TODO change details 
                          // update appbar, and json?
                          // does this update globaly?
                        },
                      ),
                    ),
                    // author handling
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Autocomplete<String>(
                        // set initial value
                        initialValue: TextEditingValue(text: book.author),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return authors.where((a) => a
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        // when selected
                        onSelected: (sel) =>
                          // TODO:
                          // update appbar, and json?
                          // does this update globaly?
                          debugPrint('Selected author: $sel'),
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
                            onSubmitted: (value) => onFieldSubmitted(),
                          );
                        },
                      ),
                    ),
                    // tag handling
                    // TODO: modify how tags are handled
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Tags: ${book.tags.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
