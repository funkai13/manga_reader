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
    final tempOutput = Directory("$outputDir/temp_extract");
    if (!tempOutput.existsSync()) tempOutput.createSync(recursive: true);

    final rawExtracted = <File>[];

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

        final outFile = File(p.join(tempOutput.path, ent.name));
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(ent.content as List<int>);
        rawExtracted.add(outFile);
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

        for (final f in files) {
          final dest = File(p.join(tempOutput.path, p.basename(f.path)));
          await f.copy(dest.path);
          rawExtracted.add(dest);
        }
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    }

    rawExtracted.sort((a, b) => _naturalSort(a.path, b.path));

    for (int i = 0; i < rawExtracted.length; i++) {
      print("   ${i + 1}. ${rawExtracted[i].path}");
    }

    final finalFiles = <File>[];
    int index = 1;

    for (final original in rawExtracted) {
      final ext = p.extension(original.path).toLowerCase();
      final newPath = p.join(
        outputDir,
        index.toString().padLeft(4, '0') + ext,
      );

      final f = File(original.path).renameSync(newPath);
      finalFiles.add(f);

      index++;
    }

    if (tempOutput.existsSync()) tempOutput.deleteSync(recursive: true);

    return finalFiles;
  }

  int _naturalSort(String a, String b) {
    final regex = RegExp(r'(\d+)|(\D+)');
    final aMatches = regex.allMatches(a).map((m) => m.group(0)!).toList();
    final bMatches = regex.allMatches(b).map((m) => m.group(0)!).toList();

    for (int i = 0; i < aMatches.length && i < bMatches.length; i++) {
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
