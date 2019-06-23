import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

enum DownloadState {
  DOWNLOADING_DETAILS,
  DOWNLOADING_IMAGES,
  GENERATING_DATA,
  DOWNLOADED,
  NOT_DOWNLOADED,
  DELETING
}

class DownloadException implements Exception {
  String message;
  DownloadException(this.message);
}

class DownloadService {
  DownloadService();

  final DatabaseHelper dbLocal = getIt.get<DatabaseHelper>();
  final MuseumService museumService = getIt.get<MuseumService>();

  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  String downloadTaskId = '';

  BehaviorSubject<Map<String, DownloadState>> _museumStatesSubject =
      BehaviorSubject.seeded(null);
  Observable<Map<String, DownloadState>> get museumStates$ =>
      _museumStatesSubject.stream;
  Map<String, DownloadState> get museumStates => _museumStatesSubject.value;

  bool busy = false;

  Future<void> loadMuseumStates() async {
    var museumPaintingCounts = await dbLocal.countPaintingsByMuseum();
    var museumPaintingDataCounts = await dbLocal.countPaintingsDataByMuseum();

    List<Map<String, dynamic>> data = museumService.museums.map((museum) {
      var state = DownloadState.NOT_DOWNLOADED;
      if ((museumPaintingCounts[museum.id] ?? -1) > 0 &&
          museumPaintingCounts[museum.id] ==
              museumPaintingDataCounts[museum.id]) {
        state = DownloadState.DOWNLOADED;
      }
      return {"id": museum.id, "state": state};
    }).toList();

    Map<String, DownloadState> states = Map.fromIterable(
      data,
      key: (m) => m['id'],
      value: (m) => m['state'],
    );

    _museumStatesSubject.add(states);
  }

  Future<void> notifyChanges(
    String museumId,
    DownloadState downloadState,
  ) async {
    var states = museumStates;
    states[museumId] = downloadState;
    _museumStatesSubject.add(states);
  }

  Future<void> deleteData(String museumId) async {
    if (busy)
      throw DownloadException("Please wait for other operations to finish.");

    try {
      busy = true;
      notifyChanges(museumId, DownloadState.DELETING);

      String savedDirPath = (await getApplicationDocumentsDirectory()).path;
      String savePath = '$savedDirPath/$museumId';
      Directory saveDir = Directory(savePath);
      if (saveDir.existsSync()) saveDir.deleteSync(recursive: true);
      await dbLocal.deletePaintingsByMuseum(museumId);

      await Future.delayed(const Duration(milliseconds: 400), () async {
        await museumService.unloadMuseumData(museumId);
        notifyChanges(museumId, DownloadState.NOT_DOWNLOADED);
      });
    } finally {
      busy = false;
    }
  }

  Future<void> downloadData(String museumId) async {
    if (busy)
      throw DownloadException("Please wait for other downloads to finish.");

    try {
      busy = true;
      await downloadDetails(museumId);
      var archiveBytes = await downloadImages(museumId);
      await extractArchive(museumId, archiveBytes);
      await generateData(museumId);
    } finally {
      busy = false;
    }
  }

  Future<void> downloadDetails(String museumId) async {
    await notifyChanges(museumId, DownloadState.DOWNLOADING_DETAILS);

    try {
      QuerySnapshot docs = await db
          .collection('museums')
          .document(museumId)
          .collection('paintings')
          .getDocuments();
      List<Map<String, dynamic>> paintings = docs.documents.map((doc) {
        var map = doc.data;
        map[Painting.columnMuseum] = museumId;
        return map;
      }).toList();

      await dbLocal.insertPaintingsMap(paintings);
    } catch (ex) {
      throw DownloadException(
          "Could not download details for museum $museumId");
    }
  }

  Future<Uint8List> downloadImages(String museumId) async {
    notifyChanges(museumId, DownloadState.DOWNLOADING_IMAGES);

    try {
      String downloadUrl =
          await storage.ref().child('$museumId.zip').getDownloadURL();
      var response = await http.get(Uri.parse(downloadUrl));
      return response.bodyBytes;
    } catch (err) {
      throw DownloadException("Could not download images for museum $museumId");
    }
  }

  Future<void> extractArchive(String museumId, Uint8List archiveBytes) async {
    String savedDirPath = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$savedDirPath/$museumId';

    // Decode the Zip file
    Archive archive = new ZipDecoder().decodeBytes(archiveBytes);

    // Extract the contents of the Zip archive to disk.
    for (ArchiveFile file in archive) {
      String filename = file.name;
      if (file.isFile) {
        List<int> data = file.content;
        try {
          var file = new File('$savePath/$filename');
          await file.create(recursive: true);
          await file.writeAsBytes(data);
        } catch (ex) {
          print("cannot write file");
          print(ex);
        }
      } else {
        new Directory(filename)..create(recursive: true);
      }
    }
  }

  Future<void> generateData(String museumId) async {
    notifyChanges(museumId, DownloadState.GENERATING_DATA);

    var paintings = await dbLocal.getPaintingsWithColumnsByMuseum(
        [Painting.columnId, Painting.columnImagePath], museumId);

    var paintingsData = (await platform.invokeMethod<List<dynamic>>(
            "generateImageData", {"paintings": paintings}))
        .map((p) => Map<String, String>.from(p))
        .toList();

    await dbLocal.insertPaintingsDataMap(paintingsData);
    if (museumId == museumService.activeMuseum?.id ?? null) {
      await museumService.loadMuseumData();
    }

    await notifyChanges(museumId, DownloadState.DOWNLOADED);
  }
}
