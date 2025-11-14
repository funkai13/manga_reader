import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/comics_carousel.dart';

import '../widgets/emtpy_comics_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncComics = ref.watch(comicControllerProvider);

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
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(comicControllerProvider.future);
            },
            child: CustomScrollView(
              slivers: [
                /// HEADER
                SliverAppBar(
                  floating: true,
                  snap: true,
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: () async => await ref
                          .read(comicControllerProvider.notifier)
                          .addComic(context),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                /// TÍTULO "Bienvenido"
                SliverToBoxAdapter(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),

                /// SEARCH BAR
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchBar(
                      leading: const Icon(Icons.search),
                      hintText: 'Buscar',
                      elevation: const WidgetStatePropertyAll(0),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),
                  ),
                ),

                /// CAROUSEL DE COMICS
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ComicsCarousel(
                      title: 'Últimos Agregados',
                      comics: comics,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
