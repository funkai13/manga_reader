import 'dart:io';

import 'package:archive/archive.dart';
import 'package:unrar_file/unrar_file.dart';

import '../../domain/repositories/comic_file_repository.dart';

class ComicFileRepositoryImpl implements ComicFileRepository {
  @override
  Future<List<File>> extractComic(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    if (filePath.endsWith('.cbz')) {
      final archive = ZipDecoder().decodeBytes(bytes);
      return _extractFiles(archive);
    } else if (filePath.endsWith('.cbr')) {
      return _extractFilesFromRar(filePath);
    } else {
      throw Exception('Unsupported file format');
    }
  }

  Future<List<File>> _extractFiles(Archive archive) async {
    final tempDir = Directory.systemTemp.createTempSync();
    final extractedFiles = <File>[];

    for (final file in archive) {
      if (file.isFile &&
          (file.name.endsWith('.jpg') || file.name.endsWith('.png'))) {
        final outputFile = File('${tempDir.path}/${file.name}')
          ..writeAsBytesSync(file.content as List<int>);
        extractedFiles.add(outputFile);
      }
    }
    return extractedFiles;
  }

  Future<List<File>> _extractFilesFromRar(String filePath) async {
    final tempDir = Directory.systemTemp.createTempSync();
    final extractedFiles = <File>[];

    try {
      await UnrarFile.extract_rar(filePath, tempDir.path);

      final extractedDir = Directory(tempDir.path);
      final files =
          extractedDir.listSync(recursive: true); // Recursively list all files
      print("Extracted files: $files");
      for (final entity in files) {
        if (entity is File) {
          final filePath = entity.path;
          print("Checking file: $filePath");
          if (filePath.endsWith('.jpg') || filePath.endsWith('.png')) {
            print("Adding file: $filePath");
            extractedFiles.add(entity);
          }
        }
      }
      print("Extracted files list: $extractedFiles");
    } catch (e) {
      print('Error extracting CBR file: $e');
      throw Exception('Error extracting CBR file: $e');
    }

    return extractedFiles;
  }
}
