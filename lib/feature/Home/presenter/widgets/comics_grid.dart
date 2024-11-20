import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';

import '../../../../core/widgets/generic_grid.dart';
import '../screen/comic_viewer_screen.dart';

class ComicsGrid extends ConsumerStatefulWidget {
  const ComicsGrid({super.key});

  @override
  ConsumerState<ComicsGrid> createState() => _ComicsGridState();
}

class _ComicsGridState extends ConsumerState<ComicsGrid> {
  @override
  void initState() {
    super.initState();
    _fetchComics();
  }

  Future<void> _fetchComics() async {
    var comics =
        await ref.read(comicControllerProvider.notifier).getAllComics();
    print('$comics veamos si hay datos');
  }

  @override
  Widget build(BuildContext context) {
    final asyncComics = ref.watch(comicControllerProvider);
    return asyncComics.when(
      data: (comics) => RefreshIndicator(
          onRefresh: () async {
            await _fetchComics();
          },
          child: GenericGrid(
            items: comics,
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 250,
            itemBuilder: (comic) {
              return ComicCard(comic: comic);
            },
          )),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class ComicCard extends StatelessWidget {
  final ComicEntity comic;

  const ComicCard({super.key, required this.comic});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComicViewerScreen(filePath: comic.filePath),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: comic.picture != null
                  ? Image.network(
                      comic.picture!,
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
