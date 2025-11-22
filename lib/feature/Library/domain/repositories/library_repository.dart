import 'package:manga_reader/feature/Library/domain/entities/category_entity.dart';

abstract class LibraryRepository {
  Future<List<CategoryEntity>> getAuthors();
  Future<List<CategoryEntity>> getGenres();
  Future<List<CategoryEntity>> getCollections();
  
  Future<void> renameAuthor(String oldName, String newName);
  Future<void> renameGenre(String oldName, String newName);
  Future<void> renameCollection(String oldName, String newName);
}
