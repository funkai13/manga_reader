import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/data/datasources/comic_database.dart';
import 'package:manga_reader/feature/Library/data/repositories/library_repository_impl.dart';
import 'package:manga_reader/feature/Library/domain/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepositoryImpl(ComicDatabase.instance);
});
