import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

class ComicCard extends StatelessWidget {
  final ComicEntity comic;

  const ComicCard({super.key, required this.comic});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                ),
        )
      ],
    );
  }
}
