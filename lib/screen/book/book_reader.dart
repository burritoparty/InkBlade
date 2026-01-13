import 'dart:async';
import 'dart:math' as math;

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
  late final PageController _pageController;
  late final FocusNode _keyboardFocusNode;
  late final SettingsController settingsController;

  int _currentPage = 0;

  bool _zoomedIn = false;

  // Keep a separate ScrollController per page to avoid attaching one controller
  // to multiple scroll views.
  final Map<int, ScrollController> _pageScrollControllers = {};
  ScrollController? _activeScrollController;

  // Hotkey state for held keys
  bool _upHeld = false;
  bool _downHeld = false;
  bool _leftHeld = false;
  bool _rightHeld = false;

  // Timers
  Timer? _scrollTimer;
  Timer? _cursorTimer;
  Timer? _holdDelayTimer;
  Timer? _rapidPageTurnTimer;
  Timer? _pageTurnDebounce;

  bool _cursorVisible = true;

  // Rapid flip behavior
  final Duration _rapidHoldDelay = const Duration(milliseconds: 400);
  final Duration _rapidFlipInterval = const Duration(milliseconds: 100);

  bool _dialogOpen = false;

  // Temporarily disable hotkeys while a page-turn animation is running.
  bool _pageTurnInProgress = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleCursorHide();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _cursorTimer?.cancel();
    _holdDelayTimer?.cancel();
    _rapidPageTurnTimer?.cancel();
    _pageTurnDebounce?.cancel();

    _keyboardFocusNode.dispose();
    _pageController.dispose();

    for (final c in _pageScrollControllers.values) {
      c.dispose();
    }
    _pageScrollControllers.clear();

    super.dispose();
  }

  ScrollController _controllerForPage(int index) {
    return _pageScrollControllers.putIfAbsent(index, () => ScrollController());
  }

  void _setActiveScrollController(int pageIndex) {
    _activeScrollController = _controllerForPage(pageIndex);
  }

  void _resetScroll() {
    final c = _activeScrollController;
    if (c == null) return;
    if (!c.hasClients) return;

    c.jumpTo(0);
  }

  void _precacheAround(int pageIndex) {
    // keep this lightweight, only cache a small window
    final pages = widget.book.getPageFiles();
    if (pages.isEmpty) return;

    const buffer = 2;
    final start = (pageIndex - buffer).clamp(0, pages.length - 1);
    final end = (pageIndex + buffer).clamp(0, pages.length - 1);

    for (int i = start; i <= end; i++) {
      precacheImage(FileImage(pages[i]), context);
    }
  }

  Future<void> _goToPage(int index, {bool animate = true}) async {
    final target = index.clamp(0, widget.book.getPageCount() - 1);
    if (target == _currentPage) return;
    if (_pageTurnInProgress) return;

    if (animate && _pageController.hasClients) {
      final settings = context.read<SettingsController>();
      final speed = settings.pageTurnSpeed;

      final int ms = speed == 0 ? 1 : speed * 100;

      _pageTurnInProgress = true;
      try {
        await _pageController.animateToPage(
          target,
          duration: Duration(milliseconds: ms),
          curve: Curves.easeInOut,
        );
      } finally {
        _pageTurnInProgress = false;
      }
    } else {
      _pageController.jumpToPage(target);
    }

    setState(() {
      _currentPage = target;
    });

    _setActiveScrollController(target);
    _resetScroll();
    _precacheAround(target);
  }

  void _handlePageJump(String text) {
    final totalPages = widget.book.getPageCount();
    final value = int.tryParse(text);
    if (value == null) return;

    final target = (value - 1).clamp(0, totalPages - 1);
    _goToPage(target);
  }

  void _showJumpToPageDialog() {
    final controller = TextEditingController(text: '${_currentPage + 1}');
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);

    setState(() {
      _dialogOpen = true;
    });

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
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _dialogOpen = false;
      });
    });
  }

  void _scrollByViewportFraction(double fraction) {
    final c = _activeScrollController;
    if (c == null) return;
    if (!c.hasClients) return;

    final viewport = c.position.viewportDimension;
    final delta = viewport * fraction;
    final target = (c.offset + delta).clamp(
      c.position.minScrollExtent,
      c.position.maxScrollExtent,
    );

    c.animateTo(
      target,
      duration: const Duration(milliseconds: 55),
      curve: Curves.linear,
    );
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
        _goToPage(_currentPage + direction, animate: false);
      });
    });
  }

  void _scheduleCursorHide() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _cursorVisible = false;
      });
    });
  }

  void _handleKey(KeyEvent event) {
    // ESC = back
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.maybePop(context);
      return;
    }

    if (_dialogOpen) return; // Ignore key events when dialog is open

    final key = event.logicalKey;

    // TODO: find a better way to handle this?
    // While a page-turn animation is in progress, ignore keys that would
    // initiate another page turn so fast repeated presses don't get lost.
    final pageTurnKeys = {
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.arrowRight,
      // prevent vertical scroll keys while animation is running
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.pageUp,
      LogicalKeyboardKey.pageDown,
      LogicalKeyboardKey.home,
      LogicalKeyboardKey.end,
    };
    if (_pageTurnInProgress &&
        (event is KeyDownEvent || event is KeyRepeatEvent) &&
        pageTurnKeys.contains(key)) {
      return;
    }

    // was causing bug with cursor visibility
    // _resetCursorTimer();

    final isUp =
        key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp;
    final isDown =
        key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown;

    if (isUp) {
      _upHeld = event is KeyDownEvent || event is KeyRepeatEvent;
      if (_upHeld && _zoomedIn) {
        _startScrollTimer(() => _scrollByViewportFraction(-0.12));
      }
      if (event is KeyUpEvent) _stopScrollTimer();
      return;
    }

    if (isDown) {
      _downHeld = event is KeyDownEvent || event is KeyRepeatEvent;
      if (_downHeld && _zoomedIn) {
        _startScrollTimer(() => _scrollByViewportFraction(0.12));
      }
      if (event is KeyUpEvent) _stopScrollTimer();
      return;
    }

    final isLeft =
        key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft;
    final isRight =
        key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.arrowRight;

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

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
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

      if (isRight && !_rightHeld) {
        _rightHeld = true;
        _pageTurnDebounce?.cancel();
        _pageTurnDebounce = Timer(const Duration(milliseconds: 60), () {
          _goToPage(_currentPage + 1);
        });
        _startRapidFlipAfterDelay(direction: 1);
        return;
      }

      if (key == LogicalKeyboardKey.pageUp) {
        _goToPage(_currentPage - 1);
        return;
      }

      if (key == LogicalKeyboardKey.pageDown) {
        _goToPage(_currentPage + 1);
        return;
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

  Widget _buildPageTurnAnimation({required int index, required Widget child}) {
    // Lightweight 3D turn effect driven by the PageController.
    // Does not change AppBar styling, hotkeys, zoom, scroll behavior, or buttons.
    return AnimatedBuilder(
      animation: _pageController,
      child: child,
      builder: (context, page) {
        double current = _currentPage.toDouble();

        if (_pageController.hasClients) {
          final p = _pageController.page;
          if (p != null) current = p;
        }

        final delta = index - current;
        final t = delta.clamp(-1.0, 1.0);

        final rotationY = t * (math.pi / 18); // ~10°
        final scale = (1.0 - delta.abs() * 0.035).clamp(0.965, 1.0);
        final opacity = (1.0 - delta.abs() * 0.18).clamp(0.0, 1.0);

        final alignment =
            delta >= 0 ? Alignment.centerLeft : Alignment.centerRight;

        return Opacity(
          opacity: opacity,
          child: Transform(
            alignment: alignment,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(rotationY)
              ..scale(scale, 1.0, 1.0),
            child: page,
          ),
        );
      },
    );
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

              Widget pageChild;

              if (_zoomedIn) {
                final controller = _controllerForPage(index);
                final screenW = MediaQuery.of(context).size.width;

                pageChild = SingleChildScrollView(
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
              } else {
                pageChild = AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('Image not found')),
                  ),
                );
              }

              return _buildPageTurnAnimation(index: index, child: pageChild);
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
