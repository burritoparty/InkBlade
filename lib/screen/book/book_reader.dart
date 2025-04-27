import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manga_reader/models/book.dart';

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

  void _resetScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _goToPage(int index) {
    final target = index.clamp(0, totalPages - 1);
    if (target == _currentPage) return;
    // instant page jump without animation
    _pageController.jumpToPage(target);
    _resetScroll();
    setState(() {
      _currentPage = target;
    });
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
          decoration: const InputDecoration(labelText: 'Page number'),
          onSubmitted: (value) {
            final num = int.tryParse(value);
            Navigator.pop(context, num);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
    if (picked != null) _goToPage(picked - 1);
  }

  void _handleKey(RawKeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp) {
      _upHeld = event is RawKeyDownEvent;
    }
    if (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown) {
      _downHeld = event is RawKeyDownEvent;
    }

    if (event is RawKeyDownEvent) {
      if (key == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (key == LogicalKeyboardKey.space) {
        _zoomedIn = !_zoomedIn;
        _resetScroll();
        setState(() {});
      } else if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft) {
        if (!_zoomedIn || (!_upHeld && !_downHeld)) {
          _goToPage(_currentPage - 1);
        }
      } else if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.arrowRight) {
        if (!_zoomedIn || (!_upHeld && !_downHeld)) {
          _goToPage(_currentPage + 1);
        }
      } else if (_zoomedIn && _scrollController.hasClients) {
        if (_upHeld) {
          final newOffset = (_scrollController.offset - 100)
              .clamp(0.0, _scrollController.position.maxScrollExtent);
          _scrollController.jumpTo(newOffset);
        } else if (_downHeld) {
          final newOffset = (_scrollController.offset + 100)
              .clamp(0.0, _scrollController.position.maxScrollExtent);
          _scrollController.jumpTo(newOffset);
        }
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
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          title: GestureDetector(onTap: _showJumpToPageDialog, child: Text('${_currentPage + 1} of $totalPages')),
          centerTitle: true,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: totalPages,
          onPageChanged: (i) {
            _resetScroll();
            setState(() {
              _currentPage = i;
            });
          },
          itemBuilder: (context, index) {
            final file = File(r'lib\placeholders\portrait.jpg');
            if (_zoomedIn) {
              final screenW = MediaQuery.of(context).size.width;
              return SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: Image.file(
                    file,
                    width: screenW * 0.6,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => const Center(child: Text('Image not found')),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 2/3,
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
              IconButton(icon: const Icon(Icons.first_page, color: Colors.white), onPressed: () => _goToPage(0)),
              IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => _goToPage(_currentPage - 1)),
              IconButton(
                icon: Icon(_zoomedIn ? Icons.zoom_out : Icons.zoom_in, color: Colors.white),
                onPressed: () {
                  _zoomedIn = !_zoomedIn;
                  _resetScroll();
                  setState(() {});
                },
              ),
              IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => _goToPage(_currentPage + 1)),
              IconButton(icon: const Icon(Icons.last_page, color: Colors.white), onPressed: () => _goToPage(totalPages - 1)),
            ],
          ),
        ),
      ),
    );
  }
}
