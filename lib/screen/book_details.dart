import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/book.dart';
import 'dart:io';

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
    // controller for link editing field
    final TextEditingController linkController =
        TextEditingController(text: widget.book.link);

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
    int imagesPerRow = 10;
    int totalPages = 30;

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            initialValue:
                                TextEditingValue(text: widget.book.author),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              return allAuthors.where((a) => a
                                  .toLowerCase()
                                  .contains(
                                      textEditingValue.text.toLowerCase()));
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
                        // Link handling
                        Padding(
                          // specify padding only from top and bottom
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: TextField(
                            controller: linkController,
                            decoration: const InputDecoration(
                              labelText: "Link",
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (newLink) => setState(() {
                              widget.book.link = newLink;
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            // HERE
                            children: [
                              // favorite
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        widget.book.favorite =
                                            !widget.book.favorite;
                                      });
                                    },
                                    icon: Icon(
                                      widget.book.favorite
                                          ? Icons.favorite
                                          : Icons.heart_broken_outlined,
                                    ),
                                    label: const Text('Favorite'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                              ),
                              // read later
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        widget.book.readLater =
                                            !widget.book.readLater;
                                      });
                                    },
                                    icon: Icon(
                                      widget.book.readLater
                                          ? Icons.bookmark_added
                                          : Icons.bookmark_add_outlined,
                                    ),
                                    label: const Text('Read Later'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              // open file location
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // TODO replace with widget.book.path
                                      Process.run("explorer", [""]);
                                    },
                                    icon: const Icon(Icons.folder),
                                    label: const Text('Explorer'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                              ),
                              // delete book
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        // TODO: delete the book
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete Book'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // tag handling
                  // TODO: modify how tags are handled
                  Expanded(
                    // modify flex for how much space is taken
                    flex: 2,
                    child: Column(
                      crossAxisAlignment:
                          // align
                          CrossAxisAlignment.start,
                      children: [
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return allTags.where((a) => a
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          // when selected
                          onSelected: (sel) {
                            setState(() {
                              debugPrint('Selected tag: $sel');
                              widget.book.tags.add(sel);
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
                                labelText: 'Add tag',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (value) => setState(() {
                                onFieldSubmitted();
                              }),
                            );
                          },
                        ),
                        Padding(
                          // padding above the tag
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            // Use Wrap instead of ListView
                            spacing: 8.0, // space between chips
                            runSpacing: 4.0, // space between lines
                            children: widget.book.tags.map((tag) {
                              return InputChip(
                                label: Text(tag),
                                onDeleted: () => setState(() {
                                  widget.book.tags.remove(tag);
                                }),
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
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: imagesPerRow,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: totalPages,
                itemBuilder: (context, index) {
                  // TODO: replace with Image.File
                  return const Placeholder();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
