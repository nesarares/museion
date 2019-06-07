import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:open_museum_guide/models/painting.dart';

class PaintingService {
  PaintingService._privateConstructor();
  static final PaintingService instance = PaintingService._privateConstructor();

  final DatabaseHelper dbLocal = DatabaseHelper.instance;
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
}
