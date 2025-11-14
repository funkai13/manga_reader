import 'package:flutter/material.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';
import 'package:manga_reader/feature/Home/presenter/screen/comic_viewer_screen.dart';

import 'comic_card.dart';

class ComicsCarousel extends StatelessWidget {
  final String title;
  final List<ComicEntity> comics;

  const ComicsCarousel({required this.title, required this.comics, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textAlign: TextAlign.start,
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 250,
          width: 500,
          child: CarouselView.weighted(
              onTap: (
                int index,
              ) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ComicViewerScreen(comic: comics.elementAt(index))));
              },
              scrollDirection: Axis.horizontal,
              flexWeights: [1, 1],
              shrinkExtent: 200,
              itemSnapping: true,
              shape: Border(),
              children: List<Widget>.generate(comics.length,
                  (int index) => ComicCard(comic: comics[index]))),
        ),
      ],
    );
  }
}
