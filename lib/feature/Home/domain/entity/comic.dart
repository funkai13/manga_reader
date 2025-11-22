class ComicEntity {
  final int? id;
  final String filePath;
  final String title;
  final String picture;
  final int currentReadPage;
  final int totalPages;
  final String lastOpened;
  final int currentReading;
  final String imagesPath;
  final bool isReading;
  final bool isFavorite;
  final int? rating;
  final String bookMarks;
  final bool isCompleted;
  final String? author;
  final String? genre;
  final String? collection;
  final String? comicType;

  ComicEntity({
    this.id,
    required this.title,
    required this.filePath,
    this.picture = '',
    required this.currentReadPage,
    required this.totalPages,
    required this.lastOpened,
    required this.currentReading,
    required this.imagesPath,
    required this.isReading,
    required this.isFavorite,
    this.rating,
    required this.bookMarks,
    required this.isCompleted,
    this.author,
    this.genre,
    this.collection,
    this.comicType,
  });

  ComicEntity copyWith({
    int? id,
    String? filePath,
    String? title,
    int? currentReadPage,
    int? totalPages,
    String? picture,
    String? lastOpened,
    int? currentReading,
    String? imagesPath,
    bool? isReading,
    bool? isFavorite,
    int? rating,
    String? bookMarks,
    bool? isCompleted,
    String? author,
    String? genre,
    String? collection,
    String? comicType,
  }) {
    return ComicEntity(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      currentReadPage: currentReadPage ?? this.currentReadPage,
      totalPages: totalPages ?? this.totalPages,
      picture: picture ?? this.picture,
      lastOpened: lastOpened ?? this.lastOpened,
      currentReading: currentReading ?? this.currentReading,
      imagesPath: imagesPath ?? this.imagesPath,
      isReading: isReading ?? this.isReading,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      bookMarks: bookMarks ?? this.bookMarks,
      isCompleted: isCompleted ?? this.isCompleted,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      collection: collection ?? this.collection,
      comicType: comicType ?? this.comicType,
    );
  }
}
