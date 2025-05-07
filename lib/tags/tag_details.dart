import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/book_grid.dart';
import '../router/routes.dart';
import '../widgets/widgets.dart';
import '../controllers/library_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _tag = widget.tag;
  }

  @override
  Widget build(BuildContext context) {
    // Set up the library controller, which holds the list of books
    final libraryController = context.watch<LibraryController>();
    // Filter the books dynamically
    final filteredBooks = libraryController.books
        .where((book) => book.tags.contains(_tag))
        .toList();
    // Get all tags from the library controller
    final allTags = libraryController.tags.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_tag),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownEditor(
                    name: "Rename Tag",
                    initial: _tag,
                    all: allTags,
                    onSelected: (sel) async {
                      if (_tag != sel) {
                        final libraryController = context.read<LibraryController>();
                        // Rename the tag in all books
                        await libraryController.renameTag(_tag, sel);
                        setState(() {
                          _tag = sel;
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
                      content: const Text('Are you sure you want to delete this tag?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), // Cancel
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), // Confirm
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  final libraryController = context.read<LibraryController>();
                  // Remove the tag from all books
                  await libraryController.removeTagFromBooks(_tag);
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
    );
  }
}
