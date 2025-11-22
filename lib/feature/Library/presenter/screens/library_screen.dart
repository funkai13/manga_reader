import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Library/presenter/widgets/category_list_widget.dart';
import 'package:manga_reader/feature/Library/presenter/widgets/comic_grid_widget.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncComics = ref.watch(comicControllerProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final scale = isTablet ? 0.8 : 1.0;

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
              data: (comics) => ComicGridWidget(comics: comics, scale: scale),
            ),
            const CategoryListWidget(type: 'author'),
            const CategoryListWidget(type: 'genre'),
            const CategoryListWidget(type: 'collection'),
          ],
        ),
      ),
    );
  }
}
