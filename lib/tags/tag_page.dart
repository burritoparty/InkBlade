import 'package:flutter/material.dart';
import 'tag_details.dart';

class TagPage extends StatefulWidget {
  const TagPage({super.key});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  // controller for search input field
  final TextEditingController _searchController = TextEditingController();

  List<String> allTags = [];
  List<String> filteredTags = [];

  @override
  void initState() {
    super.initState();

    // load up the tags from json
    allTags = [
      "Romance",
      "Comedy",
      "Horror",
      "Slice of Life",
      "Isekai",
    ];
    filteredTags = List.from(allTags);
  }

  // fitlters the tags based on the given to update the list
  void filterTags(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTags = List.from(allTags);
      } else {
        filteredTags = allTags
            .where((tag) => tag.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // search bar
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search tags...',
              onChanged: (value) {
                filterTags(value);
              },
            ),
          ),
        ),
        // responsive grid for tag buttons
        TagButtons(
          filteredTags: filteredTags,
          allTags: allTags,
          // onTagPressed: _showTagOptions,
        ),
      ],
    );
  }
}

// grid of buttons for each tag
class TagButtons extends StatelessWidget {
  final List<String> filteredTags;
  final List<String> allTags;
  // final void Function(BuildContext, String) onTagPressed;

  const TagButtons({
    super.key,
    required this.filteredTags,
    required this.allTags,
    // required this.onTagPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double buttonWidth = 150.0;
          int crossAxisCount = (constraints.maxWidth / buttonWidth).floor();
          if (crossAxisCount < 1) crossAxisCount = 1;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 3 / 1,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: filteredTags.length,
            itemBuilder: (context, index) {
              final tag = filteredTags[index];
              return TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TagDetails(tag: tag))),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                child: Text(tag),
              );
            },
          );
        },
      ),
    );
  }
}
