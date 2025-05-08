import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/book_grid.dart';
import '../router/routes.dart';
import '../widgets/widgets.dart';
import '../controllers/library_controller.dart';
import 'package:flutter/services.dart';

class AuthorDetails extends StatefulWidget {
  final String author;

  const AuthorDetails({
    super.key,
    required this.author,
  });

  @override
  State<AuthorDetails> createState() => AuthorDetailsState();
}

class AuthorDetailsState extends State<AuthorDetails> {
  late String _author;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _author = widget.author;

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
    // it watches for changes to the list of books, and rebuilds the widget tree
    final libraryController = context.watch<LibraryController>();
    // Filter the books dynamically
    final filteredBooks = libraryController.books
        .where((book) => book.authors.contains(_author))
        .toList();
    // get all authors from the library controller
    final allAuthors = libraryController.authors.toList();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_author),
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
                    child: DropdownEditor(
                      name: "Rename Author",
                      initial: _author,
                      all: allAuthors,
                      onSelected: (sel) async {
                        if (_author != sel) {
                          final libraryController =
                              context.read<LibraryController>();
                          // rename the author in all books
                          await libraryController.renameAuthor(_author, sel);
                          setState(() {
                            _author = sel;
                          });
                        }
                      },
                    ),
                  ),
                ),
                DeleteButton(onDelete: () async {
                  if (!mounted) return; // Ensure the widget is still mounted
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to delete this author?'),
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
                    // Remove the author from all books
                    await libraryController.removeAuthorFromBooks(_author);
                    // Navigate back to the previous screen
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
                  setState(() {}); // Refresh UI on return
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
