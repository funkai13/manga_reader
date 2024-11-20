import 'package:manga_reader/feature/Home/data/datasources/comic_database.dart';
import 'package:manga_reader/feature/Home/data/models/comic_model.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';
import 'package:manga_reader/feature/Home/domain/repositories/comic_repository.dart';

class ComicRepositoryImpl implements ComicRepository {
  final ComicDatabase datasource;

  ComicRepositoryImpl(this.datasource);

  @override
  Future<void> addComic(ComicEntity comic) async {
    final comicModel = ComicModel(
        title: comic.title,
        filePath: comic.filePath,
        totalPages: comic.totalPages,
        lastOpened: comic.lastOpened,
        currentReading: comic.currentReading,
        currentPage: comic.currentPage,
        picture: comic.picture,
        id: comic.id);
    await datasource.addComic(comicModel);
  }

  @override
  Future<List<ComicEntity>> getAllComics() async {
    final comics = await datasource.fetchAllComics();
    return comics; // Ya es una lista de `ComicEntity`
  }
}
