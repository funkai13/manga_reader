import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      contentPadding: EdgeInsets.all(10.w),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Página',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 0.6.sh, // 60% de la altura de pantalla
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5.w,
                  mainAxisSpacing: 5.h,
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
                                width: 3.w,
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
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Colors.black,
                                  offset: Offset(2.0.w, 2.0.h),
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
