import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/provider/comic_file_provider.dart';

class ComicViewerController extends AutoDisposeAsyncNotifier<List<File>> {
  @override
  Future<List<File>> build() async => [];

  Future<void> loadComic(String filePath) async {
    final comicViewerRepository = ref.read(extractComicImagesUseCaseProvider);
    state = const AsyncLoading();
    try {
      final images = await comicViewerRepository(filePath);
      state = AsyncData(images);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final comicViewerControllerProvider =
    AutoDisposeAsyncNotifierProvider<ComicViewerController, List<File>>(
  ComicViewerController.new,
);
