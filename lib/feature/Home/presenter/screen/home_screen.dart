import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Home/presenter/helpers/comic_selectors.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/comics_carousel.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entity/comic.dart';
import '../widgets/emtpy_comics_screen.dart';
import 'comic_viewer_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncComics = ref.watch(comicControllerProvider);
    final readingNow = ref.watch(readingNowComicsProvider);
    final lastAdded = ref.watch(lastAddedComicsProvider);
    final unread = ref.watch(unreadComicsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.backgroundColor
          : AppColorsLight.backgroundColor,
      body: asyncComics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error cargando comics',
            style: TextStyle(
              color:
                  isDark ? AppColorsDark.textColor : AppColorsLight.textColor,
            ),
          ),
        ),
        data: (comics) {
          if (comics.isEmpty) {
            return EmptyComicsScreen(
              onAddComic: () async {
                await ref
                    .read(comicControllerProvider.notifier)
                    .addComic(context);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(comicControllerProvider.future);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHomeAppBar(isDark),
                _buildSearchBar(context, comics, isDark),
                if (readingNow.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ComicsCarousel(
                      title: 'Continuar Leyendo',
                      comics: readingNow,
                    ),
                  ),
                if (lastAdded.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ComicsCarousel(
                      title: 'Recientemente Agregados',
                      comics: lastAdded,
                    ),
                  ),
                if (unread.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ComicsCarousel(
                      title: 'Sin Leer',
                      comics: unread,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

SliverAppBar _buildHomeAppBar(bool isDark) {
  return SliverAppBar(
    floating: true,
    snap: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: Text(
      'Biblioteca',
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColorsDark.textColor : AppColorsLight.textColor,
      ),
    ),
    actions: [
      Container(
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Consumer(
          builder: (context, ref, _) {
            return IconButton(
              onPressed: () async => await ref
                  .read(comicControllerProvider.notifier)
                  .addComic(context),
              icon: Icon(
                Icons.add,
                color: isDark
                    ? AppColorsDark.accentColor
                    : AppColorsLight.accentColor,
              ),
            );
          },
        ),
      ),
    ],
  );
}

SliverToBoxAdapter _buildSearchBar(
  BuildContext context,
  List<ComicEntity> comics,
  bool isDark,
) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h, top: 16.h),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              leading: Icon(
                Icons.search,
                color: isDark
                    ? AppColorsDark.textColor.withOpacity(0.6)
                    : AppColorsLight.textColor.withOpacity(0.6),
                size: 20.sp,
              ),
              hintText: 'Buscar en tu biblioteca',
              hintStyle: WidgetStatePropertyAll(
                TextStyle(
                  color: isDark
                      ? AppColorsDark.textColor.withOpacity(0.4)
                      : AppColorsLight.textColor.withOpacity(0.4),
                  fontSize: 14.sp,
                ),
              ),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide.none,
                ),
              ),
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 44,
              ),
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            final String input = controller.value.text.toLowerCase().trim();

            if (input.isEmpty) {
              return const Iterable<Widget>.empty();
            }

            final results = comics
                .where(
                  (comic) => comic.title.toLowerCase().contains(input),
                )
                .take(6)
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
                    FocusScope.of(context).unfocus();
                  },
                ),
              ];
            }

            return results.map((comic) {
              return ListTile(
                leading: Icon(
                  comic.isReading ? Icons.menu_book : Icons.book_outlined,
                ),
                title: RichText(
                  text: _buildHighlightedTextSpan(
                    text: comic.title,
                    query: input,
                    normalStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColorsDark.textColor
                            : AppColorsLight.textColor),
                    highlightStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColorsDark.accentColor
                          : AppColorsLight.accentColor,
                    ),
                  ),
                ),
                subtitle: Text(
                  comic.isReading
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

TextSpan _buildHighlightedTextSpan({
  required String text,
  required String query,
  required TextStyle normalStyle,
  required TextStyle highlightStyle,
}) {
  if (query.isEmpty) {
    return TextSpan(text: text, style: normalStyle);
  }

  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();

  final startIndex = lowerText.indexOf(lowerQuery);
  if (startIndex == -1) {
    return TextSpan(text: text, style: normalStyle);
  }

  final endIndex = startIndex + query.length;

  return TextSpan(
    children: [
      if (startIndex > 0)
        TextSpan(
          text: text.substring(0, startIndex),
          style: normalStyle,
        ),
      TextSpan(
        text: text.substring(startIndex, endIndex),
        style: highlightStyle,
      ),
      if (endIndex < text.length)
        TextSpan(
          text: text.substring(endIndex),
          style: normalStyle,
        ),
    ],
  );
}
