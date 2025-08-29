// book_grid.dart (drop-in style-matched badge)

import 'dart:io';
import 'dart:ui'; // for FontFeature
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
    final cs = Theme.of(context).colorScheme;

    // Thumbnail logic (adapt to your model: cover path, bytes, etc.)
    final File? coverFile = _resolveCoverFile(book);

    // Example badge label: total pages in the book
    final int pageCount = book.getPageFiles().length;
    final String badgeLabel = '$pageCount';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Cover / fallback
            Positioned.fill(
              child: coverFile != null
                  ? Image.file(
                      coverFile,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverFallback(cs),
                    )
                  : _coverFallback(cs),
            ),

            switch (badgePosition) {
              'topLeft' => Positioned(
                  left: badgeFontSize / 14.0 * 12,
                  top: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              'topRight' => Positioned(
                  right: badgeFontSize / 14.0 * 12,
                  top: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              'bottomLeft' => Positioned(
                  left: badgeFontSize / 14.0 * 12,
                  bottom: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              'bottomRight' => Positioned(
                  right: badgeFontSize / 14.0 * 12,
                  bottom: badgeFontSize / 14.0 * 12,
                  child: Transform.scale(
                    scale: badgeFontSize / 14.0,
                    child: _PillBadge(label: badgeLabel),
                  ),
                ),
              _ => const SizedBox.shrink(),
            },

            // (Optional) Add more badges; just stack them in a Row:
            // Positioned(
            //   right: 6,
            //   bottom: 6,
            //   child: Row(
            //     children: [
            //       _PillBadge(label: badgeLabel),
            //       const SizedBox(width: 6),
            //       _PillBadge(label: '★'), // favorite example
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _coverFallback(ColorScheme cs) {
    return Container(
      color: cs.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_outlined),
    );
  }

  File? _resolveCoverFile(dynamic book) {
    // If your Book has a stored cover path, return File(book.coverPath)
    // Or derive from folder (e.g., first image) if you prefer:
    final pages = book.getPageFiles();
    if (pages.isNotEmpty) return pages.first;
    return null;
  }
}

/// Shared badge widget to keep style identical across grids.
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
