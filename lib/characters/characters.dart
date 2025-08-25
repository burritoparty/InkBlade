import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/library_controller.dart';
import 'characters_details.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryController>();

    // Build unique character -> counts
    final Map<String, int> charCounts = {};
    for (final b in lib.books) {
      final chars = b.characters;
      for (final raw in chars) {
        final c = raw.trim();
        if (c.isEmpty) continue;
        charCounts[c] = (charCounts[c] ?? 0) + 1;
      }
    }

    final allChars = charCounts.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final q = _query.trim().toLowerCase();
    final visibleChars = q.isEmpty
        ? allChars
        : allChars.where((c) => c.toLowerCase().contains(q)).toList();

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // SearchBar in the title removes the top gap
        titleSpacing: 8,
        toolbarHeight: 64,
        title: SearchBar(
          controller: _searchCtrl,
          hintText: 'Search ${allChars.length} characters...',
          leading: const Icon(Icons.search),
          trailing: [
            if (_query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
          ],
          onChanged: (v) => setState(() => _query = v),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          elevation: const WidgetStatePropertyAll(0.0),
          backgroundColor:
              WidgetStatePropertyAll(scheme.surfaceContainerHighest),
        ),
      ),
      body: visibleChars.isEmpty
          ? Center(
              child: Text(
                q.isEmpty
                    ? 'No characters found.'
                    : 'No characters match "$_query".',
              ),
            )
          : ListView.separated(
              itemCount: visibleChars.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final name = visibleChars[i];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ListTile(
                    leading: const Icon(Icons.groups),
                    title: Text(name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${charCounts[name]}'),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    hoverColor: scheme.surfaceContainerHighest.withOpacity(0.3),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              CharactersDetails(characterName: name),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
