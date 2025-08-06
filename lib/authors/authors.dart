import 'dart:io';

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Project-specific imports
import 'package:flutter_manga_reader/router/routes.dart';
import '../controllers/library_controller.dart';

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
    // initialize filteredAuthors with all authors from the LibraryController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final libraryController = context.read<LibraryController>();
      setState(() {
        filteredAuthors = libraryController.authors.toList();
      });
    });
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

    // Format the number of aauthors with commas
    final formatter = NumberFormat('#,###');
    final formattedAuthorCount =
        formatter.format(libraryController.authors.length);

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
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search $formattedAuthorCount authors...',
              onChanged: (value) {
                filterAuthors(value, allAuthors);
              },
            ),
          ),
        ),
        AuthorButtons(
          filteredAuthors: filteredAuthors,
          allAuthors: allAuthors,
          allBooks: libraryController.books, // Pass the books here
        )
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
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double buttonWidth = 200.0;
          int crossAxisCount = (constraints.maxWidth / buttonWidth).floor();
          if (crossAxisCount < 1) {
            crossAxisCount = 1;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 3 / 1,
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
              final coverPath = book?.getCoverPath() ?? '';

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                child: Row(
                  children: [
                    if (coverPath.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(coverPath),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[700],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        author,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
