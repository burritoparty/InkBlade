// Third-party package imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

// Project-specific imports
import '../controllers/library_controller.dart';
import '../router/routes.dart';
import '../widgets/book_grid.dart';
import '../widgets/widgets.dart';

class TagDetails extends StatefulWidget {
  final String tag;

  const TagDetails({
    super.key,
    required this.tag,
  });

  @override
  State<TagDetails> createState() => _TagDetailsState();
}

class _TagDetailsState extends State<TagDetails> {
  late String _tag;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _tag = widget.tag;

    // set up focus node and request focus after build
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
    final libraryController = context.watch<LibraryController>();
    // filter the books dynamically
    final filteredBooks = libraryController.books
        .where((book) => book.tags.contains(_tag))
        .toList();
    // get all tags from the library controller
    final allTags = libraryController.tags.toList();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tag),
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          // Refocus the main FocusNode when this widget loses focus
                          _focusNode.requestFocus();
                        }
                      },
                      child: DropdownEditor(
                        name: "Rename Tag",
                        initial: _tag,
                        all: allTags,
                        onSelected: (sel) async {
                          if (_tag != sel) {
                            final libraryController =
                                context.read<LibraryController>();
                            // Rename the tag in all books
                            await libraryController.renameTag(_tag, sel);
                            setState(() {
                              _tag = sel;
                            });
                          }
                          // refocus keyboard, fix escape key issue
                          _focusNode.requestFocus();
                        },
                      ),
                    ),
                  ),
                ),
                ThumbnailButton(
                  onAdd: () async {
                    const XTypeGroup typeGroup = XTypeGroup(
                      label: 'images',
                      extensions: <String>['jpg', 'png'],
                    );

                    final XFile? file = await openFile(
                      acceptedTypeGroups: <XTypeGroup>[typeGroup],
                    );

                    if (file != null) {
                      final libraryController =
                          context.read<LibraryController>();
                      final tag = _tag;
                      await libraryController.setTagThumbnail(tag, file.path);
                    }
                  },
                ),
                DeleteButton(onDelete: () async {
                  if (!mounted) return; // Ensure the widget is still mounted
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to delete this tag?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false), // Cancel
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true), // Confirm
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    final libraryController = context.read<LibraryController>();
                    // remove the tag from all books
                    await libraryController.removeTagFromBooks(_tag);
                    // back to the previous screen
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                }),
              ],
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
                  setState(() {}); // refresh the screen after returning
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
