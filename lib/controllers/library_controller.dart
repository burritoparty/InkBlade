import 'dart:io';

import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/library_repository.dart';
import 'package:path_provider/path_provider.dart'; // for getApplicationDocumentsDirectory()
import 'package:path/path.dart' as p;

class LibraryController extends ChangeNotifier {
  final LibraryRepository _libraryRepository;

  // this will hold the keys to the kingdom
  List<Book> _books = [];

  final Set<String> _authors = {};
  final Set<String> _tags = {};
  final Set<String> _series = {};
  final Set<String> _characters = {};

  // initialize the repository
  LibraryController(this._libraryRepository);

  // getters for the books and their attributes
  List<Book> get books => _books;
  Set<String> get authors => _authors;
  Set<String> get tags => _tags;
  Set<String> get series => _series;
  Set<String> get characters => _characters;

  // call this at startup
  Future<void> init() async {
    // await the repository to be initialized
    await _libraryRepository.init();
    // load the books from the json file
    _books = await _libraryRepository.loadBooks();
    // update the sets with the loaded books
    _rebuildSets();
    // notify listeners to update the UI
    notifyListeners();
  }

  void _rebuildSets() {
    // clear the sets
    _authors.clear();
    _tags.clear();
    _series.clear();
    _characters.clear();

    // loop through all books and add their values to the sets
    for (Book book in _books) {
      _authors.addAll(book.authors);
      _tags.addAll(book.tags);
      _series.add(book.series);
      _characters.addAll(book.characters);
    }
  }

  // recursively copy a folder
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) {
      // create destination and any missing parent dirs
      await destination.create(recursive: true);
    }
    for (final entity in source.listSync()) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        // recurse into sub-directory
        await _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        // copy file
        await entity.copy(newPath);
      }
    }
  }

  // add a book to the list and save it to the json file
  // checks if the book already exists in the list
  Future<void> addBook(Book book) async {
    // determine your app documents dir
    final docsDir = await getApplicationDocumentsDirectory();
    // build the target Library/<bookTitle> path
    final targetDir = Directory(
      p.join(docsDir.path, 'InkBlade', 'Library', book.title),
    );
    // copy the entire folder over
    await _copyDirectory(Directory(book.path), targetDir);
    // update the book’s path to the new internal location
    book.path = targetDir.path;
    // check if the book already exists in the list
    if (_books.any((b) => b.path == book.path)) {
      return;
    }
    // add the book to the list
    _books.add(book);
    // update the sets with the new book
    _rebuildSets();
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
  }

  // remove a book from the list and save it to the json file
  Future<void> removeBook(Book book) async {
    // remove the book from the list
    _books.remove(book);
    // update the sets with the new book
    _rebuildSets();
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
  }

  Future<bool> updateTitle(Book book, String newTitle) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // check if the book exists in the list or if the new title is empty
    if (index == -1 || newTitle.trim().isEmpty) {
      return false;
    }
    // update the title of the book
    _books[index].title = newTitle;
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateLink(Book book, String newLink) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // check if the book exists in the list
    if (index == -1) {
      return false;
    }
    // don't need to check if link is empty, because it can be empty
    // update the link of the book
    _books[index].link = newLink;
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateSeries(Book book, String newSeries) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // check if the book exists in the list
    if (index == -1) {
      return false;
    }
    // don't need to check if series is empty, because it can be empty
    // update the series of the book
    _books[index].series = newSeries;
    // rebuild the sets with the new series
    _rebuildSets();
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateAuthors(Book book, String newAuthor, bool remove) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // normalize input
    newAuthor = newAuthor.trim();
    // protect against empty author, and if author already exists
    // and if the book exists in the list
    if (index == -1 || newAuthor.isEmpty) {
      return false;
    }
    // update the authors of the book
    if (remove) {
      _books[index].authors.remove(newAuthor);
    } else {
      _books[index].authors.add(newAuthor);
    }
    // rebuild the sets with the new author
    _rebuildSets();
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateTags(Book book, String newTag, bool remove) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // normalize input
    newTag = newTag.trim();
    // protect against empty tag, and if tag already exists
    // and if the book exists in the list
    if (index == -1 || newTag.isEmpty) {
      return false;
    }
    // update the tags of the book
    if (remove) {
      _books[index].tags.remove(newTag);
    } else {
      _books[index].tags.add(newTag);
    }
    // rebuild the sets with the new tag
    _rebuildSets();
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateCharacters(Book book, String newCharacter, bool remove) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // normalize input
    newCharacter = newCharacter.trim();
    // protect against empty character, and if character already exists
    // and if the book exists in the list
    if (index == -1 || newCharacter.isEmpty) {
      return false;
    }
    // update the characters of the book
    if (remove) {
      _books[index].characters.remove(newCharacter);
    }
    else {
      _books[index].characters.add(newCharacter);
    }
    // rebuild the sets with the new character
    _rebuildSets();
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners thowso update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateFavorite(Book book, bool newFavorite) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // check if the book exists in the list
    if (index == -1) {
      return false;
    }
    // update the favorite status of the book
    _books[index].favorite = newFavorite;
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateReadLater(Book book, bool newReadLater) async {
    // find the book in the list
    final index = _books.indexWhere((b) => b.path == book.path);
    // check if the book exists in the list
    if (index == -1) {
      return false;
    }
    // update the read later status of the book
    _books[index].readLater = newReadLater;
    // save the books to the json file
    await _libraryRepository.saveBooks(_books);
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<void> removeAuthorFromBooks(String author) async {
    for (final book in _books) {
      book.authors.remove(author);
    }
    // rebuild the sets and save the updated books
    _rebuildSets();
    await _libraryRepository.saveBooks(_books);
    notifyListeners();
  }

  Future<void> renameAuthor(String oldAuthor, String newAuthor) async {
    for (final book in _books) {
      if (book.authors.remove(oldAuthor)) {
        book.authors.add(newAuthor);
      }
    }
    // rebuild the sets and save the updated books
    _rebuildSets();
    await _libraryRepository.saveBooks(_books);
    notifyListeners();
  }

  Future<void> renameTag(String oldTag, String newTag) async {
    for (final book in _books) {
      if (book.tags.remove(oldTag)) {
        book.tags.add(newTag);
      }
    }
    // rebuild the sets and save the updated books
    _rebuildSets();
    await _libraryRepository.saveBooks(_books);
    notifyListeners();
  }

  Future<void> removeTagFromBooks(String tag) async {
    for (final book in _books) {
      book.tags.remove(tag);
    }
    // Rebuild the sets and save the updated books
    _rebuildSets();
    await _libraryRepository.saveBooks(_books);
    notifyListeners();
  }
}
