import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicViewerController extends AsyncNotifier<List<File>> {
  @override
  Future<List<File>> build() async => [];

  Future<void> loadComic(String imagesPath) async {
    state = const AsyncLoading();

    try {
      final dir = Directory(imagesPath);
      print(imagesPath);

      final images = dir
          .listSync()
          .whereType<File>()
          .where((file) =>
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg') ||
              file.path.toLowerCase().endsWith('.png'))
          .toList();

      state = AsyncData(images);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final comicViewerControllerProvider =
    AsyncNotifierProvider<ComicViewerController, List<File>>(
  ComicViewerController.new,
);
