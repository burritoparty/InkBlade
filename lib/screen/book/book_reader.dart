import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manga_reader/models/book.dart';

// Enhanced: recreate ScrollController on zoom or page change to avoid multiple attachments citeturn1file0
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

  // track whether if 'w' and 's' keys are currently held down
  bool _upHeld = false;
  bool _downHeld = false;

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

  void _showJumpToPageDialog() async {
    final input = TextEditingController();
    final picked = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Go to page'),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Page number',
          ),
          onSubmitted: (value) {
            final num = int.tryParse(value);
            Navigator.pop(context, num);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final num = int.tryParse(input.text);
              Navigator.pop(context, num);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
    if (picked != null) {
      _goToPage(picked - 1);
    }
  }

  void _handleKey(RawKeyEvent event) {
    final key = event.logicalKey;

    // update held state for 'w'/up arrow
    if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp) {
      _upHeld = event is RawKeyDownEvent;
    }
    // update held state for 's'/down arrow
    if (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown) {
      _downHeld = event is RawKeyDownEvent;
    }

    if (event is RawKeyDownEvent) {
      if (key == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (key == LogicalKeyboardKey.space) {
        // toggle zoom: rebuild a fresh ScrollController
        final willZoom = !_zoomedIn;
        // dispose old and create new to avoid attached positions
        _scrollController.dispose();
        _scrollController = ScrollController();
        setState(() {
          _zoomedIn = willZoom;
        });
      } else if (key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.arrowLeft) {
        // if not zoomed in and up and down are not being held
        if (!_zoomedIn || (!_upHeld && !_downHeld)) {
          _goToPage(_currentPage - 1);
        }
      } else if (key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.arrowRight) {
        // if not zoomed in and up and down are not being held
        if (!_zoomedIn || (!_upHeld && !_downHeld)) {
          _goToPage(_currentPage + 1);
        }
      } else if (_zoomedIn && _upHeld) {
        final newOffset = (_scrollController.offset - 100)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        // changed scroll down to jump instead of animate
        _scrollController.jumpTo(newOffset);
        // _scrollController.animateTo(
        //   newOffset,
        //   duration: const Duration(milliseconds: 200),
        //   curve: Curves.easeInOut,
        // );
      } else if (_zoomedIn && _downHeld) {
        final newOffset = (_scrollController.offset + 100)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        // changed scroll down to jump instead of animate
        _scrollController.jumpTo(newOffset);
        // _scrollController.animateTo(
        //   newOffset,
        //   duration: const Duration(milliseconds: 200),
        //   curve: Curves.easeInOut,
        // );
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
          title: GestureDetector(
            onTap: _showJumpToPageDialog,
            child: Text('${_currentPage + 1} of $totalPages'),
          ),
          centerTitle: true,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: totalPages,
          onPageChanged: (i) {
            // on new page, reset scrollController to detach from old page
            _scrollController.dispose();
            _scrollController = ScrollController();
            setState(() {
              _currentPage = i;
            });
          },
          itemBuilder: (context, index) {
            final file = File(r'lib\placeholders\portrait.jpg');
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
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('Image not found')),
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
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('Image not found')),
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
              IconButton(
                icon: const Icon(Icons.first_page, color: Colors.white),
                onPressed: () => _goToPage(0),
                tooltip: 'First page',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => _goToPage(_currentPage - 1),
                tooltip: 'Previous page',
              ),
              IconButton(
                icon: Icon(_zoomedIn ? Icons.zoom_out : Icons.zoom_in,
                    color: Colors.white),
                onPressed: () {
                  // toggle zoom via UI button also
                  final willZoom = !_zoomedIn;
                  // make a new scroll controller each time
                  // stop the scrolling position error
                  _scrollController.dispose();
                  _scrollController = ScrollController();
                  setState(() {
                    _zoomedIn = willZoom;
                  });
                },
                tooltip: _zoomedIn ? 'Zoom Out' : 'Zoom In',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => _goToPage(_currentPage + 1),
                tooltip: 'Next page',
              ),
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
