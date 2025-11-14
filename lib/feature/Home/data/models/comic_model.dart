import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

import 'comic_fields.dart';

class ComicModel extends ComicEntity {
  ComicModel(
      {required super.title,
      required super.filePath,
      required super.totalPages,
      required super.lastOpened,
      required super.currentReading,
      required super.currentReadPage,
      required super.picture,
      required super.id,
      required super.imagesPath,
      required super.isFavorite,
      required super.isReading,
      required super.bookMarks,
      required super.isCompleted,
      required super.rating});

  Map<String, dynamic> toMap() {
    return {
      ComicFields.id: id,
      ComicFields.filePath: filePath,
      ComicFields.title: title,
      ComicFields.picture: picture,
      ComicFields.currentPage: currentReadPage,
      ComicFields.totalPages: totalPages,
      ComicFields.lastOpened: lastOpened,
      ComicFields.currentReading: currentReading,
      ComicFields.imagesPath: imagesPath,
      ComicFields.isFavorite: isFavorite,
      ComicFields.isReading: isReading,
      ComicFields.rating: rating,
      ComicFields.bookMarks: bookMarks,
      ComicFields.isCompleted: isCompleted,
    };
  }

  factory ComicModel.fromMap(Map<String, dynamic> map) {
    return ComicModel(
        id: map[ComicFields.id] as int,
        filePath: map[ComicFields.filePath],
        title: map[ComicFields.title],
        picture: map[ComicFields.picture],
        currentReadPage: map[ComicFields.currentPage],
        totalPages: map[ComicFields.totalPages],
        lastOpened: map[ComicFields.lastOpened],
        currentReading: map[ComicFields.currentReading],
        imagesPath: map[ComicFields.imagesPath],
        isFavorite: map[ComicFields.isFavorite],
        isReading: map[ComicFields.isReading],
        rating: map[ComicFields.rating],
        bookMarks: map[ComicFields.bookMarks],
        isCompleted: map[ComicFields.isCompleted]);
  }
}
