// Third-party package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project-specific imports
import 'package:flutter_manga_reader/router/routes.dart';
import '../controllers/library_controller.dart';

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
    // set up the library controller, which holds the list of books
    // it watches for changes to the list of books, and rebuilds the widget tree
    final libraryController = context.watch<LibraryController>();
    // get all authors dynamically
    final allAuthors = libraryController.authors.toList();

    // update filteredAuthors based on the current search query
    if (_searchController.text.isEmpty) {
      filteredAuthors = List.from(allAuthors);
    } else {
      filteredAuthors = allAuthors
          .where((author) =>
              author.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search authors...',
              onChanged: (value) {
                filterAuthors(value, allAuthors);
              },
            ),
          ),
        ),
        AuthorButtons(
          filteredAuthors: filteredAuthors,
          allAuthors: allAuthors,
        )
      ],
    );
  }
}

class AuthorButtons extends StatelessWidget {
  final List<String> filteredAuthors;
  final List<String> allAuthors;
  const AuthorButtons(
      {super.key, required this.filteredAuthors, required this.allAuthors});

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
              return TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.author,
                    // pass as a map
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
                child: Text(author),
              );
            },
          );
        },
      ),
    );
  }
}
