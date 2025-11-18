import 'dart:io';

import 'package:flutter/material.dart';

import 'comic_page.dart';

class ComicPageView extends StatelessWidget {
  final PageController controller;
  final List<File> images;
  final bool mangaMode;
  final bool enablePageScroll;
  final Map<int, double> pageScales;
  final ValueChanged<int> onPageChanged;
  final void Function(int pageIndex, double scale) onPageScaleChanged;

  const ComicPageView({
    super.key,
    required this.controller,
    required this.images,
    required this.mangaMode,
    required this.enablePageScroll,
    required this.pageScales,
    required this.onPageChanged,
    required this.onPageScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return PageView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      reverse: mangaMode,
      physics: enablePageScroll
          ? const PageScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final initialScale = pageScales[index] ?? 1.0;

        return ComicPage(
          image: images[index],
          initialScale: initialScale,
          onScaleChanged: (scale) => onPageScaleChanged(index, scale),
        );
      },
    );
  }
}
