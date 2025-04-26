import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manga_reader/book.dart';

class BookReader extends StatefulWidget {
  final Book book;
  const BookReader({Key? key, required this.book}) : super(key: key);

  @override
  BookReaderState createState() => BookReaderState();
}

class BookReaderState extends State<BookReader> {
  final int totalPages = 28;
  late PageController _pageController;
  late ScrollController _scrollController;
  int _currentPage = 0;
  bool _zoomedIn = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    final target = index.clamp(0, totalPages - 1);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (key == LogicalKeyboardKey.space) {
        setState(() {
          _zoomedIn = !_zoomedIn;
          if (!_zoomedIn && _scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
      } else if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft) {
        _goToPage(_currentPage - 1);
      } else if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.arrowRight) {
        _goToPage(_currentPage + 1);
      } else if (_zoomedIn && (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp)) {
        final newOffset = (_scrollController.offset - 100)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } else if (_zoomedIn && (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown)) {
        final newOffset = (_scrollController.offset + 100)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('${_currentPage + 1} of $totalPages'),
          centerTitle: true,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: totalPages,
          onPageChanged: (i) {
            setState(() {
              _currentPage = i;
              if (_zoomedIn && _scrollController.hasClients) {
                _scrollController.jumpTo(0);
              }
            });
          },
          itemBuilder: (context, index) {
            final file = File(
              r'c:\Users\burrito\Desktop\Burrito Manga Reader\Burrito Manga Reader Library\(C86) [Saigado] ASUKA28 (Neon Genesis Evangelion) [English] [Chocolate + LWB]\02.jpg',
            );
            if (_zoomedIn) {
              const zoomFactor = 0.6;
              final screenW = MediaQuery.of(context).size.width;
              return SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: Image.file(
                    file,
                    width: screenW * zoomFactor,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => const Center(child: Text('Image not found')),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(child: Text('Image not found')),
                  ),
                ),
              );
            }
          },
        ),
        bottomNavigationBar: Container(
          color: Colors.blueGrey[900],
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Jump to first page
              IconButton(
                icon: const Icon(Icons.first_page, color: Colors.white),
                onPressed: () => _goToPage(0),
                tooltip: 'First page',
              ),
              // Previous page
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => _goToPage(_currentPage - 1),
                tooltip: 'Previous page',
              ),
              // Zoom toggle
              IconButton(
                icon: Icon(
                  _zoomedIn ? Icons.zoom_out : Icons.zoom_in,
                  color: Colors.white,
                ),
                onPressed: () => setState(() {
                  _zoomedIn = !_zoomedIn;
                  if (!_zoomedIn && _scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                }),
                tooltip: _zoomedIn ? 'Zoom Out' : 'Zoom In',
              ),
              // Next page
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => _goToPage(_currentPage + 1),
                tooltip: 'Next page',
              ),
              // Jump to last page
              IconButton(
                icon: const Icon(Icons.last_page, color: Colors.white),
                onPressed: () => _goToPage(totalPages - 1),
                tooltip: 'Last page',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
