// lib/feature/Home/presenter/widgets/comic_controls_overlay.dart

import 'package:flutter/material.dart';

import 'comic_progress_bar.dart';

class ComicControlsOverlay extends StatelessWidget {
  final int currentPageIndex;
  final int totalPages;
  final bool mangaMode;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;
  final VoidCallback onOpenPageGrid;
  final VoidCallback onToggleMangaMode;
  final ValueChanged<int> onPageSelected;

  const ComicControlsOverlay({
    super.key,
    required this.currentPageIndex,
    required this.totalPages,
    required this.mangaMode,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleBookmark,
    required this.onOpenPageGrid,
    required this.onToggleMangaMode,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentPageText = 'Página ${currentPageIndex + 1}';
    final totalPagesText = '$totalPages Páginas';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack,
              ),
              actions: [
                IconButton(
                  onPressed: onToggleBookmark,
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.list, color: Colors.white),
                  onPressed: onOpenPageGrid,
                ),
                IconButton(
                  icon: Icon(
                    mangaMode ? Icons.book : Icons.menu_book,
                    color: Colors.white,
                  ),
                  onPressed: onToggleMangaMode,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: mangaMode
                        ? [
                            Text(
                              totalPagesText,
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currentPageText,
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                        : [
                            Text(
                              currentPageText,
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              totalPagesText,
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                  ),
                  const SizedBox(height: 8),
                  ComicProgressBar(
                    currentPageIndex: currentPageIndex,
                    totalPages: totalPages,
                    mangaMode: mangaMode,
                    onPageSelected: onPageSelected,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
