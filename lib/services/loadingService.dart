import 'package:flutter/services.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:tflite/tflite.dart';

class LoadingService {
  LoadingService._privateConstructor();
  static final LoadingService instance = LoadingService._privateConstructor();

  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  String museumId = "GWNdYOmSpgjkLxnLSroV";

  Future<void> loadMuseumData() async {
    List data = await dbLocal.getPaintingsDataByMuseum(museumId);
    await platform.invokeMethod("loadPaintingsData", {"data": data});
  }

  Future<String> loadModel() async {
    return Tflite.loadModel(
        model: "assets/graph/paintings.tflite",
        labels: "assets/graph/paintings.txt");
  }
}
