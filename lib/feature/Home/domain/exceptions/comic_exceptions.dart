class UnsupportedComicException implements Exception {
  final String message;

  UnsupportedComicException([this.message = '']);

  @override
  String toString() => 'UnsupportedComicException: $message';
}
