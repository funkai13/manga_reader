import 'dart:io';

import 'package:archive/archive.dart';
import 'package:manga_reader/feature/Home/data/datasources/comic_database.dart';
import 'package:manga_reader/feature/Home/data/models/comic_model.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';
import 'package:manga_reader/feature/Home/domain/repositories/comic_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unrar_file/unrar_file.dart';
import 'package:xml/xml.dart';

class ComicRepositoryImpl implements ComicRepository {
  final ComicDatabase datasource;

  ComicRepositoryImpl(this.datasource);

  @override
  Future<void> addComic(ComicEntity comic) async {
    String? thumbnailPath;
    if (comic.filePath.endsWith('.cbz')) {
      thumbnailPath =
          await _extractThumbnailFromCbz(comic.filePath, comic.title);
    } else if (comic.filePath.endsWith('.cbr')) {
      thumbnailPath =
          await _extractThumbnailFromCbr(comic.filePath, comic.title);
    }
    print('$thumbnailPath thumnailpath');
    final comicModel = ComicModel(
        title: comic.title,
        filePath: comic.filePath,
        totalPages: comic.totalPages,
        lastOpened: comic.lastOpened,
        currentReading: comic.currentReading,
        currentPage: comic.currentPage,
        picture: thumbnailPath.toString(),
        id: comic.id);

    print('Ruta de la imagen: ${comicModel.picture}');
    print('title ${comicModel.title}');

    await datasource.addComic(comicModel);
  }

  @override
  Future<List<ComicEntity>> getAllComics() async {
    final comics = await datasource.fetchAllComics();
    return comics;
  }

  Future<String?> _extractThumbnailFromCbz(
      String filePath, String comicTitle) async {
    final tempDir = Directory.systemTemp.createTempSync();
    String? thumbnailPath;

    try {
      print('Procesando CBZ: $filePath');
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extraemos los archivos del .cbz
      for (final file in archive) {
        if (file.isFile) {
          final tempFile = File('${tempDir.path}/${file.name}')
            ..writeAsBytesSync(file.content as List<int>);

          // Primero intentamos procesar el XML si está presente
          final xmlThumbnail = await _extractThumbnailFromXml(tempDir.path);
          if (xmlThumbnail != null) {
            thumbnailPath = xmlThumbnail;
            break;
          }

          // Si no encontramos XML o no tiene portada, buscamos la primera imagen
          if (file.name.endsWith('.jpg') || file.name.endsWith('.png')) {
            thumbnailPath = await _saveThumbnail(tempFile, comicTitle);
            break;
          }
        }
      }
    } catch (e) {
      print('Error al procesar el CBZ: $e');
    } finally {
      // Limpiar el directorio temporal
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }

    return thumbnailPath;
  }

  Future<String?> _extractThumbnailFromCbr(
      String filePath, String comicTitle) async {
    final tempDir = Directory.systemTemp.createTempSync();
    String? thumbnailPath;

    try {
      print('Procesando CBR: $filePath');
      await UnrarFile.extract_rar(filePath, tempDir.path);

      // Recorrer todos los archivos extraídos, incluyendo subdirectorios
      final directory = Directory(tempDir.path);
      final files = directory.listSync(recursive: true);

      for (final entity in files) {
        if (entity is File) {
          // Primero intentamos procesar el XML si está presente
          final xmlThumbnail = await _extractThumbnailFromXml(tempDir.path);
          if (xmlThumbnail != null) {
            thumbnailPath = xmlThumbnail;
            break;
          }

          // Si no encontramos XML o no tiene portada, buscamos la primera imagen
          if (entity.path.endsWith('.jpg') || entity.path.endsWith('.png')) {
            thumbnailPath = await _saveThumbnail(entity, comicTitle);
            break;
          }
        }
      }
    } catch (e) {
      print('Error al procesar el CBR: $e');
    } finally {
      // Limpiar el directorio temporal
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }

    return thumbnailPath;
  }

  Future<String> _saveThumbnail(File thumbnailFile, String comicTitle) async {
    final appDir = await getApplicationDocumentsDirectory();
    final coverDir = Directory('${appDir.path}/covers');
    if (!await coverDir.exists()) {
      await coverDir.create(recursive: true);
    }

    final sanitizedTitle =
        comicTitle.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final savedPath = '${coverDir.path}/$sanitizedTitle.jpg';

    return await thumbnailFile.copy(savedPath).then((file) => file.path);
  }

  Future<String?> _extractThumbnailFromXml(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      final xmlFile = directory.listSync().firstWhere(
            (entity) => entity is File && entity.path.endsWith('.xml'),
            orElse: () => throw Exception('XML file not found'),
          );

      final xmlContent = await File(xmlFile.path).readAsString();
      final document = XmlDocument.parse(xmlContent);

      // Buscar la portada (cover)
      final coverElement = document.findElements('cover').firstOrNull;
      if (coverElement != null && coverElement.text.isNotEmpty) {
        return coverElement.text;
      }

      // Si no hay portada, buscar la primera imagen
      final firstImageElement = document.findElements('image').firstOrNull;
      if (firstImageElement != null && firstImageElement.text.isNotEmpty) {
        return firstImageElement.text;
      }

      // Si no encontramos nada, devolver null
      return null;
    } catch (e) {
      print('Error al procesar el XML: $e');
      return null;
    }
  }
}
