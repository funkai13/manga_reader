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

  Future<int> addComic(ComicModel comic) async {
    final db = await database;

    int id = await db.insert('comics', comic.toMap());
    final result = await db.query('comics');
    print(result); // Aquí puedes ver si el id se generó correctamente

    return id;
  }

  Future<List<ComicModel>> fetchAllComics() async {
    final db = await database;
    final maps = await db.query('comics');
    return List.generate(maps.length, (i) => ComicModel.fromMap(maps[i]));
  }

  Future<void> updateBookmark(int id, int currentPage) async {
    final db = await database;

    await db.update(
      'comics',
      {'currentPage': currentPage}, // Solo actualiza currentPage
      where: 'id = ?',
      whereArgs: [id], // Parámetro seguro para evitar inyección SQL
    );

    // Verificar si la actualización fue exitosa
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
}
