import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:archive/archive.dart';
import 'package:manga_reader/feature/Home/domain/exceptions/comic_exceptions.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:unrar_file/unrar_file.dart';

import '../../domain/entity/comic.dart';
import '../../domain/repositories/comic_repository.dart';
import '../datasources/comic_database.dart';
import '../models/comic_fields.dart';
import '../models/comic_model.dart';

class ComicRepositoryImpl implements ComicRepository {
  final ComicDatabase datasource;

  ComicRepositoryImpl(this.datasource);

  @override
  Future<ComicEntity?> getComicByPath(String path) async {
    final comicModel = await datasource.getComicByPath(path);
    if (comicModel == null) {
      return null;
    }
    return ComicEntity(
      id: comicModel.id,
      filePath: comicModel.filePath,
      title: comicModel.title,
      picture: comicModel.picture,
      currentReadPage: comicModel.currentReadPage,
      totalPages: comicModel.totalPages,
      lastOpened: comicModel.lastOpened,
      currentReading: comicModel.currentReading,
      imagesPath: comicModel.imagesPath,
      isFavorite: comicModel.isFavorite,
      isReading: comicModel.isReading,
      rating: comicModel.rating,
      bookMarks: comicModel.bookMarks,
      isCompleted: comicModel.isCompleted,
      author: comicModel.author,
      genre: comicModel.genre,
      collection: comicModel.collection,
      comicType: comicModel.comicType,
    );
  }

  @override
  Future<ComicEntity?> getComicByTitle(String title) async {
    final comicModel = await datasource.getComicByTitle(title);
    if (comicModel == null) {
      return null;
    }
    return ComicEntity(
      id: comicModel.id,
      filePath: comicModel.filePath,
      title: comicModel.title,
      picture: comicModel.picture,
      currentReadPage: comicModel.currentReadPage,
      totalPages: comicModel.totalPages,
      lastOpened: comicModel.lastOpened,
      currentReading: comicModel.currentReading,
      imagesPath: comicModel.imagesPath,
      isFavorite: comicModel.isFavorite,
      isReading: comicModel.isReading,
      rating: comicModel.rating,
      bookMarks: comicModel.bookMarks,
      isCompleted: comicModel.isCompleted,
      author: comicModel.author,
      genre: comicModel.genre,
      collection: comicModel.collection,
      comicType: comicModel.comicType,
    );
  }

  @override
  Future<ComicEntity?> getComicByFilenameMatch(String filename) async {
    final comicModel = await datasource.getComicByFilenameMatch(filename);
    if (comicModel == null) {
      return null;
    }
    return ComicEntity(
      id: comicModel.id,
      filePath: comicModel.filePath,
      title: comicModel.title,
      picture: comicModel.picture,
      currentReadPage: comicModel.currentReadPage,
      totalPages: comicModel.totalPages,
      lastOpened: comicModel.lastOpened,
      currentReading: comicModel.currentReading,
      imagesPath: comicModel.imagesPath,
      isFavorite: comicModel.isFavorite,
      isReading: comicModel.isReading,
      rating: comicModel.rating,
      bookMarks: comicModel.bookMarks,
      isCompleted: comicModel.isCompleted,
      author: comicModel.author,
      genre: comicModel.genre,
      collection: comicModel.collection,
      comicType: comicModel.comicType,
    );
  }

  @override
  Future<ComicEntity> addComic(ComicEntity comic) async {
    final existingComic = await datasource.getComicByTitle(comic.title);

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
        author: existingComic.author,
        genre: existingComic.genre,
        collection: existingComic.collection,
        comicType: existingComic.comicType,
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
      author: comic.author,
      genre: comic.genre,
      collection: comic.collection,
      comicType: comic.comicType,
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
        author: comic.author,
        genre: comic.genre,
        collection: comic.collection,
        comicType: comic.comicType,
      );
    } on UnsupportedComicException {
      await _cleanupFailedInsert(newId, folderPath);
      rethrow;
    } catch (e) {
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
    final ext = p.extension(archivePath).toLowerCase();

    final archiveFile = File(archivePath);
    if (!await archiveFile.exists()) {
      return <File>[];
    }

    final tempOutput = Directory(p.join(outputDir, 'temp_extract'));
    if (!tempOutput.existsSync()) {
      tempOutput.createSync(recursive: true);
    }

    final rawExtracted = <File>[];
    final seenPaths = <String>{};

    if (ext == '.cbz') {
      try {
        final bytes = await archiveFile.readAsBytes();
        // Use compute to run decodeBytes in a separate isolate
        final archive = await compute(_decodeZip, bytes);

        for (final ent in archive) {
          if (!ent.isFile) continue;
          if (!_isImageName(ent.name)) continue;

          final destPath = p.join(tempOutput.path, ent.name);
          if (seenPaths.contains(destPath)) {
            continue;
          }

          final outFile = File(destPath);
          outFile.createSync(recursive: true);
          await outFile.writeAsBytes(ent.content as List<int>);
          rawExtracted.add(outFile);
          seenPaths.add(destPath);
        }
      } catch (e) {
        throw UnsupportedComicException(
          'No se pudo leer el archivo CBZ. El archivo puede estar corrupto.',
        );
      }
    } else if (ext == '.cbr') {
      final tempDir = Directory.systemTemp.createTempSync();

      try {
        await UnrarFile.extract_rar(archivePath, tempDir.path);

        final files = tempDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => _isImagePath(f.path))
            .toList();

        for (final f in files) {
          final destPath = p.join(tempOutput.path, p.basename(f.path));

          if (seenPaths.contains(destPath)) {
            continue;
          }

          final dest = File(destPath);
          await f.copy(dest.path);
          rawExtracted.add(dest);
          seenPaths.add(destPath);
        }
      } catch (e) {
        throw UnsupportedComicException(
          'No se pudo extraer el archivo CBR (posiblemente RAR5 no soportado).',
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    }

    if (rawExtracted.isEmpty) {
      throw UnsupportedComicException(
        'El archivo no contiene imágenes soportadas (.jpg, .jpeg, .png).',
      );
    }

    rawExtracted.sort((a, b) => _naturalSort(a.path, b.path));

    final finalFiles = <File>[];
    var index = 1;

    for (final original in rawExtracted) {
      final srcFile = File(original.path);
      if (!srcFile.existsSync()) {
        continue;
      }

      final pageExt = p.extension(original.path).toLowerCase();
      final newPath = p.join(
        outputDir,
        index.toString().padLeft(4, '0') + pageExt,
      );

      final f = await srcFile.rename(newPath);
      finalFiles.add(f);
      index++;
    }

    if (tempOutput.existsSync()) {
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
            author: m.author,
            genre: m.genre,
            collection: m.collection,
            comicType: m.comicType,
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

  @override
  Future<void> updateComicMetadata({
    required int id,
    String? title,
    String? author,
    String? genre,
    String? collection,
    String? comicType,
  }) async {
    await datasource.updateComic(
      id: id,
      title: title,
      author: author,
      genre: genre,
      collection: collection,
      comicType: comicType,
    );
  }

  @override
  Future<List<String>> getDistinctAuthors() async {
    return await datasource.getDistinctValues(ComicFields.author);
  }

  @override
  Future<List<String>> getDistinctGenres() async {
    return await datasource.getDistinctValues(ComicFields.genre);
  }

  @override
  Future<List<String>> getDistinctCollections() async {
    return await datasource.getDistinctValues(ComicFields.collection);
  }

  @override
  Future<List<ComicEntity>> getComicsByAuthor(String author) async {
    return await datasource.getComicsByAuthor(author);
  }

  @override
  Future<List<ComicEntity>> getComicsByGenre(String genre) async {
    return await datasource.getComicsByGenre(genre);
  }

  @override
  Future<List<ComicEntity>> getComicsByCollection(String collection) async {
    return await datasource.getComicsByCollection(collection);
  }
}

// Top-level function for compute
Archive _decodeZip(List<int> bytes) {
  return ZipDecoder().decodeBytes(bytes);
}
