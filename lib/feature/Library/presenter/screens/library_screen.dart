import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Library/presenter/widgets/category_grid_widget.dart';
import 'package:manga_reader/feature/Library/presenter/widgets/comic_grid_widget.dart';

import 'package:manga_reader/core/widgets/responsive_layout.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: LibraryScreenMobile(),
      tabletBody: LibraryScreenTablet(),
    );
  }
}

class LibraryScreenMobile extends ConsumerWidget {
  const LibraryScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncComics = ref.watch(comicControllerProvider);
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Autores'),
              Tab(text: 'Géneros'),
              Tab(text: 'Colecciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            asyncComics.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (comics) => ComicGridWidget(comics: comics, crossAxisCount: 2),
            ),
            const CategoryGridWidget(type: 'author', crossAxisCount: 2),
            const CategoryGridWidget(type: 'genre', crossAxisCount: 2),
            const CategoryGridWidget(type: 'collection', crossAxisCount: 2),
          ],
        ),
      ),
    );
  }
}

class LibraryScreenTablet extends ConsumerWidget {
  const LibraryScreenTablet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncComics = ref.watch(comicControllerProvider);
    // On tablet, we might want a smaller scale for text/icons relative to the screen size,
    // or we can keep it 1.0 if we want them large. 
    // The previous code used 0.8 for tablet. Let's keep it consistent or adjust.
    // Since we are increasing columns, 1.0 might be fine, or 0.8 if we want more density.
    // Let's stick to the user's preference for "control". 
    // Using 0.8 scale as per previous logic for consistency.
    const scale = 0.8;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca'),
          bottom: const TabBar(
            isScrollable: false, // On tablet, tabs might fit without scrolling
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Autores'),
              Tab(text: 'Géneros'),
              Tab(text: 'Colecciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            asyncComics.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (comics) => ComicGridWidget(
                comics: comics, 
                scale: scale,
                crossAxisCount: 4, // 4 columns for tablet
              ),
            ),
            const CategoryGridWidget(type: 'author', crossAxisCount: 4),
            const CategoryGridWidget(type: 'genre', crossAxisCount: 4),
            const CategoryGridWidget(type: 'collection', crossAxisCount: 4),
          ],
        ),
      ),
    );
  }
}
