import 'dart:io';
import 'package:open_museum_guide/models/painting.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "OpenMuseumGuideDB.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE ${Painting.tableName} (
                ${Painting.columnId} TEXT PRIMARY KEY,
                ${Painting.columnArtist} TEXT NOT NULL,
                ${Painting.columnTitle} TEXT NOT NULL,
                ${Painting.columnMuseum} TEXT NOT NULL,
                ${Painting.columnImagePath} TEXT NOT NULL,
                ${Painting.columnText} TEXT,
                ${Painting.columnYear} TEXT,
                ${Painting.columnCopyright} TEXT,
                ${Painting.columnMedium} TEXT,
                ${Painting.columnDimensions} TEXT
              )
              ''');
  }

  // Database helper methods:

  Future<int> insertPainting(Painting painting) async {
    Database db = await database;
    int id = await db.insert(Painting.tableName, painting.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<int> insertPaintingMap(Map<String, dynamic> painting) async {
    Database db = await database;
    int id = await db.insert(Painting.tableName, painting,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<void> insertPaintingsMap(List<Map<String, dynamic>> paintings) async {
    Database db = await database;
    var batch = db.batch();
    paintings.forEach((painting) {
      batch.insert(Painting.tableName, painting, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }

  Future<Painting> getPaintingById(String id) async {
    Database db = await database;
    List<Map> maps = await db.query(Painting.tableName,
        where: '${Painting.columnId} = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Painting.fromMap(maps.first);
    }
    return null;
  }

  Future<int> countPaintingsByMuseum(String museumId) async {
    Database db = await database;
    int count = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) 
      FROM ${Painting.tableName}
      WHERE ${Painting.columnMuseum} = ?
      ''', [museumId]));
    return count;
  }

  Future<int> removeAllRecords() async {
    Database db = await database;
    return db.delete(Painting.tableName);
  }

  // TODO: queryAllWords()
  // TODO: delete(int id)
  // TODO: update(Word word)
}
