import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/domain/exceptions/comic_exceptions.dart';

import '../../domain/entity/comic.dart';
import '../../domain/provider/comic_provider.dart';

class ComicController extends AsyncNotifier<List<ComicEntity>> {
  @override
  FutureOr<List<ComicEntity>> build() async {
    final comicRepository = ref.read(comicRepositoryProvider);
    final comics = await comicRepository.getAllComics();
    return comics;
  }

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
          final newComicEntity = ComicEntity(
            filePath: filePath,
            title: fileName,
            currentReadPage: 0,
            totalPages: 0,
            picture: '',
            lastOpened: DateTime.now().toIso8601String(),
            currentReading: 0,
            imagesPath: '',
            isReading: false,
            isFavorite: false,
            rating: null,
            bookMarks: '',
            isCompleted: false,
          );
          try {
            final createdComic = await comicRepository.addComic(newComicEntity);

            final currentList = state.value ?? [];
            final alreadyInState =
                currentList.any((c) => c.id == createdComic.id);

            if (alreadyInState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Este cómic ya está en tu biblioteca.'),
                ),
              );
            } else {
              state = AsyncData([...currentList, createdComic]);
            }
          } on UnsupportedComicException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.message.isNotEmpty
                      ? e.message
                      : 'Este archivo de cómic no está soportado.',
                ),
              ),
            );
          } catch (e) {
            // Error inesperado
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ocurrió un error al agregar el cómic.'),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Seleccione un archivo con extensión .cbr o .cbz"),
          ),
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

  Future<void> markAsReading(int id) async {
    final comicRepository = ref.read(comicRepositoryProvider);
    try {
      await comicRepository.startReadingComic(id);

      state = state.whenData((comics) {
        return comics.map((c) {
          if (c.id == id && !c.isReading) {
            return c.copyWith(isReading: true);
          }
          return c;
        }).toList();
      });
    } catch (error) {
      print('Error al marcar como leyendo: $error');
      rethrow;
    }
  }
}

final comicControllerProvider =
    AsyncNotifierProvider<ComicController, List<ComicEntity>>(
  ComicController.new,
);
