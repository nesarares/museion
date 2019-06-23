import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:rxdart/rxdart.dart';

class MuseumService {
  MuseumService();

  final DatabaseHelper dbLocal = getIt.get<DatabaseHelper>();

  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  BehaviorSubject<List<Museum>> _museumsSubject =
      BehaviorSubject.seeded(List());
  Observable<List<Museum>> get museums$ => _museumsSubject.stream;
  List<Museum> get museums => _museumsSubject.value;

  BehaviorSubject<Museum> _activeMuseumSubject = BehaviorSubject.seeded(null);
  Observable<Museum> get activeMuseum$ => _activeMuseumSubject.stream;
  Museum get activeMuseum => _activeMuseumSubject.value;

  BehaviorSubject<bool> _dataLoadedSubject = BehaviorSubject.seeded(false);
  Observable<bool> get isDataLoaded$ => _dataLoadedSubject.stream;
  bool get isDataLoaded => _dataLoadedSubject.value;

  Future<void> loadMuseums() async {
    if (museums != null && museums.length > 0) return;
    List<Museum> data = await dbLocal.getMuseums();
    if (data.length == 0) {
      await downloadMuseums();
    } else {
      _museumsSubject.add(data);
    }
  }

  Future<void> loadMuseumData() async {
    if (activeMuseum == null) {
      _dataLoadedSubject.add(false);
      return;
    }
    List data = await dbLocal.getPaintingsDataByMuseum(activeMuseum.id);
    if (data.length == 0) {
      _dataLoadedSubject.add(false);
    } else {
      await platform.invokeMethod("loadPaintingsData", {"data": data});
      _dataLoadedSubject.add(true);
    }
  }

  Future<void> unloadMuseumData(String id) async {
    // await platform.invokeMethod("unloadPaintingsData");
    if (activeMuseum.id == id) {
      _dataLoadedSubject.add(false);
    }
  }

  Future<void> changeActiveMuseum(String id) async {
    if (id == null) return;
    Museum museum = await dbLocal.getMuseumById(id);
    if (museum != null) {
      _activeMuseumSubject.add(museum);
    }
    loadMuseumData();
  }

  Future<void> downloadMuseums() async {
    QuerySnapshot docs = await db.collection('museums').getDocuments();
    print(docs.documents.length);
    List<Museum> museums = docs.documents.map((snap) {
      var map = snap.data;
      Museum museum = Museum.fromMap(map);
      return museum;
    }).toList();
    await dbLocal.insertMuseums(museums);

    museums = museums
        .map((m) => Museum.fromMap({
              Museum.columnId: m.id,
              Museum.columnTitle: m.title,
              Museum.columnImageUrl: m.imageUrl,
              Museum.columnCity: m.city,
              Museum.columnCountry: m.country,
              Museum.columnCoordinates: m.coordinates
            }))
        .toList();

    _museumsSubject.add(museums);
  }
}
