// book_grid.dart (drop-in style-matched badge)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

// import 'package:your_app/models/book.dart';

class BookGrid extends StatelessWidget {
  const BookGrid({
    super.key,
    required this.books,
    this.crossAxisCount = 5,
    this.spacing = 10,
    this.childAspectRatio = 0.70,
    this.onBookTap,
  });

  final List<dynamic> books; // replace with List<Book>
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final void Function(dynamic book)? onBookTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _BookTile(
          book: book,
          onTap: () => onBookTap?.call(book),
        );
      },
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({
    required this.book,
    this.onTap,
  });

  final dynamic book; // replace with your Book type
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badgePosition =
        Provider.of<SettingsController>(context).badgePosition;
    final badgeFontSize =
        Provider.of<SettingsController>(context).badgeFontSize;

    // If badge is on bottom show top
    bool titlePositionBottom = false;

    if (badgePosition == 'topLeft' ||
        badgePosition == 'topRight' ||
        badgePosition == 'off') {
      // If badge is on top, or off, show bottom
      titlePositionBottom = true;
    }

    // Thumbnail logic
    final File? coverFile = _resolveCoverFile(book);

    // Example badge label: total pages in the book
    final int pageCount = book.getPageFiles().length;
    final String badgeLabel = '$pageCount';

    const double kBaseFont = 14.0; // base font size for badge
    const double kBaseGap = 8.0; // gap used when fontSize = 14

    final double scale = badgeFontSize / kBaseFont;
    final double edgeGap = kBaseGap * scale; // scales 1:1 with the badge

    Positioned(
      top: edgeGap,
      right: edgeGap,
      child: Transform.scale(
        alignment:
            Alignment.topRight, // anchor at the corner you’re spacing from
        scale: scale,
        child: _PillBadge(label: badgeLabel),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.black.withValues(alpha: 0.1),
        splashColor: Colors.black.withValues(alpha: 0.12),
        highlightColor: Colors.black.withValues(alpha: 0.06),
        child: Ink(
          // The main container for the book tile
          decoration: BoxDecoration(
            image: coverFile != null
                ? DecorationImage(
                    image: FileImage(coverFile),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: LinearGradient(
              begin: titlePositionBottom
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              end: titlePositionBottom
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.99),
                Colors.transparent,
              ],
              stops: const [0.0, 0.1],
            ),
          ),
          child: Stack(
            children: [
              // fade for title
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: titlePositionBottom
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      end: titlePositionBottom
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      colors: [
                        // adjust alpha to taste
                        Colors.black.withValues(alpha: 0.99),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.1],
                    ),
                  ),
                ),
              ),

              // Title
              Positioned(
                left: 0,
                right: 0,
                bottom: titlePositionBottom ? 0 : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Text(
                    (book.title ?? 'Untitled'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      shadows: [
                        Shadow(
                            blurRadius: 2,
                            color: Colors.black54,
                            offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ),

              // Badge for favorite should be opposite of page count badge
              if (book.favorite == true)
                switch (badgePosition) {
                  'topLeft' => Positioned(
                      top: edgeGap,
                      right: edgeGap,
                      child: Transform.scale(
                        scale: badgeFontSize / 14.0,
                        child: _FavoriteBadge(),
                      ),
                    ),
                  'topRight' => Positioned(
                      top: edgeGap,
                      left: edgeGap,
                      child: Transform.scale(
                        scale: badgeFontSize / 14.0,
                        child: _FavoriteBadge(),
                      ),
                    ),
                  'bottomLeft' => Positioned(
                      right: edgeGap,
                      bottom: edgeGap,
                      child: Transform.scale(
                        scale: badgeFontSize / 14.0,
                        child: _FavoriteBadge(),
                      ),
                    ),
                  'bottomRight' => Positioned(
                      left: edgeGap,
                      bottom: edgeGap,
                      child: Transform.scale(
                        scale: badgeFontSize / 14.0,
                        child: _FavoriteBadge(),
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                },

              // Badge for page count
              switch (badgePosition) {
                'topLeft' => Positioned(
                    top: edgeGap,
                    left: edgeGap,
                    child: Transform.scale(
                      scale: badgeFontSize / 14.0,
                      child: _PillBadge(label: badgeLabel),
                    ),
                  ),
                'topRight' => Positioned(
                    top: edgeGap,
                    right: edgeGap,
                    child: Transform.scale(
                      scale: badgeFontSize / 14.0,
                      child: _PillBadge(label: badgeLabel),
                    ),
                  ),
                'bottomLeft' => Positioned(
                    left: edgeGap,
                    bottom: edgeGap,
                    child: Transform.scale(
                      scale: badgeFontSize / 14.0,
                      child: _PillBadge(label: badgeLabel),
                    ),
                  ),
                'bottomRight' => Positioned(
                    right: edgeGap,
                    bottom: edgeGap,
                    child: Transform.scale(
                      scale: badgeFontSize / 14.0,
                      child: _PillBadge(label: badgeLabel),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
    );
  }

  File? _resolveCoverFile(dynamic book) {
    final pages = book.getPageFiles();
    if (pages.isNotEmpty) return pages.first;
    return null;
  }
}

// Shared badge widget to keep style identical across grids.
class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 2),
            color: Colors.black26,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 2),
            color: Colors.black26,
          ),
        ],
      ),
      child: Icon(
        Icons.favorite,
        color: Colors.red,
      ),
    );
  }
}
