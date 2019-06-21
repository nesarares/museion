import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:path_provider/path_provider.dart';

class PaintingService {
  PaintingService();

  final DatabaseHelper dbLocal = getIt.get<DatabaseHelper>();

  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> addPaintingToHistory(Painting painting) async {
    int lastViewed = DateTime.now().toUtc().millisecondsSinceEpoch;
    try {
      await dbLocal.updatePaintingLastViewedById(painting.id, lastViewed);
    } catch (error) {
      print('Could not add painting to history: $error');
    }
  }

  Future<Painting> loadPainting(String id) async {
    Painting p = await dbLocal.getPaintingById(id);
    String savedDirPath = (await getApplicationDocumentsDirectory()).path;
    p.imagePath = "$savedDirPath/${p.imagePath}";
    return p;
  }
}
