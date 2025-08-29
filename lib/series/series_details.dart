import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/library_controller.dart';
import '../widgets/book_grid.dart';
import '../widgets/delete_button.dart'; // <- uses your existing delete button styling
import '../router/routes.dart';

class SeriesDetails extends StatefulWidget {
  final String seriesName;
  const SeriesDetails({super.key, required this.seriesName});

  @override
  State<SeriesDetails> createState() => _SeriesDetailsState();
}

enum _SaveState { neutral, dirty, saved }

class _SeriesDetailsState extends State<SeriesDetails> {
  String _query = '';
  bool _ascending = true;

  // rename
  late final TextEditingController _renameCtrl;
  late String _currentSeriesName;
  _SaveState _saveState = _SaveState.neutral;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentSeriesName = widget.seriesName;
    _renameCtrl = TextEditingController(text: _currentSeriesName);
    _renameCtrl.addListener(() {
      final now = _renameCtrl.text.trim();
      final was = _currentSeriesName.trim();
      setState(() {
        _saveState = (now == was) ? _SaveState.neutral : _SaveState.dirty;
      });
    });
  }

  @override
  void dispose() {
    _renameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRename(LibraryController lib) async {
    final newName = _renameCtrl.text.trim();
    if (newName.isEmpty || newName == _currentSeriesName) return;

    setState(() => _saving = true);
    try {
      await Future<void>.sync(
          () => lib.renameSeries(_currentSeriesName, newName));
      if (!mounted) return;
      setState(() {
        _currentSeriesName = newName;
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

    // books in (possibly renamed) series
    final target = _currentSeriesName.trim().toLowerCase();
    final booksInSeries = lib.books
        .where((b) => ((b.series).trim().toLowerCase()) == target)
        .toList();

    // filter by query
    final q = _query.trim().toLowerCase();
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
        ? booksInSeries
        : booksInSeries.where((b) {
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

    // colors for the rename box
    final Color red = Colors.redAccent;
    final Color green = Colors.green;

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

    // label color reacts to state (neutral -> default, dirty -> red, saved -> green)
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
        title: Text('Series: $_currentSeriesName'),
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
          // rename text box + delete button row
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
                      labelText: 'Series name',
                      hintText: 'Rename series',
                      isDense: true,

                      // label color changes with state
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
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to delete this series?'),
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
                    // remove the tag from all books
                    await libraryController.deleteSeries(_currentSeriesName);
                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  }
                }),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No matching books.'))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BookGrid(
                      books: booksInSeries,
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
