// models/book.dart

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
}
