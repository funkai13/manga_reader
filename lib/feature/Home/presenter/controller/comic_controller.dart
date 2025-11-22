import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/domain/exceptions/comic_exceptions.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/comic_metadata_dialog.dart';

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
            // 1. Show loading spinner immediately
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            // 2. Start processing in background
            final processingFuture = comicRepository.addComic(newComicEntity);

            // 3. Wait a bit to ensure spinner is seen (optional, but requested for UX)
            // and to allow the background process to initialize
            await Future.delayed(const Duration(milliseconds: 500));

            // 4. Close spinner and show metadata dialog
            if (!context.mounted) return;
            Navigator.of(context).pop(); // Close spinner

            final dialogFuture = showDialog<Map<String, String>?>(
              context: context,
              barrierDismissible: false,
              builder: (context) => ComicMetadataDialog(fileName: fileName),
            );

            // 5. Wait for both
            final results = await Future.wait([
              processingFuture,
              dialogFuture,
            ], eagerError: false);

            final createdComic = results[0] as ComicEntity;
            final metadata = results[1] as Map<String, String>?;

            // 4. Update metadata if provided
            if (metadata != null) {
              await comicRepository.updateComicMetadata(
                id: createdComic.id!,
                title: metadata['title'],
                author: metadata['author'],
                genre: metadata['genre'],
                collection: metadata['collection'],
                comicType: metadata['comicType'],
              );
            }

            // 5. Update state
            // Re-fetch to get the updated metadata
            final updatedList = await comicRepository.getAllComics();
            state = AsyncData(updatedList);
          } on UnsupportedComicException catch (e) {
            // If error happens very fast (before spinner pop), we might need to pop it.
            // However, since we await Future.delayed, we likely popped it.
            // But if addComic throws synchronously (it shouldn't), we need to handle it.
            // For now, let's assume the flow reaches the pop.
            // Actually, if addComic throws, processingFuture holds the error.
            // Future.wait will throw.
            
            if (!context.mounted) return;
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
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ocurrió un error al agregar el cómic.'),
              ),
            );
          }
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Seleccione un archivo con extensión .cbr o .cbz"),
          ),
        );
      }
    } else {
      if (!context.mounted) return;
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
      rethrow;
    }
  }

  Future<List<String>> getSuggestions(String type) async {
    final comicRepository = ref.read(comicRepositoryProvider);
    switch (type) {
      case 'author':
        return await comicRepository.getDistinctAuthors();
      case 'genre':
        final existingGenres = await comicRepository.getDistinctGenres();
        final predefinedGenres = [
          'Shonen',
          'Seinen',
          'Shojo',
          'Josei',
          'Kodomo',
          'Isekai',
          'Fantasía',
          'Acción',
          'Aventura',
          'Comedia',
          'Drama',
          'Romance',
          'Ciencia Ficción',
          'Terror',
          'Misterio',
          'Slice of Life',
          'Deportes',
          'Mecha',
          'Superhéroes',
          'Histórico',
        ];
        // Combine and remove duplicates
        final allGenres = {...existingGenres, ...predefinedGenres}.toList();
        allGenres.sort();
        return allGenres;
      case 'collection':
        return await comicRepository.getDistinctCollections();
      default:
        return [];
    }
  }

  Future<void> updateComicMetadata({
    required int id,
    String? title,
    String? author,
    String? genre,
    String? collection,
    String? comicType,
  }) async {
    final comicRepository = ref.read(comicRepositoryProvider);
    await comicRepository.updateComicMetadata(
      id: id,
      title: title,
      author: author,
      genre: genre,
      collection: collection,
      comicType: comicType,
    );
    // Refresh the list
    final updatedList = await comicRepository.getAllComics();
    state = AsyncData(updatedList);
  }
}

final comicControllerProvider =
    AsyncNotifierProvider<ComicController, List<ComicEntity>>(
  ComicController.new,
);
