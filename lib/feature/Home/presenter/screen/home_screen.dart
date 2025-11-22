import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Home/presenter/helpers/comic_selectors.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/comics_carousel.dart';

import '../../../../core/theme/colors.dart';
import '../widgets/emtpy_comics_screen.dart';
import '../widgets/search_bar.dart';

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
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final scale = isTablet ? 0.8 : 1.0;
    final SearchController _searchController = SearchController();
    final FocusNode _searchFocusNode = FocusNode();
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
                _buildHomeAppBar(isDark, scale),
                buildSearchBar(context, comics, isDark, scale,
                    _searchController, _searchFocusNode),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h * scale),
                ),
                if (readingNow.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ComicsCarousel(
                      scale: scale,
                      title: 'Continuar Leyendo',
                      comics: readingNow,
                    ),
                  ),
                if (lastAdded.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ComicsCarousel(
                      scale: scale,
                      title: 'Recientemente Agregados',
                      comics: lastAdded,
                    ),
                  ),
                if (unread.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ComicsCarousel(
                      scale: scale,
                      title: 'Sin Leer',
                      comics: unread,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h * scale),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

SliverAppBar _buildHomeAppBar(bool isDark, double scale) {
  return SliverAppBar(
    floating: true,
    snap: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: Text(
      'Biblioteca',
      style: TextStyle(
        fontSize: 22.sp * scale,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColorsDark.textColor : AppColorsLight.textColor,
      ),
    ),
    actions: [
      Container(
        margin: EdgeInsets.only(right: 16.w * scale),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8 * scale,
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
                size: 16.sp * scale,
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
