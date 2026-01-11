// Standard Dart imports
import 'dart:async';

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Project-specific imports
import 'package:flutter_manga_reader/models/book.dart';
import '../../controllers/settings_controller.dart';

class BookReader extends StatefulWidget {
  final Book book;
  final int startPage;
  const BookReader({super.key, required this.book, required this.startPage});

  @override
  BookReaderState createState() => BookReaderState();
}

class BookReaderState extends State<BookReader> {
  late final SettingsController settingsController;
  late PageController _pageController;
  late ScrollController _scrollController;
  int _currentPage = 0;

  // check if zoomed in
  bool _zoomedIn = false;
  // tracking for if up and down key are held
  bool _upHeld = false;
  bool _downHeld = false;

  // scroll timer for smooth scrolling
  // and page turn debounce timer
  Timer? _scrollTimer;
  Timer? _pageTurnDebounce;

  // cursor visibility
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  late final FocusNode _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    // Clamp startPage to valid range (protects against out-of-bounds)
    final pages = widget.book.getPageFiles();
    final maxIndex = pages.isEmpty ? 0 : pages.length - 1;
    final start = pages.isEmpty ? 0 : widget.startPage.clamp(0, maxIndex);

    // initialize the settings controller
    _pageController = PageController(
      initialPage: start,
      keepPage: true,
    );
    settingsController = context.read<SettingsController>();
    _scrollController = ScrollController();
    _keyboardFocusNode = FocusNode();

    // request focus once, after first frame:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
    if (settingsController.defaultZoom) {
      _zoomedIn = true;
    }

    // set the current page
    _currentPage = start;

    // jump to the start page after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) _pageController.jumpToPage(start);
    });
  }

  // for clearing controllers
  @override
  void dispose() {
    _scrollTimer?.cancel();
    _pageTurnDebounce?.cancel();
    _cursorTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
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

// start a timer for scrolling, and call the action
  void _startScrollTimer(void Function() action) {
    _scrollTimer?.cancel();
    _scrollTimer =
        Timer.periodic(const Duration(milliseconds: 50), (_) => action());
  }

  // stop the scroll timer
  void _stopScrollTimer() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  // start a timer for rapid page turning, and call the action
  void _startRapidPageTurnTimer(void Function() action) {
    _scrollTimer?.cancel();
    _scrollTimer =
        Timer.periodic(const Duration(milliseconds: 200), (_) => action());
  }

  // keyboard events for nav and zoom
  void _handleKey(KeyEvent event) {
    final key = event.logicalKey;

    // track the up/down or w/s states
    if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp) {
      _upHeld = event is KeyDownEvent;
      if (_upHeld && _zoomedIn && _scrollController.hasClients) {
        _startScrollTimer(() {
          final increment =
              MediaQuery.of(context).size.height * 0.1; // Reduced to 10%
          final newOffset = (_scrollController.offset - increment)
              .clamp(0.0, _scrollController.position.maxScrollExtent);
          _scrollController.jumpTo(newOffset);
        });
      } else {
        _stopScrollTimer();
      }
    }
    if (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown) {
      _downHeld = event is KeyDownEvent;
      if (_downHeld && _zoomedIn && _scrollController.hasClients) {
        _startScrollTimer(() {
          final increment =
              MediaQuery.of(context).size.height * 0.1; // Reduced to 10%
          final newOffset = (_scrollController.offset + increment)
              .clamp(0.0, _scrollController.position.maxScrollExtent);
          _scrollController.jumpTo(newOffset);
        });
      } else {
        _stopScrollTimer();
      }
    }

    if (event is KeyDownEvent) {
      if (key == LogicalKeyboardKey.escape) {
        // escape, go back a page
        Navigator.pop(context);
      } else if (key == LogicalKeyboardKey.space) {
        // alter zoom state, reset the scroll position to top
        _zoomedIn = !_zoomedIn;
        _resetScroll();
        setState(() {});
      } else if (key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.arrowLeft) {
        // immediate page turn
        _goToPage(_currentPage - 1);
        // start rapid page turning after 1 second
        _scrollTimer?.cancel();
        _scrollTimer = Timer(const Duration(milliseconds: 500), () {
          _startRapidPageTurnTimer(() => _goToPage(_currentPage - 1));
        });
      } else if (key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.arrowRight) {
        // immediate page turn
        _goToPage(_currentPage + 1);
        // start rapid page turning after 1 second
        _scrollTimer?.cancel();
        _scrollTimer = Timer(const Duration(milliseconds: 500), () {
          _startRapidPageTurnTimer(() => _goToPage(_currentPage + 1));
        });
      }
    } else if (event is KeyUpEvent) {
      if (key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.arrowRight) {
        // stop rapid page turning
        _stopScrollTimer();
      }
    }
  }

  // method to reset the cursor visibility timer
  void _resetCursorTimer() {
    _cursorTimer?.cancel();
    setState(() {
      _cursorVisible = true;
    });
    _cursorTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        _cursorVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // get the list of pages from the book
    final pages = widget.book.getPageFiles();
    // get the total number of pages
    final totalPages = pages.length;
    return MouseRegion(
      onHover: (_) => _resetCursorTimer(),
      cursor:
          _cursorVisible ? SystemMouseCursors.basic : SystemMouseCursors.none,
      child: KeyboardListener(
        // makes sure this receives the key events
        focusNode: _keyboardFocusNode,
        onKeyEvent: _handleKey,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  // navigate back to the home screen
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                },
              ),
            ],
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
                return AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('Image not found')),
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
      ),
    );
  }
}
