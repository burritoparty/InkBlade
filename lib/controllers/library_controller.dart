// Standard Dart imports
import 'dart:io';
import 'package:flutter/painting.dart';

// Third-party package imports
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Project-specific imports
import '../models/book.dart';
import '../services/library_repository.dart';

class LibraryController extends ChangeNotifier {
  final LibraryRepository _libraryRepository;

  List<Book> _books = [];
  final Set<String> _authors = {};
  final Set<String> _tags = {};
  final Set<String> _series = {};
  final Set<String> _characters = {};
  final Map<String, String> _tagDescriptions = {};

  // Map of tag name to thumbnail path
  final Map<String, String> tagThumbnails = {};

  // initialize the repository
  LibraryController(this._libraryRepository);

  // getters for the books and their attributes
  List<Book> get books => _books;
  Set<String> get authors => _authors;
  Set<String> get tags => _tags;
  Set<String> get series => _series;
  Set<String> get characters => _characters;
  Map<String, String> get tagDescriptions => _tagDescriptions;

  // call this at startup
  Future<void> init() async {
    // await the repository to be initialized
    await _libraryRepository.init();

    // Load the full JSON (not just books)
    final Map<String, dynamic> json =
        await _libraryRepository.loadLibraryJson();

    // Load books
    final booksJson = json['book'] ?? [];
    _books = List<Book>.from(booksJson.map((b) => Book.fromJson(b)));

    // Load tagThumbnails, ensure it's always a Map<String, String>
    final tagThumbsJson = json['tagThumbnails'];
    if (tagThumbsJson is Map) {
      tagThumbnails
        ..clear()
        ..addAll(Map<String, String>.from(tagThumbsJson));
    } else {
      tagThumbnails.clear();
    }

    // If tagThumbnails was missing, ensure it's present in the JSON and save
    if (json['tagThumbnails'] == null) {
      await _saveLibraryJson();
    }

    // Ensure thumbnails directory exists
    final docsDir = await getApplicationDocumentsDirectory();
    final thumbnailsDir =
        Directory(p.join(docsDir.path, 'InkBlade', 'thumbnails'));
    if (!await thumbnailsDir.exists()) {
      await thumbnailsDir.create(recursive: true);
    }

    final tagDescJson = json['tagDescriptions'];
    _tagDescriptions.clear();
    if (tagDescJson is Map) {
      _tagDescriptions.addAll(Map<String, String>.from(tagDescJson));
    }

    _rebuildSets();
    notifyListeners();
  }

  // Save both books and tagThumbnails to the JSON file
  Future<void> _saveLibraryJson() async {
    final Map<String, dynamic> json =
        await _libraryRepository.loadLibraryJson();

    json['book'] = _books.map((b) => b.toJson()).toList();
    json['tagThumbnails'] = tagThumbnails;
    json['tagDescriptions'] = _tagDescriptions;

    await _libraryRepository.saveLibraryJson(json);
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

  // Method to check if a book title already exists
  bool doesBookTitleExist(String title) {
    return _books
        .any((book) => book.title.toLowerCase() == title.toLowerCase().trim());
  }

// Strip leading article only if followed by a LETTER (not a digit)
  String _stripLeadingArticle(String input, {bool ignoreArticles = true}) {
    var s = (input).trim();
    if (!ignoreArticles || s.isEmpty) return s;
    final re = RegExp(r'^(?:the|a|an)\s+(?=[A-Za-z])', caseSensitive: false);
    return s.replaceFirst(re, '');
  }

// Split into numeric and non-numeric segments for natural sort
  List<dynamic> _naturalSegments(String s) {
    final segs = <dynamic>[];
    final re = RegExp(r'(\d+)|(\D+)');
    for (final m in re.allMatches(s)) {
      final numPart = m.group(1);
      if (numPart != null) {
        segs.add(int.parse(numPart));
      } else {
        segs.add(m.group(2)!.toLowerCase());
      }
    }
    return segs;
  }

// Natural compare with smart article handling
  int _naturalCompareTitles(String a, String b, {bool ignoreArticles = true}) {
    final sa = _stripLeadingArticle(a, ignoreArticles: ignoreArticles);
    final sb = _stripLeadingArticle(b, ignoreArticles: ignoreArticles);

    final A = _naturalSegments(sa);
    final B = _naturalSegments(sb);
    final n = A.length < B.length ? A.length : B.length;

    for (var i = 0; i < n; i++) {
      final x = A[i], y = B[i];
      if (x is int && y is int) {
        if (x != y) return x.compareTo(y);
      } else if (x is int && y is String) {
        return -1; // numbers sort before letters
      } else if (x is String && y is int) {
        return 1; // letters after numbers
      } else {
        final cmp = (x as String).compareTo(y as String);
        if (cmp != 0) return cmp;
      }
    }
    return A.length.compareTo(B.length);
  }

  // Sort the library JSON on disk (and in memory) by book title.
  // Uses 'name' if present, otherwise falls back to 'title'.
  Future<void> sortLibraryJsonByTitle({bool ignoreArticles = true}) async {
    // Load current JSON
    final Map<String, dynamic> json =
        await _libraryRepository.loadLibraryJson();

    final List<dynamic> raw = (json['book'] as List<dynamic>?) ?? <dynamic>[];

    // Sort raw JSON maps without assuming the full Book model
    raw.sort((a, b) {
      final at = (a as Map)['name'] ?? (a)['title'] ?? '';
      final bt = (b as Map)['name'] ?? (b)['title'] ?? '';
      return _naturalCompareTitles(at.toString(), bt.toString(),
          ignoreArticles: true);
    });

    // Save back to disk
    json['book'] = raw;
    await _libraryRepository.saveLibraryJson(json);

    // Refresh in-memory list to match the new order
    _books = List<Book>.from(
        raw.map((m) => Book.fromJson(Map<String, dynamic>.from(m as Map))));
    notifyListeners();
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
    await _saveLibraryJson();

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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
    // notify listeners to update the UI
    notifyListeners();
    // return true to indicate success
    return true;
  }

  Future<bool> updateCharacters(
      Book book, String newCharacter, bool remove) async {
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
    } else {
      _books[index].characters.add(newCharacter);
    }
    // rebuild the sets with the new character
    _rebuildSets();
    // save the books to the json file
    await _saveLibraryJson();
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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
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
    await _saveLibraryJson();
    notifyListeners();
  }

  Future<void> renameTag(String oldTag, String newTag) async {
    if (oldTag == newTag) return;

    // 1) Update all books' tag lists
    for (final book in _books) {
      if (book.tags.remove(oldTag)) {
        book.tags.add(newTag);
      }
    }

    // Move tag description to the new tag name
    if (_tagDescriptions.containsKey(oldTag)) {
      final String oldDesc = _tagDescriptions[oldTag] ?? '';
      final String existingNewDesc = _tagDescriptions[newTag] ?? '';

      // Keep an existing newTag description if it already has one
      if (existingNewDesc.trim().isEmpty) {
        _tagDescriptions[newTag] = oldDesc;
      }

      _tagDescriptions.remove(oldTag);
    }

    // 2) If there's a thumbnail mapped to the old tag, rename the file on disk
    if (tagThumbnails.containsKey(oldTag)) {
      final String? oldPath = tagThumbnails[oldTag];
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final thumbnailsDir =
            Directory(p.join(docsDir.path, 'InkBlade', 'thumbnails'));
        if (!await thumbnailsDir.exists()) {
          await thumbnailsDir.create(recursive: true);
        }

        if (oldPath != null) {
          final String ext = p.extension(oldPath).toLowerCase();
          final String newPath = p.join(thumbnailsDir.path, '$newTag$ext');

          // Evict any cached images for the old path before renaming
          try {
            await FileImage(File(oldPath)).evict();
          } catch (_) {}

          if (oldPath != newPath) {
            // If a file already exists at the new path, replace it
            final newFile = File(newPath);
            if (await newFile.exists()) {
              try {
                await newFile.delete();
              } catch (_) {}
            }
            final oldFile = File(oldPath);
            if (await oldFile.exists()) {
              try {
                await oldFile.rename(newPath);
              } catch (_) {
                // If rename fails (e.g., cross-device), copy as a fallback
                try {
                  await oldFile.copy(newPath);
                  await oldFile.delete();
                } catch (_) {}
              }
            }
          }

          // Evict any cached images for the new path after renaming
          try {
            await FileImage(File(newPath)).evict();
          } catch (_) {}

          // Update the mapping
          tagThumbnails.remove(oldTag);
          tagThumbnails[newTag] = newPath;
        } else {
          // oldPath was null: still move the mapping key to keep JSON clean
          final String newPath = p.join(thumbnailsDir.path, '$newTag.jpg');
          tagThumbnails.remove(oldTag);
          tagThumbnails[newTag] = newPath;
        }
      } catch (_) {
        // Best-effort: even if file ops fail, ensure mapping key is updated
        final String? oldPathLocal = tagThumbnails[oldTag];
        final String ext = oldPathLocal != null
            ? p.extension(oldPathLocal).toLowerCase()
            : '.jpg';
        final docsDir = await getApplicationDocumentsDirectory();
        final thumbnailsDir =
            Directory(p.join(docsDir.path, 'InkBlade', 'thumbnails'));
        final String newPath = p.join(thumbnailsDir.path, '$newTag$ext');
        tagThumbnails.remove(oldTag);
        tagThumbnails[newTag] = newPath;
      }
    }

    // 3) Recompute sets and persist JSON
    _rebuildSets();
    await _saveLibraryJson();
    notifyListeners();
  }

  Future<void> removeTagFromBooks(String tag) async {
    for (final book in _books) {
      book.tags.remove(tag);
    }
    _rebuildSets();
    await _saveLibraryJson();
    notifyListeners();
  }

  // Set thumbnail for a tag
  Future<void> setTagThumbnail(String tag, String imagePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final thumbnailsDir =
        Directory(p.join(docsDir.path, 'InkBlade', 'thumbnails'));

    if (!await thumbnailsDir.exists()) {
      await thumbnailsDir.create(recursive: true);
    }

    final String ext = p.extension(imagePath).toLowerCase();
    final String destPath = p.join(thumbnailsDir.path, '$tag$ext');

    final savedFile = await File(imagePath).copy(destPath);

    tagThumbnails[tag] = savedFile.path;
    // Evict any cached version of this file so it reloads next time
    try {
      await FileImage(File(savedFile.path)).evict();
    } catch (_) {}
    await _saveLibraryJson();
    notifyListeners();
  }

  // Get thumbnail for a tag (returns null if not set)
  String? getTagThumbnail(String tag) {
    return tagThumbnails[tag];
  }

  // Set description for a tag
  Future<void> setTagDescription(String tag, String description) async {
    final Map<String, dynamic> json =
        await _libraryRepository.loadLibraryJson();

    final existing = json['tagDescriptions'];
    final Map<String, dynamic> tagDesc = existing is Map
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{};

    tagDesc[tag] = description;
    json['tagDescriptions'] = tagDesc;

    await _libraryRepository.saveLibraryJson(json);

    _tagDescriptions[tag] = description;
    notifyListeners();
  }

  String getTagDescription(String tag) {
    return _tagDescriptions[tag] ?? "";
  }

  Future<void> renameSeries(String from, String to) async {
    final oldKey = from.trim().toLowerCase();
    for (final b in books) {
      final s = (b.series).trim().toLowerCase();
      if (s == oldKey) {
        b.series = to.trim();
      }
    }
    notifyListeners();
  }

  Future<void> renameCharacter(String from, String to) async {
    final oldKey = from.trim().toLowerCase();
    final newVal = to.trim();
    for (final b in books) {
      final list = b.characters;
      for (var i = 0; i < list.length; i++) {
        if ((list[i]).trim().toLowerCase() == oldKey) {
          list[i] = newVal;
        }
      }
    }
    notifyListeners();
  }

  Future<void> deleteSeries(String seriesName) async {
    final key = seriesName.trim().toLowerCase();
    for (final b in books) {
      final s = (b.series).trim().toLowerCase();
      if (s == key) {
        b.series = "";
      }
    }
    notifyListeners();
  }

  Future<void> deleteCharacter(String characterName) async {
    final key = characterName.trim().toLowerCase();
    for (final b in books) {
      final list = b.characters;
      list.removeWhere((item) => item.trim().toLowerCase() == key);
    }
    notifyListeners();
  }
}
