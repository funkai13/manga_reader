import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';

import '../../../../core/widgets/generic_grid.dart';
import 'comic_card.dart';

class ComicsGrid extends ConsumerWidget {
  const ComicsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> fetchComics() async {
      await ref.read(comicControllerProvider.notifier).getAllComics();
    }

    final asyncComics = ref.watch(comicControllerProvider);
    return asyncComics.when(
      data: (comics) => RefreshIndicator(
          onRefresh: () async {
            await fetchComics();
          },
          child: GenericGrid(
            items: comics,
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 250,
            itemBuilder: (comic) {
              return ComicCard(
                comic: comic,
                scale: 1.0,
              );
            },
          )),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
/*class ComicCard extends StatelessWidget {
  final ComicEntity comic;

  const ComicCard({super.key, required this.comic});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComicViewerScreen(comic: comic),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: comic.picture.isNotEmpty
                  ? Image.file(
                      File(comic.picture),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                    ))
        ],
      ),
      */ /* child: Card(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: comic.picture.isNotEmpty
                  ? Image.file(
                      File(comic.picture),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[700],
                        size: 60,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                comic.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),*/ /*
    );
  }
}*/
