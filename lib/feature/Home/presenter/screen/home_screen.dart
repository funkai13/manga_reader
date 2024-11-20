import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/core/widgets/custom_bottomBar.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/comics_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Libreria",
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
              onPressed: () async => await ref
                  .read(comicControllerProvider.notifier)
                  .addComic(context),
              icon: Icon(Icons.add))
        ],
      ),
      drawer: Drawer(),
      body: ComicsGrid(),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
