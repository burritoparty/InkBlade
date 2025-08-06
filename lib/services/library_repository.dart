// Standard Dart imports
import 'dart:convert';
import 'dart:io';

// Third-party package imports
import 'package:path_provider/path_provider.dart';

// Project-specific imports
import '../models/book.dart';

class LibraryRepository {
  // placeholder for json file
  late final File _file;

  // call once app starts to setup the file
  Future<void> init() async {
    // get the application documents directory
    // and create a file called library.json in it
    final dir = await getApplicationDocumentsDirectory();
    // create app folder if it doesn't exist
    final appDir = Directory('${dir.path}/InkBlade');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    // create library folder if it doesn't exist
    final libraryFolder = Directory('${appDir.path}/library');
    if (!await libraryFolder.exists()) {
      await libraryFolder.create(recursive: true);
    }

    // point the file at where library.json should be
    _file = File('${appDir.path}/library.json');
    // Check if the file exists, if not create it
    if (!await _file.exists()) {
      await _file
          .writeAsString(JsonEncoder.withIndent('  ').convert({'book': []}));
    }
  }

  // read and parse json into real dart objects
  Future<List<Book>> loadBooks() async {
    // read the file as a string
    final raw = await _file.readAsString();
    // decode the string into a Dart Map<String, dynamic>
    final data = jsonDecode(raw) as Map<String, dynamic>;
    // exrtact the books list, cast it to a List<Map<String, dynamic>>
    // String being the key and dynamic being the value
    final list = (data['book'] as List).cast<Map<String, dynamic>>();
    // return the list of books as a List<Book>, sorted alphabetically by title
    return list.map(Book.fromJson).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  // save the books to the file as a json string
  Future<void> saveBooks(List<Book> books) async {
    // sort books alphabetically by title before saving
    books.sort((a, b) => a.title.compareTo(b.title));
    final data = {'book': books.map((b) => b.toJson()).toList()};
    // write out indented JSON
    await _file.writeAsString(JsonEncoder.withIndent('  ').convert(data));
  }

  // Load the entire library JSON as a Map<String, dynamic>
  Future<Map<String, dynamic>> loadLibraryJson() async {
    final raw = await _file.readAsString();
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // Save the entire library JSON from a Map<String, dynamic>
  Future<void> saveLibraryJson(Map<String, dynamic> json) async {
    await _file.writeAsString(JsonEncoder.withIndent('  ').convert(json));
  }
}
