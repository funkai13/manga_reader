class ComicEntity {
  final int? id;
  final String filePath;
  final String title;
  final String picture;
  final int currentPage;
  final int totalPages;
  final String lastOpened;
  final int currentReading;

  ComicEntity({
    this.id,
    required this.title,
    required this.filePath,
    this.picture = '',
    this.currentPage = 0,
    required this.totalPages,
    required this.lastOpened,
    required this.currentReading,
  });
}
