import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/library_controller.dart';
import 'series_details.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
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

    // unique series -> counts
    final Map<String, int> seriesCounts = {};
    for (final b in lib.books) {
      final s = (b.series).trim();
      if (s.isEmpty) continue;
      seriesCounts[s] = (seriesCounts[s] ?? 0) + 1;
    }

    final allSeries = seriesCounts.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final q = _query.trim().toLowerCase();
    final visibleSeries = q.isEmpty
        ? allSeries
        : allSeries.where((s) => s.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            true, // keeps back arrow if this page was pushed
        titleSpacing: 8,
        toolbarHeight: 64,
        title: SearchBar(
          controller: _searchCtrl,
          hintText: 'Search ${allSeries.length} series...',
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
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      body: visibleSeries.isEmpty
          ? Center(
              child: Text(
                q.isEmpty ? 'No series found.' : 'No series match "$_query".',
              ),
            )
          : ListView.separated(
              itemCount: visibleSeries.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final seriesName = visibleSeries[i];
                return ListTile(
                  leading: const Icon(Icons.auto_stories),
                  title: Text(seriesName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${seriesCounts[seriesName]}'),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SeriesDetails(seriesName: seriesName),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
