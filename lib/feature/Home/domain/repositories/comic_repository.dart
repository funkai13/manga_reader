import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

abstract class ComicRepository {
  Future<void> addComic(ComicEntity comic);

  Future<List<ComicEntity>> getAllComics();
}
