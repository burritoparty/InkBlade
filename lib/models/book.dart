// Standard Dart imports
import 'dart:io';

// Third-party package imports
import 'package:path/path.dart' as p;

class Book {
  String path;
  String title;
  String link;
  String series;
  List<String> authors;
  List<String> tags;
  List<String> characters;
  bool favorite;
  bool readLater;

  Book({
    required this.path,
    required this.title,
    required this.link,
    required this.series,
    required this.authors,
    required this.tags,
    required this.characters,
    required this.favorite,
    required this.readLater,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        path: json['path'] as String,
        title: json['title'] as String,
        link: json['link'] as String,
        series: json['series'] as String,
        authors: List<String>.from(json['authors'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
        characters: List<String>.from(json['characters'] ?? []),
        favorite: json['favorite'] as bool,
        readLater: json['readLater'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'path': path,
        'title': title,
        'link': link,
        'series': series,
        'authors': authors,
        'tags': tags,
        'characters': characters,
        'favorite': favorite,
        'readLater': readLater,
      };

  String getCoverPath() {
    // ensure the directory exists
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return '';
    }

    // list all entries in the folder
    final entries = dir.listSync();

    // filter to just files with image extensions
    final images = entries.whereType<File>().where((file) {
      final ext = p.extension(file.path).toLowerCase();
      return ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);
    }).toList();

    // if no images, bail out
    if (images.isEmpty) {
      return '';
    }

    // sort by filename so it's consistent
    images.sort((a, b) => a.path.compareTo(b.path));

    // return the very first image's path
    return images.first.path;
  }

  // getter for the page count
  int getPageCount() {
    return getPageFiles().length;
  }

  // use this to sort your page files naturally (1,2,3,...10,11)
  int _pageCompare(File a, File b) {
    int? na = _numericKey(p.basenameWithoutExtension(a.path));
    int? nb = _numericKey(p.basenameWithoutExtension(b.path));

    // if both have a numeric part, compare numerically
    if (na != null && nb != null) {
      final c = na.compareTo(nb);
      if (c != 0) return c;
    }

    // tie-break (or if no numbers), fall back to case-insensitive name compare
    return p
        .basename(a.path)
        .toLowerCase()
        .compareTo(p.basename(b.path).toLowerCase());
  }

  // extracts the last number in the name (handles things like "page_002", "ch1-p12")
  int? _numericKey(String name) {
    final matches = RegExp(r'\d+').allMatches(name);
    if (matches.isEmpty) return null;
    return int.tryParse(matches.last.group(0)!);
  }

  bool _isImage(String path) {
    final ext = p.extension(path).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp';
  }

  List<File> getPageFiles() {
    final dir = Directory(path);
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => _isImage(f.path))
        .toList();

    files.sort(_pageCompare);
    return files;
  }
}
