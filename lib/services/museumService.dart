import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:rxdart/rxdart.dart';

class MuseumService {
  MuseumService._privateConstructor();
  static final MuseumService instance = MuseumService._privateConstructor();

  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  static final LoadingService loadingService = LoadingService.instance;

  BehaviorSubject<List<Museum>> _museumsSubject =
      BehaviorSubject.seeded(List());
  Observable<List<Museum>> get museums$ => _museumsSubject.stream;

  List<Museum> get museums => _museumsSubject.value;

  BehaviorSubject<Museum> _activeMuseumSubject = BehaviorSubject.seeded(null);
  Observable<Museum> get activeMuseum$ => _activeMuseumSubject.stream;
  Museum get activeMuseum => _activeMuseumSubject.value;

  Future<void> loadMuseums() async {
    if (museums != null && museums.length > 0) return;
    List<Museum> data = await dbLocal.getMuseums();
    if (data.length == 0) {
      await downloadMuseums();
    } else {
      _museumsSubject.add(data);
    }
  }

  Future<void> changeActiveMuseum(String id) async {
    if (id == null) return;
    Museum museum = await dbLocal.getMuseumById(id);
    if (museum != null) {
      _activeMuseumSubject.add(museum);
    }
    loadingService.loadMuseumData();
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
