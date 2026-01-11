import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/library_controller.dart';
import '../widgets/book_grid.dart';
import '../router/routes.dart';

import '../widgets/delete_button.dart';
import '../widgets/search_bar.dart';

class CharactersDetails extends StatefulWidget {
  final String characterName;
  const CharactersDetails({super.key, required this.characterName});

  @override
  State<CharactersDetails> createState() => _CharactersDetailsState();
}

enum _SaveState { neutral, dirty, saved }

class _CharactersDetailsState extends State<CharactersDetails> {
  bool _ascending = true;
  final TextEditingController _searchController = TextEditingController();

  late final TextEditingController _renameCtrl;
  late String _currentCharacterName;
  _SaveState _saveState = _SaveState.neutral;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentCharacterName = widget.characterName;

    _renameCtrl = TextEditingController(text: _currentCharacterName);
    _renameCtrl.addListener(() {
      final now = _renameCtrl.text.trim();
      final was = _currentCharacterName.trim();
      setState(() {
        _saveState = (now == was) ? _SaveState.neutral : _SaveState.dirty;
      });
    });

    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _renameCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveRename(LibraryController lib) async {
    final newName = _renameCtrl.text.trim();
    if (newName.isEmpty || newName == _currentCharacterName) return;

    setState(() => _saving = true);
    try {
      // Ensure this exists in your controller
      await Future<void>.sync(
          () => lib.renameCharacter(_currentCharacterName, newName));
      if (!mounted) return;
      setState(() {
        _currentCharacterName = newName;
        _saveState = _SaveState.saved;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rename failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryController>();

    // Safely gather books for this character (ignore null/malformed)
    final target = _currentCharacterName.trim().toLowerCase();
    final booksForCharacter = lib.books.where((b) {
      final list = b.characters;
      for (final item in list) {
        if (item.trim().toLowerCase() == target) return true;
      }
      return false;
    }).toList();

    // Filter by query across common metadata
    final q = _searchController.text.trim().toLowerCase();
    bool listHas(dynamic list) {
      if (q.isEmpty) return true;
      if (list is List) {
        for (final e in list) {
          if (e is String && e.toLowerCase().contains(q)) return true;
        }
      }
      return false;
    }

    final filtered = q.isEmpty
        ? booksForCharacter
        : booksForCharacter.where((b) {
            final name = (b.title).toLowerCase();
            return name.contains(q) ||
                listHas(b.tags) ||
                listHas(b.authors) ||
                listHas(b.characters);
          }).toList()
      ..sort((a, b) {
        final an = (a.title).toLowerCase();
        final bn = (b.title).toLowerCase();
        return _ascending ? an.compareTo(bn) : bn.compareTo(an);
      });

    // Rename box state colors
    final red = Colors.redAccent;
    final green = Colors.green;

    final InputBorder? enabledBorder = (_saveState == _SaveState.neutral)
        ? null
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _saveState == _SaveState.dirty ? red : green,
              width: 1.5,
            ),
          );

    final InputBorder? focusedBorder = (_saveState == _SaveState.neutral)
        ? null
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _saveState == _SaveState.dirty ? red : green,
              width: 2,
            ),
          );

    final Color? labelColor = switch (_saveState) {
      _SaveState.neutral => null,
      _SaveState.dirty => red,
      _SaveState.saved => green,
    };
    final TextStyle? labelTextStyle =
        (labelColor == null) ? null : TextStyle(color: labelColor);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        toolbarHeight: 64,
        title: Text('Character: $_currentCharacterName'),
        actions: [
          IconButton(
            tooltip: _ascending ? 'Sort Z–A' : 'Sort A–Z',
            icon: const Icon(Icons.swap_vert),
            onPressed: () => setState(() => _ascending = !_ascending),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _renameCtrl,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveRename(lib),
                    enabled: !_saving,
                    decoration: InputDecoration(
                      labelText: 'Character name',
                      hintText: 'Rename character',
                      isDense: true,
                      labelStyle: labelTextStyle,
                      floatingLabelStyle: labelTextStyle,
                      suffixIcon: _saving
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : switch (_saveState) {
                              _SaveState.neutral => null,
                              _SaveState.dirty =>
                                Icon(Icons.circle, color: red, size: 14),
                              _SaveState.saved =>
                                Icon(Icons.check_circle, color: green),
                            },
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                DeleteButton(onDelete: () async {
                  if (!mounted) return;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text(
                            'Are you sure you want to delete this character?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    // ignore: use_build_context_synchronously
                    final libraryController = context.read<LibraryController>();
                    await libraryController
                        .deleteCharacter(_currentCharacterName);
                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  }
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: CustomSearchBar(
                controller: _searchController,
                hintText:
                    '${booksForCharacter.length == 1 ? 'book' : 'books'} with $_currentCharacterName',
                count: booksForCharacter.length,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No matching books.'))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BookGrid(
                      books: filtered,
                      onBookTap: (index) async {
                        await Navigator.pushNamed(
                          context,
                          Routes.details,
                          arguments: index,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
