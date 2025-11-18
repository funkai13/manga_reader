import 'dart:math';

import 'package:flutter/material.dart';

class ComicProgressBar extends StatelessWidget {
  final int currentPageIndex;
  final int totalPages;
  final bool mangaMode;
  final ValueChanged<int> onPageSelected;

  const ComicProgressBar({
    super.key,
    required this.currentPageIndex,
    required this.totalPages,
    required this.onPageSelected,
    required this.mangaMode,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 0) return const SizedBox.shrink();
    final progress = (currentPageIndex + 1) / totalPages;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(mangaMode ? pi : 0),
      child: LayoutBuilder(builder: (context, constraints) {
        void handlePosition(double dx) {
          final width = constraints.maxWidth;
          if (width <= 0) return;
          final clampedDx = dx.clamp(0, width);
          final page =
              (clampedDx / width * totalPages).floor().clamp(0, totalPages - 1);
          onPageSelected(page);
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) => handlePosition(details.localPosition.dx),
          onHorizontalDragUpdate: (details) =>
              handlePosition(details.localPosition.dx),
          child: SizedBox(
            height: 24,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.8)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}
