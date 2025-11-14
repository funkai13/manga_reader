import 'package:manga_reader/feature/Home/data/models/comic_fields.dart';
import 'package:sqflite/sqflite.dart';

import '../models/comic_model.dart';

class ComicDatabase {
  static final ComicDatabase instance = ComicDatabase._init();
  static Database? _database;

  ComicDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase('comics.db');
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$filePath';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future _createDatabase(Database db, int version) async {
    await db.execute('''
        CREATE TABLE ${ComicFields.tableName} (
          ${ComicFields.id} ${ComicFields.idType},
          ${ComicFields.filePath} ${ComicFields.textType},
          ${ComicFields.title} ${ComicFields.textType},
          ${ComicFields.picture} TEXT,
          ${ComicFields.currentPage} ${ComicFields.intType},
          ${ComicFields.totalPages} ${ComicFields.intType},
          ${ComicFields.lastOpened} ${ComicFields.intType},
          ${ComicFields.currentReading} ${ComicFields.intType},
          ${ComicFields.bookMarks} ${ComicFields.textType},
          ${ComicFields.isFavorite} ${ComicFields.intType},
          ${ComicFields.imagesPath} ${ComicFields.textType},
          ${ComicFields.rating} ${ComicFields.intType},
          ${ComicFields.isReading} ${ComicFields.textType},
          ${ComicFields.isCompleted} ${ComicFields.textType}
        )
      ''');
  }

  Future<int> addComic(ComicModel comic) async {
    final db = await database;
    int id = await db.insert('comics', comic.toMap());
    final result = await db.query('comics');
    return id;
  }

  Future<List<ComicModel>> fetchAllComics() async {
    final db = await database;
    final maps = await db.query(ComicFields.tableName);
    return List.generate(maps.length, (i) => ComicModel.fromMap(maps[i]));
  }

  Future<void> updateBookmark(int id, int currentPage) async {
    final db = await database;

    await db.update(
      'comics',
      {'currentPage': currentPage},
      where: 'id = ?',
      whereArgs: [id],
    );

    final result = await db.query(
      'comics',
      columns: ['id', 'currentPage'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      print(
          "Comic ID: ${result.first['id']} - Current Page actualizado: ${result.first['currentPage']}");
    } else {
      print("No se encontró el cómic con ID: $id");
    }
  }

  Future<void> updateComic({
    required int id,
    String? imagesPath,
    String? picture,
    String? filePath,
    String? title,
    int? totalPages,
  }) async {
    final db = await database;
    final Map<String, Object?> values = {};
    if (imagesPath != null) values[ComicFields.imagesPath] = imagesPath;
    if (filePath != null) values[ComicFields.filePath] = filePath;
    if (title != null) values[ComicFields.title] = title;
    if (picture != null) values[ComicFields.picture] = picture;
    if (totalPages != null) values[ComicFields.totalPages] = totalPages;
    if (values.isNotEmpty) {
      await db.update(
        ComicFields.tableName,
        values,
        where: '${ComicFields.id} = ?',
        whereArgs: [id],
      );
    }
  }
}
