import 'book.dart';

class LibraryHandler {
  List<Book> _allBooks;
  List<String> _allAuthors;
  List<String> _allTags;

  LibraryHandler(
    this._allBooks,
    this._allAuthors,
    this._allTags,
  );
}
