// Standard Dart imports
import 'dart:io';

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Project-specific imports
import 'package:flutter_manga_reader/models/book.dart';
import '../../controllers/library_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../router/routes.dart';
import '../../widgets/widgets.dart';

class BookDetails extends StatefulWidget {
  final Book book;
  const BookDetails({super.key, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late final LibraryController libraryController;
  late final SettingsController settingsController;
  late int imagesPerRow;
  late FocusNode _focusNode;
  bool _isCtrlPressed = false; // Track if Ctrl is pressed
  // controller for text editing field
  late final TextEditingController titleController;
  late final TextEditingController linkController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book.title);
    linkController = TextEditingController(text: widget.book.link);
    // initialize the library controller
    libraryController = context.read<LibraryController>();
    // initialize the settings controller
    settingsController = context.read<SettingsController>();
    // set up focus node and request focus after build
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    imagesPerRow = settingsController.pageSliderValue.round();
  }

  // dispose focus node
  @override
  void dispose() {
    // dispose focus node
    _focusNode.dispose();
    super.dispose();
  }

  // handle key presses
  void _handleKeyEvent(KeyEvent event) {
    // on Escape key down, go back a page
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // set up the library controller, which holds the list of books
    // it watches for changes to the list of books, and rebuilds the widget tree
    final libraryController = context.watch<LibraryController>();
    // // controller for text editing field
    // final TextEditingController titleController =
    //     TextEditingController(text: widget.book.title);
    // final TextEditingController linkController =
    //     TextEditingController(text: widget.book.link);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        _handleKeyEvent(event);
        // track ctrl key state
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.controlLeft) {
          setState(() {
            _isCtrlPressed = true;
          });
        } else if (event is KeyUpEvent &&
            event.logicalKey == LogicalKeyboardKey.controlLeft) {
          setState(() {
            _isCtrlPressed = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.book.title),
              Text(
                '${widget.book.getPageCount()} pages',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
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
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CoverImage(book: widget.book),
                  ),
                  Expanded(
                    flex: 2,
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
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      _focusNode.requestFocus();
                                    }
                                  },
                                  child: StringEditor(
                                    name: "Title",
                                    controller: titleController,
                                    onSubmitted: (newTitle) async {
                                      final success = await libraryController
                                          .updateTitle(widget.book, newTitle);
                                      if (success) {
                                        setState(() {
                                          widget.book.title = newTitle;
                                        });
                                      }
                                      await libraryController
                                          .sortLibraryJsonByTitle();
                                      // refocus keyboard, fix escape key issue
                                      _focusNode.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      _focusNode.requestFocus();
                                    }
                                  },
                                  child: ListEditor(
                                    name: "author",
                                    item: widget.book.authors.toList()..sort(),
                                    allItems:
                                        libraryController.authors.toList(),
                                    onAdded: (sel) async {
                                      if (!widget.book.authors.contains(sel)) {
                                        final success = await libraryController
                                            .updateAuthors(
                                                widget.book, sel, false);
                                        if (success) {
                                          setState(() {});
                                        }
                                      }
                                    },
                                    onRemoved: (author) async {
                                      final success =
                                          await libraryController.updateAuthors(
                                              widget.book, author, true);
                                      if (success) {
                                        setState(() {
                                          widget.book.authors.remove(author);
                                        });
                                      }
                                    },
                                  ),
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
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      _focusNode.requestFocus();
                                    }
                                  },
                                  child: DropdownEditor(
                                    name: "Series",
                                    initial: widget.book.series,
                                    // convert set to list for the editor
                                    all: libraryController.series.toList(),
                                    onSelected: (sel) async {
                                      final success = await libraryController
                                          .updateSeries(widget.book, sel);
                                      if (success) {
                                        setState(() {
                                          widget.book.series = sel;
                                        });
                                      }
                                      // refocus keyboard, fix escape key issue
                                      _focusNode.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      _focusNode.requestFocus();
                                    }
                                  },
                                  child: ListEditor(
                                    name: "tag",
                                    item: widget.book.tags.toList()..sort(),
                                    allItems: libraryController.tags.toList(),
                                    onAdded: (sel) async {
                                      if (!widget.book.tags.contains(sel)) {
                                        final success =
                                            await libraryController.updateTags(
                                                widget.book, sel, false);
                                        if (success) {
                                          setState(() {});
                                        }
                                      }
                                    },
                                    onRemoved: (tag) async {
                                      final success = await libraryController
                                          .updateTags(widget.book, tag, true);
                                      if (success) {
                                        setState(() {
                                          widget.book.tags.remove(tag);
                                        });
                                      }
                                    },
                                  ),
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
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      _focusNode.requestFocus();
                                    }
                                  },
                                  child: StringEditor(
                                    name: "Link",
                                    controller: linkController,
                                    onSubmitted: (newLink) async {
                                      final success = await libraryController
                                          .updateLink(widget.book, newLink);
                                      if (success) {
                                        setState(() {
                                          widget.book.link = newLink;
                                        });
                                      }
                                      // Refocus keyboard, fix escape key issue
                                      _focusNode.requestFocus();
                                    },
                                    onTap: () async {
                                      if (_isCtrlPressed) {
                                        final url = Uri.parse(widget.book.link);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        } else {
                                          debugPrint('Could not launch $url');
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      _focusNode.requestFocus();
                                    }
                                  },
                                  child: ListEditor(
                                    name: "character",
                                    item: widget.book.characters.toList()
                                      ..sort(),
                                    allItems:
                                        libraryController.characters.toList(),
                                    onAdded: (sel) async {
                                      if (!widget.book.characters
                                          .contains(sel)) {
                                        final success = await libraryController
                                            .updateCharacters(
                                                widget.book, sel, false);
                                        if (success) {
                                          setState(() {});
                                        }
                                      }
                                    },
                                    onRemoved: (character) async {
                                      final success = await libraryController
                                          .updateCharacters(
                                              widget.book, character, true);
                                      if (success) {
                                        setState(() {
                                          widget.book.characters
                                              .remove(character);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FavoriteButton(
                                  isFavorite: widget.book.favorite,
                                  onFavoriteToggle: (newVal) async {
                                    // Update the book's favorite status and save to JSON
                                    final success = await libraryController
                                        .updateFavorite(widget.book, newVal);
                                    if (success) {
                                      setState(
                                        () {
                                          widget.book.favorite =
                                              newVal; // Update the UI
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LaterButton(
                                  isReadLater: widget.book.readLater,
                                  onReadLaterToggle: (newVal) async {
                                    // Update the book's readLater status and save to JSON
                                    final success = await libraryController
                                        .updateReadLater(widget.book, newVal);
                                    if (success) {
                                      setState(
                                        () {
                                          widget.book.readLater =
                                              newVal; // Update the UI
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            ExplorerButton(
                              onExplorer: () {
                                Process.run("explorer", [widget.book.path]);
                              },
                            ),
                            DeleteButton(
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Book"),
                                    content: const Text(
                                        "Are you sure you want to delete this book?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                            context, false), // Cancel
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                            context, true), // Confirm
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  // grab path before pop
                                  final bookPath = widget.book.path;

                                  // pop first
                                  // ignore: use_build_context_synchronously
                                  if (mounted) Navigator.pop(context);

                                  // Remove the book from the library
                                  await libraryController
                                      .removeBook(widget.book);

                                  // delete the folder, safely catching any errors
                                  try {
                                    final dir = Directory(bookPath);
                                    if (await dir.exists()) {
                                      await dir.delete(recursive: true);
                                    }
                                  } catch (e) {
                                    debugPrint(
                                        'Failed to delete book folder: $e');
                                  }
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PagesGrid(
                  book: widget.book,
                  crossAxisCount: imagesPerRow,
                  spacing: 8,
                  onTapPage: (file, pageNumber) {
                    debugPrint('Tapped on page $pageNumber');
                    // navigate to the reader page, passing the book and page number
                    Navigator.pushNamed(
                      context,
                      Routes.reader, // path to reader
                      arguments: {
                        'book': widget.book,
                        'startPage': pageNumber - 1, // zero-based index
                      }, // object passed it
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoverImage extends StatelessWidget {
  final Book book;
  // requires the book as a param
  const CoverImage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // switch to the bookreader page
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.reader, // path to reader
            arguments: {
              'book': book,
              'startPage': 0, // start at the beginning
            }, // object passed it
          );
        },
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Image.file(File(book.getCoverPath())),
        ),
      ),
    );
  }
}

class PagesGrid extends StatelessWidget {
  const PagesGrid({
    super.key,
    required this.book,
    this.crossAxisCount = 3,
    this.spacing = 8,
    this.onTapPage, // optional: handle open/go-to here
    this.childAspectRatio = 0.707, // tweak if your thumbs are different
  });

  final dynamic book; // change to your Book class
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final void Function(File pageFile, int pageNumber)? onTapPage;

  @override
  Widget build(BuildContext context) {
    final List<File> pages = book.getPageFiles();

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final file = pages[index];
        final pageNumber = index + 1;

        return _PageTile(
          file: file,
          pageNumber: pageNumber,
          onTap: () => onTapPage?.call(file, pageNumber),
        );
      },
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    required this.file,
    required this.pageNumber,
    this.onTap,
  });

  final File file;
  final int pageNumber;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badgePosition =
        Provider.of<SettingsController>(context).badgePosition;
    final badgeFontSize =
        Provider.of<SettingsController>(context).badgeFontSize;
    final cs = Theme.of(context).colorScheme;
    // Example badge label: total pages in the book
    final String badgeLabel = '$pageNumber';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Page preview
            Positioned.fill(
              child: Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),

            switch (badgePosition) {
              'topLeft' => Positioned(
                  left: badgeFontSize / 14.0 * 12,
                  top: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              'topRight' => Positioned(
                  right: badgeFontSize / 14.0 * 12,
                  top: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              'bottomLeft' => Positioned(
                  left: badgeFontSize / 14.0 * 12,
                  bottom: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              'bottomRight' => Positioned(
                  right: badgeFontSize / 14.0 * 12,
                  bottom: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              _ => const SizedBox.shrink(),
            },
          ],
        ),
      ),
    );
  }
}

/// Shared badge widget to keep style identical across grids.
class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 2),
            color: Colors.black26,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
