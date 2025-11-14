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
  final String isReading;
  final String isFavorite;
  final String rating;
  final String bookMarks;
  final String isCompleted;

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
    required this.rating,
    required this.bookMarks,
    required this.isCompleted,
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
    String? isReading,
    String? isFavorite,
    String? rating,
    String? bookMarks,
    String? isCompleted,
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
    );
  }
}
