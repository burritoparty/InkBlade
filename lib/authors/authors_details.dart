import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/book_grid.dart';
import '../router/routes.dart';
import '../widgets/widgets.dart';
import '../controllers/library_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _author = widget.author;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_author),
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
                        final libraryController = context.read<LibraryController>();
                        // Rename the author in all books
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
                final libraryController = context.read<LibraryController>();
                // Remove the author from all books
                await libraryController.removeAuthorFromBooks(_author);
                // Notify listeners to update the previous page
                libraryController.notifyListeners();
                // Navigate back to the previous screen
                if (mounted) {
                  Navigator.pop(context);
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
    );
  }
}
