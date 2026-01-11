import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  late final PageController _pageController;

  int _currentPage = 0;

  bool _zoomedIn = false;
  bool _upHeld = false;
  bool _downHeld = false;

  Timer? _scrollTimer;
  Timer? _pageTurnDebounce;

  Timer? _holdDelayTimer;
  Timer? _rapidPageTurnTimer;

  bool _leftHeld = false;
  bool _rightHeld = false;

  bool _cursorVisible = true;
  Timer? _cursorTimer;

  bool _dialogOpen = false;

  late final FocusNode _keyboardFocusNode;

  final Map<int, ScrollController> _scrollControllers = {};
  ScrollController? _activeScrollController;

  static const Duration _rapidHoldDelay = Duration(milliseconds: 300);
  static const Duration _rapidFlipInterval = Duration(milliseconds: 90);

  ScrollController _controllerForPage(int pageIndex) {
    return _scrollControllers.putIfAbsent(pageIndex, () => ScrollController());
  }

  void _setActiveScrollController(int pageIndex) {
    _activeScrollController = _controllerForPage(pageIndex);
  }

  @override
  void initState() {
    super.initState();

    final pages = widget.book.getPageFiles();
    final maxIndex = pages.isEmpty ? 0 : pages.length - 1;
    final start = pages.isEmpty ? 0 : widget.startPage.clamp(0, maxIndex);

    _pageController = PageController(
      initialPage: start,
      keepPage: true,
    );

    settingsController = context.read<SettingsController>();
    _keyboardFocusNode = FocusNode();

    if (settingsController.defaultZoom) {
      _zoomedIn = true;
    }

    _currentPage = start;
    _setActiveScrollController(_currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
      _precacheAround(_currentPage);
      if (_pageController.hasClients) _pageController.jumpToPage(start);
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _pageTurnDebounce?.cancel();

    _holdDelayTimer?.cancel();
    _rapidPageTurnTimer?.cancel();

    _cursorTimer?.cancel();

    _pageController.dispose();
    _keyboardFocusNode.dispose();

    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    _scrollControllers.clear();

    super.dispose();
  }

  void _resetScroll() {
    final c = _activeScrollController;
    if (c == null) return;
    if (!c.hasClients) return;
    c.jumpTo(0);
  }

  void _precacheAround(int index) {
    final pages = widget.book.getPageFiles();
    if (pages.isEmpty) return;

    final minIndex = (index - 2).clamp(0, pages.length - 1);
    final maxIndex = (index + 2).clamp(0, pages.length - 1);

    for (var i = minIndex; i <= maxIndex; i++) {
      final provider = FileImage(pages[i]);
      precacheImage(provider, context);
    }
  }

  void _goToPage(int index) {
    final target = index.clamp(0, widget.book.getPageCount() - 1);
    if (target == _currentPage) return;

    _pageController.jumpToPage(target);

    setState(() {
      _currentPage = target;
    });

    _setActiveScrollController(target);
    _resetScroll();
    _precacheAround(target);
  }

  void _showJumpToPageDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Jump to page'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) {
              _handlePageJump(controller.text);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _handlePageJump(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handlePageJump(String value) {
    if (value.isEmpty) return;

    final page = int.tryParse(value);
    if (page == null) return;

    final target = page - 1;
    if (target < 0 || target >= widget.book.getPageCount()) return;

    _pageController.jumpToPage(target);
  }

  void _startScrollTimer(void Function() action) {
    _scrollTimer?.cancel();
    _scrollTimer =
        Timer.periodic(const Duration(milliseconds: 50), (_) => action());
  }

  void _stopScrollTimer() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void _stopRapidFlipTimers() {
    _holdDelayTimer?.cancel();
    _holdDelayTimer = null;

    _rapidPageTurnTimer?.cancel();
    _rapidPageTurnTimer = null;
  }

  void _startRapidFlipAfterDelay({required int direction}) {
    _stopRapidFlipTimers();

    _holdDelayTimer = Timer(_rapidHoldDelay, () {
      final stillHeld = direction < 0 ? _leftHeld : _rightHeld;
      if (!stillHeld) return;

      _rapidPageTurnTimer = Timer.periodic(_rapidFlipInterval, (_) {
        final still = direction < 0 ? _leftHeld : _rightHeld;
        if (!still) {
          _stopRapidFlipTimers();
          return;
        }
        _goToPage(_currentPage + direction);
      });
    });
  }

  void _scrollByViewportFraction(double fraction) {
    final c = _activeScrollController;
    if (c == null) return;
    if (!c.hasClients) return;

    final viewport = c.position.viewportDimension;
    final increment = viewport * fraction;

    final target =
        (c.offset + increment).clamp(0.0, c.position.maxScrollExtent);
    c.jumpTo(target);
  }

  void _handleKey(KeyEvent event) {
    if (_dialogOpen) return; // Ignore key events when dialog is open

    final key = event.logicalKey;

    _resetCursorTimer();

    final isUp =
        key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp;
    final isDown =
        key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown;

    if (isUp) {
      _upHeld = event is KeyDownEvent || event is KeyRepeatEvent;
      if (_upHeld && _zoomedIn) {
        if (_scrollTimer == null) {
          _startScrollTimer(() => _scrollByViewportFraction(-0.10));
        }
      } else {
        if (!_downHeld) _stopScrollTimer();
      }
    }

    if (isDown) {
      _downHeld = event is KeyDownEvent || event is KeyRepeatEvent;
      if (_downHeld && _zoomedIn) {
        if (_scrollTimer == null) {
          _startScrollTimer(() => _scrollByViewportFraction(0.10));
        }
      } else {
        if (!_upHeld) _stopScrollTimer();
      }
    }

    final isLeft =
        key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft;
    final isRight =
        key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.arrowRight;

    if (event is KeyDownEvent) {
      if (key == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
        return;
      }

      if (key == LogicalKeyboardKey.space) {
        setState(() {
          _zoomedIn = !_zoomedIn;
        });
        _resetScroll();
        return;
      }

      if (key == LogicalKeyboardKey.home) {
        _goToPage(0);
        return;
      }

      if (key == LogicalKeyboardKey.end) {
        _goToPage(widget.book.getPageCount() - 1);
        return;
      }

      if (isLeft && !_leftHeld) {
        _leftHeld = true;
        _pageTurnDebounce?.cancel();
        _pageTurnDebounce = Timer(const Duration(milliseconds: 60), () {
          _goToPage(_currentPage - 1);
        });
        _startRapidFlipAfterDelay(direction: -1);
        return;
      }
    }

    if (isRight && !_rightHeld) {
      _rightHeld = true;
      _pageTurnDebounce?.cancel();
      _pageTurnDebounce = Timer(const Duration(milliseconds: 60), () {
        _goToPage(_currentPage + 1);
      });
      _startRapidFlipAfterDelay(direction: 1);
      return;
    }

    if (event is KeyUpEvent) {
      if (isLeft) {
        _leftHeld = false;
        if (!_rightHeld) _stopRapidFlipTimers();
      }

      if (isRight) {
        _rightHeld = false;
        if (!_leftHeld) _stopRapidFlipTimers();
      }
    }
  }

  void _resetCursorTimer() {
    _cursorTimer?.cancel();
    setState(() {
      _cursorVisible = true;
    });
    _cursorTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _cursorVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.book.getPageFiles();
    final totalPages = pages.length;

    return MouseRegion(
      onHover: (_) => _resetCursorTimer(),
      cursor:
          _cursorVisible ? SystemMouseCursors.basic : SystemMouseCursors.none,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: _handleKey,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                },
              ),
            ],
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
            allowImplicitScrolling: true,
            physics: _zoomedIn ? const NeverScrollableScrollPhysics() : null,
            itemCount: totalPages,
            onPageChanged: (i) {
              setState(() {
                _currentPage = i;
              });
              _setActiveScrollController(i);
              _resetScroll();
              _precacheAround(i);
            },
            itemBuilder: (context, index) {
              final file = pages[index];

              if (_zoomedIn) {
                final controller = _controllerForPage(index);
                final screenW = MediaQuery.of(context).size.width;

                return SingleChildScrollView(
                  controller: controller,
                  physics: const ClampingScrollPhysics(),
                  child: Center(
                    child: Image.file(
                      file,
                      width: screenW * 0.6,
                      fit: BoxFit.fitWidth,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Text('Image not found')),
                    ),
                  ),
                );
              }

              return AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Text('Image not found')),
                ),
              );
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
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => _goToPage(_currentPage - 1),
                ),
                IconButton(
                  icon: Icon(
                    _zoomedIn ? Icons.zoom_out : Icons.zoom_in,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _zoomedIn = !_zoomedIn;
                    });
                    _resetScroll();
                    _stopRapidFlipTimers();
                    _leftHeld = false;
                    _rightHeld = false;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => _goToPage(_currentPage + 1),
                ),
                IconButton(
                  icon: const Icon(Icons.last_page, color: Colors.white),
                  onPressed: () => _goToPage(totalPages - 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
