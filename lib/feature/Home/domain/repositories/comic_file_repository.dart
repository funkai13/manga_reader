import 'dart:io';

abstract class ComicFileRepository {
  Future<List<File>> extractComic(String filePath);
}

class ExtractComicImagesUseCase {
  final ComicFileRepository comicFileRepository;

  ExtractComicImagesUseCase(this.comicFileRepository);

  Future<List<File>> call(String filePath) {
    return comicFileRepository.extractComic(filePath);
  }
}
