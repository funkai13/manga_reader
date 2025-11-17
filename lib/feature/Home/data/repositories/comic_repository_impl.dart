import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart'; // para kDebugMode
import 'package:manga_reader/feature/Home/domain/exceptions/comic_exceptions.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:unrar_file/unrar_file.dart';

import '../../domain/entity/comic.dart';
import '../../domain/repositories/comic_repository.dart';
import '../datasources/comic_database.dart';
import '../models/comic_model.dart';

class ComicRepositoryImpl implements ComicRepository {
  final ComicDatabase datasource;

  ComicRepositoryImpl(this.datasource);

  @override
  Future<ComicEntity> addComic(ComicEntity comic) async {
    final existingComic = await datasource.getComicByTitle(comic.title);
    _log('🔍 existingComic: $existingComic');
    _log('🔍 comic: $comic');

    if (existingComic != null) {
      return ComicEntity(
        id: existingComic.id,
        filePath: existingComic.filePath,
        title: existingComic.title,
        picture: existingComic.picture,
        currentReadPage: existingComic.currentReadPage,
        totalPages: existingComic.totalPages,
        lastOpened: existingComic.lastOpened,
        currentReading: existingComic.currentReading,
        imagesPath: existingComic.imagesPath,
        isFavorite: existingComic.isFavorite,
        isReading: existingComic.isReading,
        rating: existingComic.rating,
        bookMarks: existingComic.bookMarks,
        isCompleted: existingComic.isCompleted,
      );
    }

    final comicModel = ComicModel(
      id: null,
      filePath: comic.filePath,
      title: comic.title,
      picture: comic.picture,
      currentReadPage: comic.currentReadPage,
      totalPages: comic.totalPages,
      lastOpened: comic.lastOpened,
      currentReading: comic.currentReading,
      imagesPath: comic.imagesPath,
      isFavorite: comic.isFavorite,
      isReading: comic.isReading,
      rating: comic.rating,
      bookMarks: comic.bookMarks,
      isCompleted: comic.isCompleted,
    );

    final newId = await datasource.addComic(comicModel);

    final folderPath = await _getComicFolderPath(newId);
    try {
      final extractedFiles =
          await _extractComicToFolder(comic.filePath, folderPath);

      extractedFiles.sort((a, b) => a.path.compareTo(b.path));

      final String? thumbnailPath =
          extractedFiles.isNotEmpty ? extractedFiles.first.path : null;

      await datasource.updateComic(
        id: newId,
        imagesPath: folderPath,
        picture: thumbnailPath,
        totalPages: extractedFiles.length,
      );
      return ComicEntity(
        id: newId,
        filePath: comic.filePath,
        title: comic.title,
        picture: thumbnailPath ?? '',
        currentReadPage: comic.currentReadPage,
        totalPages: extractedFiles.length,
        lastOpened: comic.lastOpened,
        currentReading: comic.currentReading,
        imagesPath: folderPath,
        isFavorite: comic.isFavorite,
        isReading: comic.isReading,
        rating: comic.rating,
        bookMarks: comic.bookMarks,
        isCompleted: comic.isCompleted,
      );
    } on UnsupportedComicException catch (e) {
      _log('⚠️ UnsupportedComicException en addComic: $e');
      await _cleanupFailedInsert(newId, folderPath);
      rethrow;
    } catch (e, st) {
      _log('❌ Error inesperado en addComic: $e');
      _log(st.toString());
      await _cleanupFailedInsert(newId, folderPath);
      rethrow;
    }
  }

  Future<void> _cleanupFailedInsert(int id, String folderPath) async {
    await datasource.deleteComic(id);

    final dir = Directory(folderPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<String> _getComicFolderPath(int comicId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final path = p.join(appDir.path, 'comics', comicId.toString());
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<List<File>> _extractComicToFolder(
    String archivePath,
    String outputDir,
  ) async {
    _log('🔍 archivePath: $archivePath');
    _log('🔍 outputDir: $outputDir');

    final ext = p.extension(archivePath).toLowerCase();
    _log('🔍 extension: $ext');

    final archiveFile = File(archivePath);
    if (!await archiveFile.exists()) {
      _log('❌ archivo no existe: $archivePath');
      return <File>[];
    }

    final tempOutput = Directory(p.join(outputDir, 'temp_extract'));
    if (!tempOutput.existsSync()) {
      _log('📁 creando tempOutput: ${tempOutput.path}');
      tempOutput.createSync(recursive: true);
    }

    final rawExtracted = <File>[];
    final seenPaths = <String>{}; // para evitar duplicados por path

    if (ext == '.cbz') {
      try {
        _log('📦 procesando CBZ (ZIP)');
        final bytes = await archiveFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);

        for (final ent in archive) {
          if (!ent.isFile) continue;
          if (!_isImageName(ent.name)) continue;

          final destPath = p.join(tempOutput.path, ent.name);
          if (seenPaths.contains(destPath)) {
            _log('⚠️ duplicado (CBZ), skip: $destPath');
            continue;
          }

          final outFile = File(destPath);
          outFile.createSync(recursive: true);
          // async para no bloquear tanto
          await outFile.writeAsBytes(ent.content as List<int>);
          rawExtracted.add(outFile);
          seenPaths.add(destPath);
        }
      } catch (e, st) {
        _log('❌ Error al leer CBZ: $e');
        _log(st.toString());
        throw UnsupportedComicException(
          'No se pudo leer el archivo CBZ. El archivo puede estar corrupto.',
        );
      }
    } else if (ext == '.cbr') {
      _log('📦 procesando CBR (RAR)');

      final tempDir = Directory.systemTemp.createTempSync();
      _log('📁 tempDir RAR: ${tempDir.path}');

      try {
        _log('➡️ llamando a UnrarFile.extract_rar...');
        await UnrarFile.extract_rar(archivePath, tempDir.path);
        _log('✅ extracción RAR completada');

        final files = tempDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => _isImagePath(f.path))
            .toList();

        _log('📄 imágenes encontradas en CBR: ${files.length}');

        for (final f in files) {
          final destPath = p.join(tempOutput.path, p.basename(f.path));

          if (seenPaths.contains(destPath)) {
            _log('⚠️ duplicado (CBR), skip: $destPath');
            continue;
          }

          final dest = File(destPath);
          await f.copy(dest.path);
          rawExtracted.add(dest);
          seenPaths.add(destPath);
        }
      } catch (e, st) {
        _log('❌ Error al extraer CBR: $e');
        _log(st.toString());
        throw UnsupportedComicException(
          'No se pudo extraer el archivo CBR (posiblemente RAR5 no soportado).',
        );
      } finally {
        _log('🧹 borrando tempDir RAR...');
        tempDir.deleteSync(recursive: true);
      }
    } else {
      _log('⚠️ extensión no soportada: $ext');
    }

    if (rawExtracted.isEmpty) {
      // Nada que mostrar → consideramos que no es soportado
      throw UnsupportedComicException(
        'El archivo no contiene imágenes soportadas (.jpg, .jpeg, .png).',
      );
    }

    _log('📄 rawExtracted antes de ordenar: ${rawExtracted.length}');
    rawExtracted.sort((a, b) => _naturalSort(a.path, b.path));

    for (int i = 0; i < rawExtracted.length; i++) {
      _log("   ${i + 1}. ${rawExtracted[i].path}");
    }

    final finalFiles = <File>[];
    var index = 1;

    for (final original in rawExtracted) {
      final srcFile = File(original.path);
      if (!srcFile.existsSync()) {
        _log('⚠️ source ya no existe, skip: ${original.path}');
        continue;
      }

      final pageExt = p.extension(original.path).toLowerCase();
      final newPath = p.join(
        outputDir,
        index.toString().padLeft(4, '0') + pageExt,
      );

      _log('🔁 renombrando ${original.path} -> $newPath');

      final f = await srcFile.rename(newPath);
      finalFiles.add(f);
      index++;
    }

    _log('✅ finalFiles: ${finalFiles.length}');
    if (tempOutput.existsSync()) {
      _log('🧹 borrando tempOutput: ${tempOutput.path}');
      tempOutput.deleteSync(recursive: true);
    }

    return finalFiles;
  }

  bool _isImagePath(String path) => _isImageName(p.basename(path));

  bool _isImageName(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  int _naturalSort(String a, String b) {
    final regex = RegExp(r'(\d+)|(\D+)');
    final aMatches = regex.allMatches(a).map((m) => m.group(0)!).toList();
    final bMatches = regex.allMatches(b).map((m) => m.group(0)!).toList();

    for (var i = 0; i < aMatches.length && i < bMatches.length; i++) {
      final aPart = aMatches[i];
      final bPart = bMatches[i];

      final aNum = int.tryParse(aPart);
      final bNum = int.tryParse(bPart);

      if (aNum != null && bNum != null) {
        final diff = aNum.compareTo(bNum);
        if (diff != 0) return diff;
      } else {
        final diff = aPart.compareTo(bPart);
        if (diff != 0) return diff;
      }
    }

    return aMatches.length.compareTo(bMatches.length);
  }

  void _log(String msg) {
    if (kDebugMode) {
      print('[_extractComicToFolder] $msg');
    }
  }

  @override
  Future<List<ComicEntity>> getAllComics() async {
    final models = await datasource.fetchAllComics();
    return models
        .map(
          (m) => ComicEntity(
            id: m.id,
            filePath: m.filePath,
            title: m.title,
            picture: m.picture,
            currentReadPage: m.currentReadPage,
            totalPages: m.totalPages,
            lastOpened: m.lastOpened,
            currentReading: m.currentReading,
            imagesPath: m.imagesPath,
            isFavorite: m.isFavorite,
            isReading: m.isReading,
            rating: m.rating,
            bookMarks: m.bookMarks,
            isCompleted: m.isCompleted,
          ),
        )
        .toList();
  }

  @override
  Future<void> addBookMark(int id, int bookmark) async {
    await datasource.updateBookmark(id, bookmark);
  }

  @override
  Future<void> startReadingComic(int id) async {
    await datasource.updateComic(id: id, isReading: true);
  }

  @override
  Future<void> deleteComic(int id) {
    return datasource.deleteComic(id);
  }
}
