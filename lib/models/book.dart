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

// get the book's pages and return as File objects
  List<File> getPageFiles() {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return [];
    }

    final images = dir.listSync().whereType<File>().where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);
    }).toList();

    // Natural sort by filename
    images.sort((a, b) {
      final nameA = p.basenameWithoutExtension(a.path);
      final nameB = p.basenameWithoutExtension(b.path);

      // This regex needs to be more specific.
      // It should target the *last* sequence of digits, ideally after an underscore.
      // Let's use a regex that matches numbers at the end of the string, optionally prefixed by an underscore.
      final regex = RegExp(r'_(\d+)$'); // This is the crucial change!

      final matchA = regex.firstMatch(nameA);
      final matchB = regex.firstMatch(nameB);

      final numStringA =
          matchA?.group(1); // Get the captured group (the digits)
      final numStringB =
          matchB?.group(1); // Get the captured group (the digits)
          
      if (numStringA != null && numStringB != null) {
        final numA = int.tryParse(numStringA) ?? 0;
        final numB = int.tryParse(numStringB) ?? 0;
        return numA.compareTo(numB);
      }

      // Fallback to string comparison if no specific number is found or parsing fails
      // This fallback will now only be used if the filenames DON'T conform to the expected pattern
      return nameA.compareTo(nameB);
    });

    return images;
  }
}
