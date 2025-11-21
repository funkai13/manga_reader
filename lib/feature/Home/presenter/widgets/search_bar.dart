import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/core/theme/colors.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

import '../screen/comic_viewer_screen.dart';

SliverToBoxAdapter buildSearchBar(
  BuildContext context,
  List<ComicEntity> comics,
  bool isDark,
  double scale,
) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w * scale),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h * scale, top: 16.h * scale),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10 * scale,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SearchAnchor(
          isFullScreen: false,
          shrinkWrap: true,
          viewPadding: EdgeInsets.zero,
          viewSide: BorderSide.none,
          viewShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r * scale),
          ),
          viewConstraints: BoxConstraints(
            maxHeight: 200.h * scale,
          ),
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              autoFocus: false,
              controller: controller,
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                    horizontal: 16.w * scale, vertical: 8.h * scale),
              ),
              onTap: controller.openView,
              onChanged: (_) => controller.openView(),
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              leading: Icon(
                Icons.search,
                color: isDark
                    ? AppColorsDark.textColor.withValues(alpha: 0.6)
                    : AppColorsLight.textColor.withValues(alpha: 0.6),
                size: 20.sp * scale,
              ),
              hintText: 'Buscar en tu biblioteca',
              hintStyle: WidgetStatePropertyAll(
                TextStyle(
                  color: isDark
                      ? AppColorsDark.textColor.withValues(alpha: 0.4)
                      : AppColorsLight.textColor.withValues(alpha: 0.4),
                  fontSize: 12.sp * scale,
                ),
              ),
              backgroundColor: WidgetStatePropertyAll(
                isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide.none,
                ),
              ),
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            final input = controller.text.toLowerCase().trim();

            if (input.isEmpty) {
              return const Iterable<Widget>.empty();
            }

            final results = comics
                .where(
                  (comic) => comic.title.toLowerCase().contains(input),
                )
                .take(20)
                .toList();

            if (results.isEmpty) {
              return [
                ListTile(
                  leading: const Icon(Icons.search_off),
                  title: const Text('Sin resultados'),
                  subtitle: Text(
                    'No se encontró ningún cómic con "$input"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    controller.closeView('');
                    controller.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ];
            }

            return results.map((comic) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                leading: _buildComicThumbnail(comic, isDark),
                title: Text(
                  comic.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  comic.isCompleted
                      ? 'Completado'
                      : comic.isReading
                          ? 'En progreso'
                          : (comic.currentReadPage == 0 ? 'Sin leer' : 'Leído'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  controller.closeView(comic.title);
                  FocusScope.of(context).unfocus();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComicViewerScreen(comic: comic),
                    ),
                  );

                  controller.text = '';
                  FocusScope.of(context).unfocus();
                },
              );
            });
          },
        ),
      ),
    ),
  );
}

Widget _buildComicThumbnail(ComicEntity comic, bool isDark) {
  final width = 36.w;
  final height = 52.h;

  if (comic.picture.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.file(
        File(comic.picture),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackThumb(isDark, width, height),
      ),
    );
  }

  return _fallbackThumb(isDark, width, height);
}

Widget _fallbackThumb(bool isDark, double width, double height) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
    ),
    child: Icon(
      Icons.book,
      size: 18.sp,
      color: isDark
          ? AppColorsDark.textColor.withOpacity(0.4)
          : AppColorsLight.textColor.withOpacity(0.4),
    ),
  );
}
