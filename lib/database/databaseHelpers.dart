import 'dart:io';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/models/paintingData.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "OpenMuseumGuideDB.db";
  static final _databaseVersion = 1;

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

    await db.execute('''
              CREATE TABLE ${PaintingData.tableName} (
                ${PaintingData.columnId} TEXT PRIMARY KEY,
                ${PaintingData.columnPhash} TEXT NOT NULL,
                ${PaintingData.columnDescriptors} TEXT NOT NULL,
                CONSTRAINT fk_id
                  FOREIGN KEY(${PaintingData.columnId}) 
                  REFERENCES ${Painting.tableName}(${Painting.columnId})
                  ON DELETE CASCADE
              )
              ''');
  }

  // Database helper methods:

  Future<void> insertPaintingsMap(List<Map<String, dynamic>> paintings) async {
    Database db = await database;
    var batch = db.batch();
    paintings.forEach((painting) {
      batch.insert(Painting.tableName, painting,
          conflictAlgorithm: ConflictAlgorithm.replace);
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

  Future<PaintingData> getPaintingDataById(String id) async {
    Database db = await database;
    List<Map> maps = await db.query(PaintingData.tableName,
        where: '${PaintingData.columnId} = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return PaintingData.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPaintingsWithColumnsByMuseum(
      List<String> columns, String museumId) async {
    Database db = await database;
    return (await db.query(Painting.tableName,
        columns: columns,
        where: '${Painting.columnMuseum} = ?',
        whereArgs: [museumId]));
  }

  Future<List<Map<String, dynamic>>> getPaintingsDataByMuseum(
      String museumId) async {
    Database db = await database;
    return db.rawQuery('''
      SELECT pd.${PaintingData.columnId}, pd.${PaintingData.columnPhash}, 
             pd.${PaintingData.columnDescriptors}
      FROM ${Painting.tableName} p INNER JOIN ${PaintingData.tableName} pd
        ON p.${Painting.columnId} = pd.${PaintingData.columnId}
      WHERE ${Painting.columnMuseum} = ?
    ''', [museumId]);
  }

  Future<int> countPaintingsByMuseum(String museumId) async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) 
      FROM ${Painting.tableName}
      WHERE ${Painting.columnMuseum} = ?
      ''', [museumId]));
  }

  Future<int> removeAllRecords() async {
    Database db = await database;
    return db.delete(Painting.tableName);
  }

  Future<int> deletePaintingsByMuseum(String museumId) async {
    Database db = await database;
    return db.delete(Painting.tableName,
        where: '${Painting.columnMuseum} = ?', whereArgs: [museumId]);
  }

  Future<void> insertPaintingsDataMap(
      List<Map<String, dynamic>> paintingsData) async {
    Database db = await database;
    var batch = db.batch();
    paintingsData.forEach((data) {
      batch.insert(PaintingData.tableName, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }

  Future<int> countPaintingsDataByMuseum(String museumId) async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) 
      FROM ${Painting.tableName} INNER JOIN ${PaintingData.tableName} 
      ON ${Painting.tableName}.${Painting.columnId} = ${PaintingData.tableName}.${PaintingData.columnId}
      WHERE ${Painting.tableName}.${Painting.columnMuseum} = ?
      ''', [museumId]));
  }
}
