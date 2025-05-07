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
  late PageController _pageController;
  late ScrollController _scrollController;
  int _currentPage = 0;

  // check if zoomed in
  bool _zoomedIn = false;
  // tracking for if up and down key are held
  bool _upHeld = false;
  bool _downHeld = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
  }

  // for clearing controllers
  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // change scroll position to top
  // for changing pages
  void _resetScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  // jump to a page given the index, as long as in range
  void _goToPage(int index) {
    final target = index.clamp(0, widget.book.getPageCount() - 1);
    if (target == _currentPage) return;
    // instant page jump without animation
    _pageController.jumpToPage(target);
    _resetScroll();
    setState(() {
      _currentPage = target;
    });
  }

  // page jump dialog box
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
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

  // keyboard events for nav and zoom
  void _handleKey(KeyEvent event) {
  final key = event.logicalKey;

  // Track the up/down or w/s states
  if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp) {
    _upHeld = event is KeyDownEvent;
  }
  if (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown) {
    _downHeld = event is KeyDownEvent;
  }

  if (event is KeyDownEvent) {
    if (key == LogicalKeyboardKey.escape) {
      // Escape, go back a page
      Navigator.pop(context);
    } else if (key == LogicalKeyboardKey.space) {
      // Alter zoom state, reset the scroll position to top
      _zoomedIn = !_zoomedIn;
      _resetScroll();
      setState(() {});
    } else if (key == LogicalKeyboardKey.keyA ||
        key == LogicalKeyboardKey.arrowLeft) {
      // Turn page previous
      _goToPage(_currentPage - 1);
    } else if (key == LogicalKeyboardKey.keyD ||
        key == LogicalKeyboardKey.arrowRight) {
      // Turn page next
      _goToPage(_currentPage + 1);
    } else if (_zoomedIn && _scrollController.hasClients) {
      // When zoomed in, scroll up/down when held
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
    // get the list of pages from the book
    final pages = widget.book.getPageFiles();
    // get the total number of pages
    final totalPages = pages.length;
    return KeyboardListener(
      // makes sure this recieves the key events
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          // show page indicator, opens dialog on tap
          title: GestureDetector(
              onTap: _showJumpToPageDialog,
              child: Text('${_currentPage + 1} of $totalPages')),
          centerTitle: true,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: totalPages,
          // reset scroll and update page
          onPageChanged: (i) {
            _resetScroll();
            setState(() {
              _currentPage = i;
            });
          },
          itemBuilder: (context, index) {
            // get the file for this page
            final file = pages[index];
            if (_zoomedIn) {
              // scale zoomed in view to x of screen width
              final screenW = MediaQuery.of(context).size.width;
              return SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: Image.file(
                    file,
                    width: screenW * 0.6, // change screen width here
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
              // button to jump to first page
              IconButton(
                  icon: const Icon(Icons.first_page, color: Colors.white),
                  onPressed: () => _goToPage(0)),
              // button to jump to previous page
              IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => _goToPage(_currentPage - 1)),
              // zoom toggle
              IconButton(
                icon: Icon(_zoomedIn ? Icons.zoom_out : Icons.zoom_in,
                    color: Colors.white),
                onPressed: () {
                  _zoomedIn = !_zoomedIn;
                  _resetScroll();
                  setState(() {});
                },
              ),
              // button next page
              IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => _goToPage(_currentPage + 1)),
              // button previous page
              IconButton(
                  icon: const Icon(Icons.last_page, color: Colors.white),
                  onPressed: () => _goToPage(totalPages - 1)),
            ],
          ),
        ),
      ),
    );
  }
}
