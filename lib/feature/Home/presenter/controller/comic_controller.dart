import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/comic.dart';
import '../../domain/provider/comic_provider.dart';

class ComicController extends AutoDisposeAsyncNotifier<List<ComicEntity>> {
  @override
  FutureOr<List<ComicEntity>> build() async => [];

  Future<void> addComic(BuildContext context) async {
    final comicRepository = ref.read(comicRepositoryProvider);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      final fileName = result.files.single.name;
      final extension = fileName.split('.').last.toLowerCase();

      if (extension == 'cbr' || extension == 'cbz') {
        if (filePath != null) {
          final newComic = ComicEntity(
            filePath: filePath,
            title: fileName,
            currentReadPage: 0,
            totalPages: 0,
            picture: '',
            lastOpened: DateTime.now().toIso8601String(),
            currentReading: 0,
          );
          await comicRepository.addComic(newComic);
          print('Inserting comic: $newComic, ');

          state = AsyncData([...state.value ?? [], newComic]);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Seleccione un archivo con extensión .cbr o .cbz")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se seleccionó ningún archivo.")),
      );
    }
  }

  Future<List<ComicEntity>> getAllComics() async {
    final comicRepository = ref.read(comicRepositoryProvider);
    try {
      final comics = await comicRepository.getAllComics();
      state = AsyncData(comics);
      return comics;
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
      print(error);
      rethrow;
    }
  }

  Future<String> createBookmark(int id, int bookMark, ComicEntity comic) async {
    final comicRepository = ref.read(comicRepositoryProvider);
    try {
      comicRepository.addBookMark(id, bookMark);
      state = state.whenData((comics) {
        return comics.map((c) {
          if (c.id == id) {
            return c.copyWith(currentReadPage: bookMark);
          }
          return c;
        }).toList();
      });

      return 'Update success';
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
      print(error);
      rethrow;
    }
  }
}

final comicControllerProvider =
    AutoDisposeAsyncNotifierProvider<ComicController, List<ComicEntity>>(
  ComicController.new,
);
