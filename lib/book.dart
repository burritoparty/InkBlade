// import 'package:flutter/material.dart';
class Book {
  String name;
  String author;
  String link;
  List<String> tags;
  String coverPath;
  bool readLater;
  bool favorite; 

  Book(
    this.name,
    this.author,
    this.link,
    this.tags,
    this.coverPath,
    this.readLater,
    this.favorite
  );

}