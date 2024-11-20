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

    // Selección del archivo
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      final fileName = result.files.single.name;
      final extension =
          fileName.split('.').last.toLowerCase(); // Usamos fileName aquí

      // Verificación de la extensión del archivo
      if (extension == 'cbr' || extension == 'cbz') {
        if (filePath != null) {
          // Crea una nueva instancia de ComicEntity
          final newComic = ComicEntity(
            filePath: filePath,
            title: fileName,
            currentPage: 0,
            totalPages: 0,
            picture: '',
            lastOpened: DateTime.now().toIso8601String(),
            currentReading: 0,
          );
          await comicRepository.addComic(newComic);
          print('Inserting comic: $newComic, ');
          // Actualiza el estado del controlador para reflejar los cambios
          state = AsyncData([...state.value ?? [], newComic]);
        }
      } else {
        // Muestra un mensaje de error si el archivo no es válido
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Seleccione un archivo con extensión .cbr o .cbz")),
        );
      }
    } else {
      // Muestra un mensaje de error si no se selecciona un archivo
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
}

final comicControllerProvider =
    AutoDisposeAsyncNotifierProvider<ComicController, List<ComicEntity>>(
  ComicController.new,
);
