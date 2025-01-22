import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

class ComicModel extends ComicEntity {
  ComicModel(
      {required super.title,
      required super.filePath,
      required super.totalPages,
      required super.lastOpened,
      required super.currentReading,
      required currentPage,
      required super.picture,
      required id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'title': title,
      'picture': picture,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'lastOpened': lastOpened,
      'currentReading': currentReading,
    };
  }

  factory ComicModel.fromMap(Map<String, dynamic> map) {
    return ComicModel(
      id: map['id'],
      filePath: map['filePath'],
      title: map['title'],
      picture: map['picture'],
      currentPage: map['currentPage'],
      totalPages: map['totalPages'],
      lastOpened: map['lastOpened'],
      currentReading: map['currentReading'],
    );
  }
}
