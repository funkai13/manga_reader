// lib/feature/Home/presenter/widgets/comic_page_grid_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';

class ComicPageGridDialog extends StatelessWidget {
  final List<File> images;
  final int currentPageIndex;
  final bool mangaMode;
  final ValueChanged<int> onPageSelected;

  const ComicPageGridDialog({
    super.key,
    required this.images,
    required this.currentPageIndex,
    required this.mangaMode,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = images.length;

    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      contentPadding: const EdgeInsets.all(10),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Página',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final adjustedIndex =
                      mangaMode ? totalPages - index - 1 : index;
                  final isCurrentPage = currentPageIndex == adjustedIndex;

                  return GestureDetector(
                    onTap: () => onPageSelected(adjustedIndex),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          images[adjustedIndex],
                          fit: BoxFit.cover,
                          cacheWidth: 200,
                        ),
                        if (isCurrentPage)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.amber,
                                width: 3,
                              ),
                              color: Colors.white54,
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${adjustedIndex + 1}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Colors.black,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
