import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/data/datasources/comic_database.dart';

import '../../data/repositories/comic_repository_impl.dart';
import '../repositories/comic_repository.dart';

final comicRepositoryProvider = Provider<ComicRepository>(
    (ref) => ComicRepositoryImpl(ComicDatabase.instance));
