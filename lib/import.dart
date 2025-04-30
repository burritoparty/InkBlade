import 'package:flutter/material.dart';

class Import extends StatelessWidget {
  const Import({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import a book...'),
      ),
      body: const Row(
        children: [
          // add button
          Expanded(child: CoverImage()),
          // details column
          Expanded(
            child: Column(
              children: [
                TitleEntry(),
                AuthorEntry(),
                LinkEntry(),
              ],
            ),
          ),
          // tags here
          Expanded(child: Text("temp"))
        ],
      ),
    );
  }
}

class TitleEntry extends StatelessWidget {
  const TitleEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Title",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class AuthorEntry extends StatelessWidget {
  const AuthorEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Author",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class LinkEntry extends StatelessWidget {
  const LinkEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Link",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class CoverImage extends StatefulWidget {
  const CoverImage({super.key});

  @override
  State<CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage> {
  // keep track of when folder selected should be a plus
  bool _folderSelected = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 200,
        minHeight: 120,
        maxHeight: 300,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // switch to the bookreader page
          onTap: () {
            setState(() {});
            // TODO: i want to select a folder here
            _folderSelected = true;
          },
          child: _folderSelected
              ? const Placeholder()
              : Center(
                  child: Icon(
                    Icons.add,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                ),
        ),
      ),
    );
  }
}
