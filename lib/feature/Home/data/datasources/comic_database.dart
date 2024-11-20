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
        ${ComicFields.currentReading} ${ComicFields.intType}
      )
    ''');
  }

  Future<void> addComic(ComicModel comic) async {
    final db = await database;
    await db.insert('comics', comic.toMap());
  }

  Future<List<ComicModel>> fetchAllComics() async {
    final db = await database;
    final maps = await db.query('comics');
    return List.generate(maps.length, (i) => ComicModel.fromMap(maps[i]));
  }
}
