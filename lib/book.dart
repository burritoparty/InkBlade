// import 'package:flutter/material.dart';
class Book {
  final String name;
  final String author;
  final String link;
  final List<String> tags;
  final String coverPath;
  final bool readLater;
  final bool favorite; 

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