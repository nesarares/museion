import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:rxdart/rxdart.dart';

class MuseumService {
  MuseumService._privateConstructor();
  static final MuseumService instance = MuseumService._privateConstructor();

  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  BehaviorSubject<List<Museum>> _museumsSubject =
      BehaviorSubject.seeded(List());
  Observable<List<Museum>> get museums$ {
    loadMuseums();
    return _museumsSubject.stream;
  }

  List<Museum> get museums => _museumsSubject.value;

  BehaviorSubject<Museum> _activeMuseumSubject = BehaviorSubject.seeded(null);
  Observable<Museum> get activeMuseum$ {
    loadActiveMuseum();
    return _activeMuseumSubject.stream;
  }

  String get museumId => "GWNdYOmSpgjkLxnLSroV"; // orsay
  // String get museumId => "4bGQk6lrv9cyu0y7l4FZ"; // test

  Museum get activeMuseum => _activeMuseumSubject.value;

  Future<void> loadMuseums() async {
    if (museums != null && museums.length > 0) return;
    List<Museum> data = await dbLocal.getMuseumsSummary();
    if (data.length == 0) {
      await downloadMuseums();
    } else {
      _museumsSubject.add(data);
    }
  }

  Future<void> loadActiveMuseum() async {
    if (activeMuseum != null) return;
    Museum museum = await dbLocal.getMuseumById(museumId);
    if (museum != null) {
      _activeMuseumSubject.add(museum);
    }
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
              Museum.columnImageUrl: m.imageUrl
            }))
        .toList();

    _museumsSubject.add(museums);
  }
}
