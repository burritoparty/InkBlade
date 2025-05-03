// import 'package:flutter/material.dart';
class Book {
  String path;
  String title;
  String author;
  String link;
  String series;
  List<String> tags;
  List<String> characters;
  bool favorite;
  bool readLater;
  // String coverPath;

  Book(
    this.path,
    this.title,
    this.author,
    this.link,
    this.series,
    this.tags,
    this.characters,
    this.favorite,
    this.readLater,
  );
}
