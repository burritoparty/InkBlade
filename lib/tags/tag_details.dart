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
import '../widgets/search_bar.dart';

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
  late FocusNode _focusNode;
  late String _tag;
  final TextEditingController _searchController = TextEditingController();

  // Description text field
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    descriptionController.text =
        context.read<LibraryController>().getTagDescription(widget.tag);
    _tag = widget.tag;
    _focusNode = FocusNode();

    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _searchController.dispose();
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

    // filter books that contain this tag
    final booksForTag = libraryController.books
        .where((b) => b.tags.contains(_tag))
        .toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final query = _searchController.text.trim().toLowerCase();

    final filteredBooks = query.isEmpty
        ? booksForTag
        : booksForTag
            .where((b) => b.title.toLowerCase().contains(query))
            .toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    // all tags
    final allTags = libraryController.tags.toList()..sort();

    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(title: Text('Tag: $_tag')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row with rename + thumbnail + delete
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Center(
                        child: DropdownEditor(
                          name: "Rename Tag",
                          initial: _tag,
                          all: allTags,
                          onSelected: (sel) async {
                            if (_tag != sel) {
                              final libraryController =
                                  context.read<LibraryController>();
                              // Rename the tag across books AND tagThumbnails (also renames the file)
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
                  const SizedBox(width: 12),
                  ThumbnailButton(
                    onAdd: () async {
                      const XTypeGroup typeGroup = XTypeGroup(
                        label: 'images',
                        extensions: <String>['jpg', 'png'],
                      );

                      final XFile? file = await openFile(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup],
                      );
                      if (file == null) return;

                      await context
                          .read<LibraryController>()
                          .setTagThumbnail(_tag, file.path);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thumbnail updated')),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
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
                      final libraryController =
                          context.read<LibraryController>();
                      // remove the tag from all books
                      await libraryController.removeTagFromBooks(_tag);
                      if (!mounted) return;
                      Navigator.pop(context);
                    }
                  }),
                ],
              ),
            ),
            // Description editor
            Padding(
              // push from ltrb
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: SizedBox(
                height: 48,
                child: StringEditor(
                  name: "Description",
                  controller: descriptionController,
                  onSubmitted: (newDescription) {
                    // Update the tag description
                    context
                        .read<LibraryController>()
                        .setTagDescription(_tag, newDescription);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: CustomSearchBar(
                  controller: _searchController,
                  hintText:
                      '${booksForTag.length == 1 ? 'book' : 'books'} in $_tag',
                  count: booksForTag.length,
                ),
              ),
            ),
            // books grid
            Expanded(
              child: BookGrid(
                books: filteredBooks,
                onBookTap: (index) async {
                  // navigate to details and refresh on return
                  await Navigator.pushNamed(
                    context,
                    Routes.details,
                    arguments: index,
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
