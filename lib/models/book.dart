// import 'package:flutter/material.dart';
class Book {
  String title;
  String author;
  List<String> tags;
  String link;
  String path;
  String coverPath;
  bool readLater;
  bool favorite; 

  Book(
    this.title,
    this.author,
    this.tags,
    this.link,
    this.path,
    this.coverPath,
    this.readLater,
    this.favorite
  );

}