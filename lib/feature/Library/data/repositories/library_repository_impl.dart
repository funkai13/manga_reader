import 'package:manga_reader/feature/Home/data/datasources/comic_database.dart';
import 'package:manga_reader/feature/Library/domain/entities/category_entity.dart';
import 'package:manga_reader/feature/Library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final ComicDatabase datasource;

  LibraryRepositoryImpl(this.datasource);

  @override
  Future<List<CategoryEntity>> getAuthors() async {
    final result = await datasource.getAuthorsWithCount();
    return result.map((e) => CategoryEntity(
      name: e['name'] as String,
      count: e['count'] as int,
      type: 'author',
      coverPath: e['coverPath'] as String?,
    )).toList();
  }

  @override
  Future<List<CategoryEntity>> getGenres() async {
    final result = await datasource.getGenresWithCount();
    return result.map((e) => CategoryEntity(
      name: e['name'] as String,
      count: e['count'] as int,
      type: 'genre',
      coverPath: e['coverPath'] as String?,
    )).toList();
  }

  @override
  Future<List<CategoryEntity>> getCollections() async {
    final result = await datasource.getCollectionsWithCount();
    return result.map((e) => CategoryEntity(
      name: e['name'] as String,
      count: e['count'] as int,
      type: 'collection',
      coverPath: e['coverPath'] as String?,
    )).toList();
  }

  @override
  Future<void> renameAuthor(String oldName, String newName) async {
    await datasource.updateAuthorName(oldName, newName);
  }

  @override
  Future<void> renameGenre(String oldName, String newName) async {
    await datasource.updateGenreName(oldName, newName);
  }

  @override
  Future<void> renameCollection(String oldName, String newName) async {
    await datasource.updateCollectionName(oldName, newName);
  }
}
