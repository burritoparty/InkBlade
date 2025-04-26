// lib/router/routes.dart

import 'package:flutter/material.dart';                               // <- for Route, MaterialPageRoute, RouteSettings
import 'package:flutter_manga_reader/models/book.dart';               // <- your Book model
import 'package:flutter_manga_reader/screen/library.dart';           // <- LibraryScreen
import 'package:flutter_manga_reader/screen/book/book_details.dart'; // <- BookDetailsScreen
import 'package:flutter_manga_reader/screen/book/book_reader.dart';  // <- BookReaderScreen

class Routes {
  static const home    = '/';
  static const library = '/library';
  static const details = '/book/details';
  static const reader  = '/book/reader';
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
      default:
        return null; // or a “NotFound” page
    }
  }
}
