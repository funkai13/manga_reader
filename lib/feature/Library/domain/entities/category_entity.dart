class CategoryEntity {
  final String name;
  final int count;
  final String type; // 'author', 'genre', 'collection'

  CategoryEntity({
    required this.name,
    required this.count,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CategoryEntity &&
      other.name == name &&
      other.count == count &&
      other.type == type;
  }

  @override
  int get hashCode => name.hashCode ^ count.hashCode ^ type.hashCode;
}
