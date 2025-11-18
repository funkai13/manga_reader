import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            Colors.black.withValues(alpha: 0.5),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.5),
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
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22.sp,
                ),
                onPressed: onBack,
              ),
              actions: [
                IconButton(
                  onPressed: onToggleBookmark,
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  onPressed: onOpenPageGrid,
                ),
                IconButton(
                  icon: Icon(
                    mangaMode ? Icons.book : Icons.menu_book,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  onPressed: onToggleMangaMode,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: mangaMode
                        ? [
                            Text(
                              totalPagesText,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white70,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currentPageText,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                        : [
                            Text(
                              currentPageText,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              totalPagesText,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white70,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                  ),
                  SizedBox(height: 8.h),
                  ComicProgressBar(
                    currentPageIndex: currentPageIndex,
                    totalPages: totalPages,
                    mangaMode: mangaMode,
                    onPageSelected: onPageSelected,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
