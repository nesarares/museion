import 'package:flutter/services.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';

class PaintingDataService {
  PaintingDataService._privateConstructor();
  static final PaintingDataService instance =
      PaintingDataService._privateConstructor();

  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  String museumId = "4bGQk6lrv9cyu0y7l4FZ";

  Future<void> loadMuseumData() async {
    List data = await dbLocal.getPaintingsDataByMuseum(museumId);
    await platform.invokeMethod("loadPaintingsData", {"data": data});
  }
}
