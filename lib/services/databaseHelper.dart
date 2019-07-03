import 'dart:io';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/models/paintingData.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "OpenMuseumGuideDB.db";
  static final _databaseVersion = 1;

  DatabaseHelper();

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
                ${Painting.columnWiki} TEXT,
                ${Painting.columnMedium} TEXT,
                ${Painting.columnDimensions} TEXT,
                ${Painting.columnLastViewed} INTEGER,
                CONSTRAINT fk_id
                  FOREIGN KEY(${Painting.columnMuseum}) 
                  REFERENCES ${Museum.tableName}(${Museum.columnId})
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

    await db.execute('''
              CREATE TABLE ${Museum.tableName} (
                ${Museum.columnId} TEXT PRIMARY KEY,
                ${Museum.columnTitle} TEXT NOT NULL,
                ${Museum.columnImageUrl} TEXT NOT NULL,
                ${Museum.columnAddress} TEXT,
                ${Museum.columnCity} TEXT,
                ${Museum.columnCoordinates} TEXT,
                ${Museum.columnCountry} TEXT,
                ${Museum.columnFacilities} TEXT,
                ${Museum.columnHours} TEXT,
                ${Museum.columnWebsite} TEXT
              )
              ''');
  }

  Future<int> removeAllRecords() async {
    Database db = await database;
    return db.delete(Painting.tableName);
  }

  // PAINTING

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
    // Database db = await database;
    // List<Map> maps = await db.query(Painting.tableName,
    //     where: '${Painting.columnId} = ?', whereArgs: [id]);
    // if (maps.length > 0) {
    //   return Painting.fromMap(maps.first);
    // }
    // return null;

    Database db = await database;
    List<Map<String, dynamic>> query = await db.rawQuery('''
      SELECT p.*, m.${Museum.columnTitle} as ${Painting.columnMuseum}
      FROM ${Painting.tableName} p INNER JOIN ${Museum.tableName} m
        ON p.${Painting.columnMuseum} = m.${Museum.columnId}
      WHERE p.${Painting.columnId} = ?
    ''', [id]);
    return query.map((m) => Painting.fromMap(m)).toList().first;
  }

  Future<int> updatePaintingLastViewedById(String id, int lastViewed) async {
    Database db = await database;
    // return (await db.update(Painting.tableName, paintingMap,
    //     where: '${Painting.columnId} = ?',
    //     whereArgs: [paintingMap[Painting.columnId]]));
    return (await db.rawUpdate('''
      UPDATE ${Painting.tableName} 
      SET ${Painting.columnLastViewed} = ? 
      WHERE ${Painting.columnId} = ?
      ''', [lastViewed, id]));
  }

  Future<int> removePaintingLastViewedById(String id) async {
    Database db = await database;
    return (await db.rawUpdate('''
      UPDATE ${Painting.tableName} 
      SET ${Painting.columnLastViewed} = NULL 
      WHERE ${Painting.columnId} = ?
      ''', [id]));
  }

  Future<int> removePaintingsLastViewed() async {
    Database db = await database;
    return (await db.rawUpdate(
      '''
      UPDATE ${Painting.tableName}
      SET ${Painting.columnLastViewed} = NULL
      ''',
    ));
  }

  Future<List<Map<String, dynamic>>> getPaintingsWithColumnsByMuseum(
      List<String> columns, String museumId) async {
    Database db = await database;
    return (await db.query(Painting.tableName,
        columns: columns,
        where: '${Painting.columnMuseum} = ?',
        whereArgs: [museumId]));
  }

  // Future<int> countPaintingsByMuseum(String museumId) async {
  //   Database db = await database;
  //   return Sqflite.firstIntValue(await db.rawQuery('''
  //     SELECT COUNT(*)
  //     FROM ${Painting.tableName}
  //     WHERE ${Painting.columnMuseum} = ?
  //     ''', [museumId]));
  // }

  Future<Map<String, int>> countPaintingsByMuseum() async {
    Database db = await database;

    List<Map<String, dynamic>> query = await db.rawQuery(
      '''
      SELECT ${Painting.columnMuseum}, COUNT(*) as count
      FROM ${Painting.tableName}
      GROUP BY ${Painting.columnMuseum}
      ''',
    );

    return Map.fromIterable(
      query,
      key: (item) => item[Painting.columnMuseum],
      value: (item) => item['count'],
    );
  }

  Future<int> deletePaintingsByMuseum(String museumId) async {
    Database db = await database;
    return db.delete(
      Painting.tableName,
      where: '${Painting.columnMuseum} = ?',
      whereArgs: [museumId],
    );
  }

  Future<List<Painting>> getPaintingsViewed() async {
    Database db = await database;
    List<Map<String, dynamic>> query = await db.rawQuery(
      '''
      SELECT p.*, m.${Museum.columnTitle} as ${Painting.columnMuseum}
      FROM ${Painting.tableName} p INNER JOIN ${Museum.tableName} m
        ON p.${Painting.columnMuseum} = m.${Museum.columnId}
      WHERE ${Painting.columnLastViewed} NOT NULL
      ORDER BY ${Painting.columnLastViewed} DESC
    ''',
    );
    return query.map((m) => Painting.fromMap(m)).toList();
  }

  // PAINTING DATA

  Future<PaintingData> getPaintingDataById(String id) async {
    Database db = await database;
    List<Map> maps = await db.query(
      PaintingData.tableName,
      where: '${PaintingData.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return PaintingData.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPaintingsDataByMuseum(
      String museumId) async {
    Database db = await database;
    return db.rawQuery(
      '''
      SELECT pd.${PaintingData.columnId}, pd.${PaintingData.columnPhash}, 
             pd.${PaintingData.columnDescriptors}
      FROM ${Painting.tableName} p INNER JOIN ${PaintingData.tableName} pd
        ON p.${Painting.columnId} = pd.${PaintingData.columnId}
      WHERE ${Painting.columnMuseum} = ?
    ''',
      [museumId],
    );
  }

  Future<void> insertPaintingsDataMap(
      List<Map<String, dynamic>> paintingsData) async {
    Database db = await database;
    var batch = db.batch();
    paintingsData.forEach((data) {
      batch.insert(
        PaintingData.tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }

  // Future<int> countPaintingsDataByMuseum(String museumId) async {
  //   Database db = await database;
  //   return Sqflite.firstIntValue(await db.rawQuery(
  //     '''
  //     SELECT COUNT(*)
  //     FROM ${Painting.tableName} INNER JOIN ${PaintingData.tableName}
  //     ON ${Painting.tableName}.${Painting.columnId} = ${PaintingData.tableName}.${PaintingData.columnId}
  //     WHERE ${Painting.tableName}.${Painting.columnMuseum} = ?
  //     ''',
  //     [museumId],
  //   ));
  // }

  Future<Map<String, int>> countPaintingsDataByMuseum() async {
    Database db = await database;

    List<Map<String, dynamic>> query = await db.rawQuery(
      '''
      SELECT ${Painting.columnMuseum}, COUNT(*) as count
      FROM ${Painting.tableName} INNER JOIN ${PaintingData.tableName} 
      ON ${Painting.tableName}.${Painting.columnId} = ${PaintingData.tableName}.${PaintingData.columnId}
      GROUP BY ${Painting.columnMuseum}
      ''',
    );

    return Map.fromIterable(
      query,
      key: (item) => item[Painting.columnMuseum],
      value: (item) => item['count'],
    );
  }

  // MUSEUM

  Future<void> insertMuseums(List<Museum> museums) async {
    Database db = await database;
    var batch = db.batch();
    museums.forEach((museum) {
      batch.insert(Museum.tableName, museum.toMap(coordinatesString: true),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }

  Future<List<Museum>> getMuseums() async {
    Database db = await database;
    var maps = await db.rawQuery('''
      SELECT ${Museum.columnId}, ${Museum.columnTitle}, ${Museum.columnImageUrl}, ${Museum.columnCity}, ${Museum.columnCountry}, ${Museum.columnCoordinates}
      FROM ${Museum.tableName}
      ORDER BY ${Museum.columnCountry} ASC, ${Museum.columnCity} ASC, ${Museum.columnTitle} ASC
    ''');
    return maps.map((m) => Museum.fromMap(m, coordinatesString: true)).toList();
  }

  Future<Museum> getMuseumById(String id) async {
    Database db = await database;
    List<Map> maps = await db.query(Museum.tableName,
        where: '${Museum.columnId} = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Museum.fromMap(maps.first, coordinatesString: true);
    }
    return null;
  }
}
