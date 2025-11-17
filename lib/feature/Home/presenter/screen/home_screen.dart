import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Home/presenter/helpers/comic_selectors.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/comics_carousel.dart';

import '../../../../core/theme/colors.dart';
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
    return asyncComics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Center(
        child: Text('Error cargando comics'),
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
        return Scaffold(
          backgroundColor: isDark
              ? AppColorsDark.backgroundColor
              : AppColorsLight.backgroundColor,
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(comicControllerProvider.future);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    'Biblioteca',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColorsDark.textColor
                          : AppColorsLight.textColor,
                    ),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: 16.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColorsDark.cardColor
                            : AppColorsLight.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () async => await ref
                            .read(comicControllerProvider.notifier)
                            .addComic(context),
                        icon: Icon(
                          Icons.add,
                          color: isDark
                              ? AppColorsDark.accentColor
                              : AppColorsLight.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 24.h, top: 24.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColorsDark.cardColor
                            : AppColorsLight.cardColor,
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
                        builder: (BuildContext context,
                            SearchController controller) {
                          return SearchBar(
                            controller: controller,
                            onTap: () => controller.openView(),
                            onChanged: (_) => controller.openView(),
                            leading: Icon(
                              Icons.search,
                              color: isDark
                                  ? AppColorsDark.textColor.withOpacity(0.6)
                                  : AppColorsLight.textColor.withOpacity(0.6),
                            ),
                            hintText: 'Buscar en tu biblioteca',
                            hintStyle: WidgetStatePropertyAll(
                              TextStyle(
                                color: isDark
                                    ? AppColorsDark.textColor.withOpacity(0.4)
                                    : AppColorsLight.textColor.withOpacity(0.4),
                                fontSize: 15.sp,
                              ),
                            ),
                            elevation: const WidgetStatePropertyAll(0),
                            backgroundColor: WidgetStatePropertyAll(
                              isDark
                                  ? AppColorsDark.cardColor
                                  : AppColorsLight.cardColor,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                side: BorderSide.none,
                              ),
                            ),
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                            ),
                          );
                        },
                        suggestionsBuilder: (BuildContext context,
                            SearchController controller) {
                          final String input =
                              controller.value.text.toLowerCase();
                          final results = comics
                              .where((comic) =>
                                  comic.title.toLowerCase().contains(input))
                              .take(6);
                          return results.map((comic) => ListTile(
                                title: Text(comic.title),
                                onTap: () async {
                                  controller.closeView(comic.title);
                                  FocusScope.of(context).unfocus();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ComicViewerScreen(comic: comic),
                                    ),
                                  );
                                  controller.clear();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                              ));
                        },
                      ),
                    ),
                  ),
                ),
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
          ),
        );
      },
    );
  }
}
