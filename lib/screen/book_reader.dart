import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/book.dart';
import 'dart:io';

class BookReader extends StatefulWidget {
  final Book book;
  const BookReader({Key? key, required this.book}) : super(key: key);

  @override
  BookReaderState createState() => BookReaderState();
}

class BookReaderState extends State<BookReader> {
  final int totalPages = 28;
  late PageController _controller;
  int _currentPage = 0;
  bool _zoomedIn = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int delta) {
    final next = (_currentPage + delta).clamp(0, totalPages - 1);
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top bar: back and page counter
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${_currentPage + 1} of $totalPages'),
        centerTitle: true,
      ),

      // pages
      body: PageView.builder(
        controller: _controller,
        itemCount: totalPages,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, index) {
          final file = File(
            r'c:\Users\burrito\Desktop\Burrito Manga Reader\Burrito Manga Reader Library\(C86) [Saigado] ASUKA28 (Neon Genesis Evangelion) [English] [Chocolate + LWB]\02.jpg',
          );

          if (_zoomedIn) {
            const zoomFactor =
                0.6; // adjust for zoom size
            final screenW = MediaQuery.of(context).size.width;

            return SingleChildScrollView(
              // center it so extra width overflows equally on both sides
              child: Center(
                child: Image.file(
                  file,
                  width:
                      screenW * zoomFactor, // make wider than screen
                  fit: BoxFit.fitWidth, // fill width
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Text('Image not found')),
                ),
              ),
            );
          } else {
            // fit whole page
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Text('Image not found')),
                ),
              ),
            );
          }
        },
      ),

      // Bottom bar: prev, zoom toggle, next
      bottomNavigationBar: Container(
        color: Colors.blueGrey[900],
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => _goToPage(-1),
              tooltip: 'Previous page',
            ),
            IconButton(
              icon: Icon(
                _zoomedIn ? Icons.zoom_out : Icons.zoom_in,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _zoomedIn = !_zoomedIn),
              tooltip: _zoomedIn ? 'Zoom Out' : 'Zoom In',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () => _goToPage(1),
              tooltip: 'Next page',
            ),
          ],
        ),
      ),
    );
  }
}
