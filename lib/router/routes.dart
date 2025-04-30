// lib/router/routes.dart

import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/import.dart';
import 'package:flutter_manga_reader/models/book.dart';
import 'package:flutter_manga_reader/screen/library.dart';
import 'package:flutter_manga_reader/screen/book/book_details.dart';
import 'package:flutter_manga_reader/screen/book/book_reader.dart';
import 'package:flutter_manga_reader/authors/authors_details.dart';

class Routes {
  static const home = '/';
  static const library = '/library';
  static const details = '/book/details';
  static const reader = '/book/reader';
  static const author = '/authors/details';
  static const import = '../import.dart';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.library:
        return MaterialPageRoute(builder: (_) => const Library());
      case Routes.details:
        final book = settings.arguments as Book;
        return MaterialPageRoute(
          builder: (_) => BookDetails(book: book),
        );
      case Routes.reader:
        final book = settings.arguments as Book;
        return MaterialPageRoute(
          builder: (_) => BookReader(book: book),
        );
      case Routes.author:
        // unpack the given map
        final args = settings.arguments as Map<String, dynamic>;
        final author = args['author'] as String;
        final allAuthors = List<String>.from(args['allAuthors'] as List);
        return MaterialPageRoute(
          builder: (_) => AuthorDetails(
            author: author,
            allAuthors: allAuthors,
          ),
        );
      // route for FAB (import)
      case Routes.import:
        return MaterialPageRoute(builder: (_) => const Import());

      default:
        return null; // or a “NotFound” page
    }
  }
}
