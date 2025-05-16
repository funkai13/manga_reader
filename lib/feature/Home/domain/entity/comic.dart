class ComicEntity {
  final int? id;
  final String filePath;
  final String title;
  final String picture;
  final int currentReadPage;
  final int totalPages;
  final String lastOpened;
  final int currentReading;

  ComicEntity({
    this.id,
    required this.title,
    required this.filePath,
    this.picture = '',
    required this.currentReadPage,
    required this.totalPages,
    required this.lastOpened,
    required this.currentReading,
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
    );
  }
}
