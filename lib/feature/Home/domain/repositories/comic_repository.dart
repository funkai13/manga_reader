import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

abstract class ComicRepository {
  Future<ComicEntity> addComic(ComicEntity comic);

  Future<List<ComicEntity>> getAllComics();

  Future<void> addBookMark(int id, int bookMark);

  Future<void> startReadingComic(int id);

  Future<void> deleteComic(int id);
  
  Future<void> updateComicMetadata({
    required int id,
    String? title,
    String? author,
    String? genre,
    String? collection,
    String? comicType,
  });

  Future<List<String>> getDistinctAuthors();
  Future<List<String>> getDistinctGenres();
  Future<List<String>> getDistinctCollections();
}
