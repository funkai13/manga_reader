import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:manga_reader/feature/Library/domain/entities/category_entity.dart';
import 'package:manga_reader/feature/Library/domain/providers/library_provider.dart';

part 'library_controller.g.dart';

@riverpod
class LibraryController extends _$LibraryController {
  @override
  Future<List<CategoryEntity>> build(String type) async {
    final repository = ref.read(libraryRepositoryProvider);
    switch (type) {
      case 'author':
        return await repository.getAuthors();
      case 'genre':
        return await repository.getGenres();
      case 'collection':
        return await repository.getCollections();
      default:
        return [];
    }
  }

  Future<void> renameCategory(String oldName, String newName, String type) async {
    final repository = ref.read(libraryRepositoryProvider);
    try {
      switch (type) {
        case 'author':
          await repository.renameAuthor(oldName, newName);
          break;
        case 'genre':
          await repository.renameGenre(oldName, newName);
          break;
        case 'collection':
          await repository.renameCollection(oldName, newName);
          break;
      }
      // Refresh the list
      ref.invalidateSelf();
    } catch (e) {
      // Handle error if needed, for now rethrow to let UI handle it
      rethrow;
    }
  }
}
