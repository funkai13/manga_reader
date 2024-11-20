import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/comic_file_repository.dart';
import '../repositories/comic_file_repository.dart';

final comicFileRepositoryProvider = Provider<ComicFileRepository>(
  (ref) => ComicFileRepositoryImpl(),
);

final extractComicImagesUseCaseProvider = Provider<ExtractComicImagesUseCase>(
  (ref) => ExtractComicImagesUseCase(ref.read(comicFileRepositoryProvider)),
);
