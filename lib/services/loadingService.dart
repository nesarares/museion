import 'package:flutter/services.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tflite/tflite.dart';

class LoadingService {
  LoadingService._privateConstructor();
  static final LoadingService instance = LoadingService._privateConstructor();

  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  String museumId = "GWNdYOmSpgjkLxnLSroV"; // orsay
  // String museumId = "4bGQk6lrv9cyu0y7l4FZ"; // test

  BehaviorSubject _dataLoadedSubject = BehaviorSubject.seeded(false);

  Observable get isDataLoaded$ => _dataLoadedSubject.stream;
  Observable get isDataLoaded => _dataLoadedSubject.value;

  Future<void> loadMuseumData() async {
    List data = await dbLocal.getPaintingsDataByMuseum(museumId);
    if (data.length == 0) {
      _dataLoadedSubject.add(false);
    } else {
      await platform.invokeMethod("loadPaintingsData", {"data": data});
      _dataLoadedSubject.add(true);
    }
  }

  Future<void> unloadMuseumData() async {
    await platform.invokeMethod("unloadPaintingsData");
    _dataLoadedSubject.add(false);
  }

  Future<String> loadModel() async {
    return Tflite.loadModel(
        model: "assets/graph/paintings.tflite",
        labels: "assets/graph/paintings.txt");
  }
}
