import 'dart:io';

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project-specific imports
import 'package:flutter_manga_reader/router/routes.dart';
import '../controllers/library_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/search_bar.dart';

import '../models/book.dart';

class Authors extends StatefulWidget {
  const Authors({super.key});

  @override
  State<Authors> createState() => _AuthorsState();
}

class _AuthorsState extends State<Authors> {
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredAuthors = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final libraryController = context.read<LibraryController>();
      setState(() {
        filteredAuthors = libraryController.authors.toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterAuthors(String query, List<String> allAuthors) {
    setState(() {
      if (query.isEmpty) {
        filteredAuthors = List.from(allAuthors);
      } else {
        filteredAuthors = allAuthors
            .where(
                (author) => author.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final libraryController = context.watch<LibraryController>();
    final allAuthors = libraryController.authors.toList();

    if (_searchController.text.isEmpty) {
      filteredAuthors = List.from(allAuthors)..sort();
    } else {
      filteredAuthors = allAuthors
          .where((author) => author
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList()
        ..sort();
    }

    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomSearchBar(
                controller: _searchController,
                hintText: 'authors',
                count: libraryController.authors.length),
          ),
        ),
        Expanded(
          child: filteredAuthors.isEmpty
              ? const Center(
                  child: Text(
                    'No matching authors.',
                    textAlign: TextAlign.center,
                  ),
                )
              : AuthorButtons(
                  filteredAuthors: filteredAuthors,
                  allAuthors: allAuthors,
                  allBooks: libraryController.books,
                ),
        ),
      ],
    );
  }
}

class AuthorButtons extends StatelessWidget {
  final List<String> filteredAuthors;
  final List<String> allAuthors;
  final List<Book> allBooks; // Add this parameter
  const AuthorButtons(
      {super.key,
      required this.filteredAuthors,
      required this.allAuthors,
      required this.allBooks});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final buttonHeight =
            context.watch<SettingsController>().authorButtonHeight;
        int crossAxisCount = (constraints.maxHeight / buttonHeight).floor();
        if (crossAxisCount < 1) {
          crossAxisCount = 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1 / 1.5, // adjust aspect ratio of button
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: filteredAuthors.length,
          itemBuilder: (context, index) {
            final author = filteredAuthors[index];
            // Find the first book for this author
            final book = allBooks.firstWhere(
              (b) => b.authors.contains(author),
            );
            final coverPath = book.getCoverPath();

            return TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.author,
                  arguments: {'author': author, 'allAuthors': allAuthors},
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background image or placeholder with padding
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: coverPath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(coverPath),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 48),
                              ),
                            ),
                    ),
                  ),
                  // Overlay for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // Author name centered with backdrop
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          author,
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
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
