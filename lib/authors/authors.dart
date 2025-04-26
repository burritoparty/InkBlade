import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/router/routes.dart';

class Authors extends StatefulWidget {
  const Authors({super.key});

  @override
  State<Authors> createState() => _AuthorsState();
}

class _AuthorsState extends State<Authors> {
  final TextEditingController _searchController = TextEditingController();
  List<String> allAuthors = [];
  List<String> filteredAuthors = [];
  @override
  void initState() {
    super.initState();

    // load up the authors from json
    allAuthors = [
      "Shinichi Fukuda",
      "Hiromu Arakawa",
      "Kana Akatsuki",
      "Kenya Suzuki",
      "Nisio Isin",
    ];
    filteredAuthors = allAuthors;
  }

  void filterAuthors(String query) {
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
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search authors...',
              onChanged: (value) {
                filterAuthors(value);
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
          double buttonWidth = 150.0;
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
                  backgroundColor: Colors.blue,
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
