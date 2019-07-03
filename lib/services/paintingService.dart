import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class PaintingService {
  PaintingService();

  final DatabaseHelper dbLocal = getIt.get<DatabaseHelper>();

  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  BehaviorSubject<List<Painting>> historyPaintingsSubject =
      BehaviorSubject.seeded(List());
  Observable<List<Painting>> get historyPaintings$ =>
      historyPaintingsSubject.stream;
  List<Painting> get historyPaintings => historyPaintingsSubject.value;

  Future<void> addPaintingToHistory(Painting painting) async {
    int lastViewed = DateTime.now().toUtc().millisecondsSinceEpoch;
    try {
      await dbLocal.updatePaintingLastViewedById(painting.id, lastViewed);
      await loadHistoryPaintings();
    } catch (error) {
      print('Could not add painting to history: $error');
    }
  }

  Future<void> loadHistoryPaintings() async {
    String savedDirPath = (await getApplicationDocumentsDirectory()).path;
    List<Painting> lst = await dbLocal.getPaintingsViewed();
    lst = lst.map((p) {
      p.imagePath = "$savedDirPath/${p.imagePath}";
      return p;
    }).toList();
    historyPaintingsSubject.add(lst);
  }

  Future<Painting> loadPainting(String id) async {
    Painting p = await dbLocal.getPaintingById(id);
    String savedDirPath = (await getApplicationDocumentsDirectory()).path;
    p.imagePath = "$savedDirPath/${p.imagePath}";
    return p;
  }

  Future<void> removePaintingFromHistory(String id) async {
    await dbLocal.removePaintingLastViewedById(id);
    var newPaintings =
        historyPaintings.where((painting) => painting.id != id).toList();
    historyPaintingsSubject.add(newPaintings);
  }

  Future<void> removeAllPaintingsFromHistory() async {
    await dbLocal.removePaintingsLastViewed();
    historyPaintingsSubject.add([]);
  }
}
