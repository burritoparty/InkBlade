// Third-party package imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Project-specific imports
import '../controllers/library_controller.dart';
import '../controllers/settings_controller.dart';
import 'tag_details.dart';

class TagPage extends StatefulWidget {
  const TagPage({super.key});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  // controller for search input field
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredTags = [];

  @override
  void initState() {
    super.initState();
    // initialize filteredTags with all tags from the LibraryController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final libraryController = context.read<LibraryController>();
      setState(() {
        filteredTags = libraryController.tags.toList();
      });
    });
  }

  // filter tags based on search query
  void filterTags(String query, List<String> allTags) {
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
    // set up the library controller, which holds the list of books
    final libraryController = context.watch<LibraryController>();
    // get all tags dynamically
    final allTags = libraryController.tags.toList();

    // Format the number of books with commas
    final formatter = NumberFormat('#,###');
    final formattedTagCount = formatter.format(libraryController.tags.length);

    // update filteredTags based on the current search query
    if (_searchController.text.isEmpty) {
      filteredTags = List.from(allTags)..sort();
    } else {
      filteredTags = allTags
          .where((tag) =>
              tag.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList()
        ..sort();
    }

    return Column(
      children: [
        // search bar
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search $formattedTagCount tags...',
              onChanged: (value) {
                filterTags(value, allTags);
              },
            ),
          ),
        ),
        // responsive grid for tag buttons
        TagButtons(
          filteredTags: filteredTags,
          allTags: allTags,
        ),
      ],
    );
  }
}

// grid of buttons for each tag
class TagButtons extends StatelessWidget {
  final List<String> filteredTags;
  final List<String> allTags;

  const TagButtons({
    super.key,
    required this.filteredTags,
    required this.allTags,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = context.watch<SettingsController>().tagButtonHeight;
    final tagThumbnails = context.watch<LibraryController>().tagThumbnails;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = (constraints.maxWidth / buttonSize).floor();
          if (crossAxisCount < 1) crossAxisCount = 1;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: filteredTags.length,
            itemBuilder: (context, index) {
              final tag = filteredTags[index];
              final thumbnailPath = tagThumbnails[tag];

              return SizedBox(
                width: buttonSize.toDouble(),
                height: buttonSize.toDouble(),
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TagDetails(tag: tag)),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // thumbnail image or placeholder, inset by 4px
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: thumbnailPath != null &&
                                  File(thumbnailPath).existsSync()
                              ? Image.file(
                                  File(thumbnailPath),
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.grey[700]),
                        ),
                      ),

                      // dark overlay (also inset by 4px)
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      // text with its own backdrop
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
