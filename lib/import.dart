// Standard Dart imports
import 'dart:io';

// Third-party package imports
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

// Project-specific imports
import '../controllers/library_controller.dart';
import '../controllers/settings_controller.dart';
import 'package:flutter_manga_reader/models/book.dart';
import '/widgets/widgets.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  late final LibraryController libraryController;
  late final SettingsController settingsController;
  // controller for text editing field
  final TextEditingController titleController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  Book newBook = Book(
    path: "",
    title: "",
    authors: [],
    series: "",
    tags: [],
    characters: [],
    link: "",
    favorite: false,
    readLater: false,
  );

  // Added to track if a valid folder with images has been selected
  bool _isValidFolderSelected = false;
  // version counter to notify title field that the parent programmatically saved the text
  int _titleSavedVersion = 0;

  @override
  void initState() {
    super.initState();
    // initialize the library controller
    libraryController = context.read<LibraryController>();
    // initialize the settings controller
    settingsController = context.read<SettingsController>();
    // controller for text editing field
    titleController.text = newBook.title;
    linkController.text = newBook.link;

    // Listen to changes in the titleController to re-evaluate validation
    titleController.addListener(_updateImportButtonState);
  }

  @override
  void dispose() {
    titleController.removeListener(_updateImportButtonState);
    titleController.dispose();
    linkController.dispose();
    super.dispose();
  }

  void _updateImportButtonState() {
    setState(() {
      // This will trigger a rebuild and re-evaluate the onPressed condition
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add a listener to the LibraryController for changes in library to update validation
    // This will ensure the title existence check is always up-to-date
    context.watch<LibraryController>();

    final bool isImportButtonEnabled = _isValidFolderSelected &&
        titleController.text.isNotEmpty &&
        !libraryController.doesBookTitleExist(titleController.text);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // navigate back to the home screen
              Navigator.popUntil(
                context,
                ModalRoute.withName('/'),
              );
            },
          ),
        ],
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.check,
                size: 24, // Slightly larger icon
              ),
              onPressed: isImportButtonEnabled
                  ? () async {
                      final originalPath = newBook.path;

                      try {
                        // copy into your app directory
                        await libraryController.addBook(newBook);

                        // only delete once the above is done
                        if (settingsController.autoDelete) {
                          final dir = Directory(originalPath);
                          if (await dir.exists()) {
                            await dir.delete(recursive: true);
                          }
                        }

                        // sort the library after adding a new book
                        libraryController.sortLibraryJsonByTitle();

                        // notify & pop
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Imported “${newBook.title}”')),
                        );
                        Navigator.of(context).pop();
                      } catch (e, st) {
                        // handle any errors (copy or delete) gracefully
                        debugPrint('Import error: $e\n$st');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to import “${newBook.title}”')),
                        );
                      }
                    }
                  : null, // Disable button if conditions are not met
              label: const Text(
                "Import book",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: isImportButtonEnabled
                    ? Colors.grey[800]
                    : Colors.grey[600], // Change color when disabled
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
            )
          ],
        ),
      ),
      body: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            // column for the left side
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // row for the favorite and read later buttons
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FavoriteButton(
                          isFavorite: newBook.favorite,
                          onFavoriteToggle: (newVal) => setState(
                            () {
                              newBook.favorite = newVal;
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LaterButton(
                          isReadLater: newBook.readLater,
                          onReadLaterToggle: (newVal) => setState(
                            () {
                              newBook.readLater = newVal;
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CoverImage(
                      folderPath: newBook.path,
                      onFolderSelected: (path) async {
                        // Check for images in the selected directory
                        final hasImages = await _checkDirectoryForImages(path);
                        setState(
                          () {
                            if (hasImages) {
                              newBook.path = path;
                              String title = p.basename(path);
                              title = cleanString(title);
                              titleController.text = title;
                              newBook.title = title;
                              _isValidFolderSelected = true;
                              // Notify the title editor that the parent has programmatically set and "saved" the title
                              _titleSavedVersion++;
                            } else {
                              newBook.path = ""; // Clear path if no images
                              _isValidFolderSelected = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Selected folder does not contain any image files (JPG, JPEG, PNG, WEBP).'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              // pad from bottom to allow for the dropdown to be visible
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 200),
              child: Column(
                // spaces out each row
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StringEditor(
                            name: "Title",
                            controller: titleController,
                            savedVersion: _titleSavedVersion,
                            onSubmitted: (newTitle) => setState(
                              () {
                                newBook.title = newTitle;
                              },
                            ),
                            // Optional: Add a validator or visual feedback here
                            // if you want to show issues as the user types
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "author",
                            item: newBook.authors,
                            // convert set to list for the editor
                            allItems: libraryController.authors.toList(),
                            onAdded: (sel) => setState(() {
                              // add them if not already in
                              if (!newBook.authors.contains(sel)) {
                                newBook.authors.add(sel);
                                newBook.authors.sort();
                              }
                            }),
                            onRemoved: (author) => setState(() {
                              // remove them if already in
                              newBook.authors.remove(author);
                              newBook.authors.sort();
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownEditor(
                            name: "Series",
                            initial: newBook.series,
                            // convert set to list for the editor
                            all: libraryController.series.toList(),
                            onSelected: (sel) => setState(
                              () {
                                // add them if not already in
                                if (!newBook.series.contains(sel)) {
                                  newBook.series = sel;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "tag",
                            item: newBook.tags,
                            // convert set to list for the editor
                            allItems: libraryController.tags.toList(),
                            onAdded: (sel) => setState(() {
                              // if new tag add to list
                              if (!newBook.tags.contains(sel)) {
                                newBook.tags.add(sel);
                                newBook.tags.sort();
                              }
                            }),
                            onRemoved: (tag) => setState(() {
                              // remove them if already in
                              newBook.tags.remove(tag);
                              newBook.tags.sort();
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StringEditor(
                            name: "Link",
                            controller: linkController,
                            onSubmitted: (newLink) => setState(() {
                              newBook.link = newLink;
                            }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListEditor(
                            name: "character",
                            item: newBook.characters,
                            // convert set to list for the editor
                            allItems: libraryController.characters.toList(),
                            onAdded: (sel) => setState(() {
                              // if new character add to list
                              if (!newBook.characters.contains(sel)) {
                                newBook.characters.add(sel);
                                newBook.characters.sort();
                              }
                            }),
                            onRemoved: (character) => setState(() {
                              // remove them if already in
                              newBook.characters.remove(character);
                              newBook.characters.sort();
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Checks if a given directory contains any image files.
  Future<bool> _checkDirectoryForImages(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return false;
    }

    final entries = dir.listSync();
    final images = entries.whereType<File>().where((file) {
      final ext = p.extension(file.path).toLowerCase();
      return ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);
    }).toList();

    return images.isNotEmpty;
  }
}

class CoverImage extends StatefulWidget {
  final String? folderPath;
  final String? bookName;
  final ValueChanged<String> onFolderSelected;

  const CoverImage({
    super.key,
    this.folderPath,
    this.bookName,
    required this.onFolderSelected,
  });

  @override
  State<CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage> {
  // Removed _folderSelected state here as it's now managed by the parent
  // using newBook.path to determine if a folder is selected.

  @override
  void didUpdateWidget(CoverImage old) {
    super.didUpdateWidget(old);
    // No need to set _folderSelected here, parent manages folderPath
  }

  @override
  Widget build(BuildContext context) {
    // Determine if a folder is selected based on widget.folderPath
    final bool folderHasPath =
        widget.folderPath != null && widget.folderPath!.isNotEmpty;

    return Material(
      color: folderHasPath ? Colors.transparent : Colors.grey[800],
      child: InkWell(
        onTap: () async {
          final String? dir = await getDirectoryPath();
          if (dir != null) {
            widget.onFolderSelected(
                dir); // Let the parent handle validation and state update
          }
        },
        child: folderHasPath
            ? Center(
                child: Image.file(
                  File(getCoverPath(widget.folderPath!)),
                ),
              )
            : Icon(
                Icons.add,
                size: 48,
                color: Colors.grey[600],
              ),
      ),
    );
  }
}

// just copy pasted code from the book model
// to get the cover image from the folder path
String getCoverPath(String path) {
  // ensure the directory exists
  final dir = Directory(path);
  if (!dir.existsSync()) {
    return '';
  }

  // list all entries in the folder
  final entries = dir.listSync();

  // filter to just files with image extensions
  final images = entries.whereType<File>().where((file) {
    final ext = p.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);
  }).toList();

  // if no images, bail out
  if (images.isEmpty) {
    return '';
  }

  // sort by filename so it's consistent
  images.sort((a, b) => a.path.compareTo(b.path));

  // return the very first image's path
  return images.first.path;
}

// cleans up the string for the name
String cleanString(String input) {
  // remove any [...] or (...) or {...} and their contents
  // remove any leading digits
  // trim residual whitespace
  return input
      .replaceAll(RegExp(r'\[.*?\]|\(.*?\)|\{.*?\}'), '')
      .replaceAll(RegExp(r'^\d+'), '')
      .trim();
}
