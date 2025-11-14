import 'dart:io';

import 'package:archive/archive.dart';
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

    final created = ComicEntity(
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

    return created;
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
      String archivePath, String outputDir) async {
    final outDir = Directory(outputDir);
    final extracted = <File>[];
    int index = 0;

    if (archivePath.toLowerCase().endsWith('.cbz')) {
      final file = File(archivePath);
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final ent in archive) {
        if (!ent.isFile) continue;
        final nameLower = ent.name.toLowerCase();
        if (!nameLower.endsWith('.jpg') &&
            !nameLower.endsWith('.jpeg') &&
            !nameLower.endsWith('.png')) {
          continue;
        }
        final outFile = File(p.join(outputDir,
            '${(index + 1).toString().padLeft(4, '0')}${p.extension(ent.name).toLowerCase()}'));
        outFile.writeAsBytesSync(ent.content as List<int>);
        extracted.add(outFile);
        index++;
      }
    } else if (archivePath.toLowerCase().endsWith('.cbr')) {
      final tempDir = Directory.systemTemp.createTempSync();
      try {
        await UnrarFile.extract_rar(archivePath, tempDir.path);
        final files =
            tempDir.listSync(recursive: true).whereType<File>().where((f) {
          final l = f.path.toLowerCase();
          return l.endsWith('.jpg') ||
              l.endsWith('.jpeg') ||
              l.endsWith('.png');
        }).toList();

        files.sort((a, b) => a.path.compareTo(b.path));

        for (final f in files) {
          final ext = p.extension(f.path).toLowerCase();
          final dest = File(p.join(
              outputDir, '${(index + 1).toString().padLeft(4, '0')}$ext'));
          await f.copy(dest.path);
          extracted.add(dest);
          index++;
        }
      } finally {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      }
    } else {
      throw Exception('Unsupported file format');
    }

    return extracted;
  }

  @override
  Future<List<ComicEntity>> getAllComics() async {
    final models = await datasource.fetchAllComics();
    return models
        .map((m) => ComicEntity(
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
            ))
        .toList();
  }

  @override
  Future<void> addBookMark(int id, int bookmark) async {
    await datasource.updateBookmark(id, bookmark);
  }
}
