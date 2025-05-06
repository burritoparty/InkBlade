// import 'package:flutter/material.dart';
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
  // String coverPath;

  Book(
    this.path,
    this.title,
    this.link,
    this.series,
    this.authors,
    this.tags,
    this.characters,
    this.favorite,
    this.readLater,
  );
}
