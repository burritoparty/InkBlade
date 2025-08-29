// Third-party package imports
import 'package:flutter/material.dart';

// Project-specific imports
import 'package:flutter_manga_reader/authors/authors_details.dart';
import 'package:flutter_manga_reader/import.dart';
import 'package:flutter_manga_reader/models/book.dart';
import 'package:flutter_manga_reader/screen/book/book_details.dart';
import 'package:flutter_manga_reader/screen/book/book_reader.dart';
import 'package:flutter_manga_reader/screen/library.dart';
import 'package:flutter_manga_reader/tags/tag_details.dart';
import '../../characters/characters_details.dart'; // from /details/ up one level to /screens

class Routes {
  static const home = '/';
  static const library = '/library';
  static const details = '/book/details';
  static const reader = '/book/reader';
  static const author = '/authors/details';
  static const tag = '/tags/details';
  static const import = '../import.dart';
  static const character = '/characters/details';
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
      // onGenerateRoute (fix this case)
      case Routes.reader:
        final args = settings.arguments as Map<String, Object?>;
        final book = args['book'] as Book;
        final startPage = (args['startPage'] as int?) ?? 0;

        return MaterialPageRoute(
          builder: (_) => BookReader(book: book, startPage: startPage),
        );

      case Routes.author:
        // unpack the given map
        final args = settings.arguments as Map<String, dynamic>;
        final author = args['author'] as String;
        return MaterialPageRoute(
          builder: (_) => AuthorDetails(
            author: author,
          ),
        );
      case Routes.tag:
        // unpack the given map
        final args = settings.arguments as Map<String, dynamic>;
        final tag = args['tag'] as String;
        return MaterialPageRoute(
          builder: (_) => TagDetails(
            tag: tag,
          ),
        );
      // route for FAB (import)
      case Routes.import:
        return MaterialPageRoute(builder: (_) => const Import());
      case Routes.character:
        // unpack the given map
        final args = settings.arguments as Map<String, dynamic>;
        final character = args['character'] as String;
        return MaterialPageRoute(
          builder: (_) => CharactersDetails(
            characterName: character,
          ),
        );
      default:
        return null; // or a “NotFound” page
    }
  }
}
