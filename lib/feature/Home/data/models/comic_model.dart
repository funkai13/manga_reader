import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

class ComicModel extends ComicEntity {
  ComicModel(
      {required super.title,
      required super.filePath,
      required super.totalPages,
      required super.lastOpened,
      required super.currentReading,
      required super.currentReadPage,
      required super.picture,
      required super.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'title': title,
      'picture': picture,
      'currentPage': currentReadPage,
      'totalPages': totalPages,
      'lastOpened': lastOpened,
      'currentReading': currentReading,
    };
  }

  factory ComicModel.fromMap(Map<String, dynamic> map) {
    return ComicModel(
      id: map['id'] as int,
      filePath: map['filePath'],
      title: map['title'],
      picture: map['picture'],
      currentReadPage: map['currentPage'],
      totalPages: map['totalPages'],
      lastOpened: map['lastOpened'],
      currentReading: map['currentReading'],
    );
  }
}
