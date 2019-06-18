import 'package:flutter/services.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/services/cameraService.dart';
import 'package:open_museum_guide/services/detectionService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/services/paintingService.dart';
import 'package:open_museum_guide/services/textToSpeechService.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tflite/tflite.dart';

class LoadingService {
  LoadingService._privateConstructor();
  static final LoadingService instance = LoadingService._privateConstructor();

  static final TextToSpeechService textToSpeechService =
      TextToSpeechService.instance;
  static final PaintingService paintingService = PaintingService.instance;
  static final MuseumService museumService = MuseumService.instance;
  static final CameraService cameraService = CameraService.instance;
  static final DetectionService detectionService = DetectionService.instance;
  final DatabaseHelper dbLocal = DatabaseHelper.instance;

  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  BehaviorSubject<bool> _dataLoadedSubject = BehaviorSubject.seeded(false);

  Observable<bool> get isDataLoaded$ => _dataLoadedSubject.stream;
  bool get isDataLoaded => _dataLoadedSubject.value;

  Future<void> loadData() async {
    await loadModel();
    await cameraService.loadCameras();
    await textToSpeechService.loadTTS();

    await museumService.loadMuseums();
    await museumService.loadActiveMuseum();
    await loadMuseumData();
  }

  Future<void> loadMuseumData() async {
    if (museumService.museumId == null) {
      _dataLoadedSubject.add(false);
      return;
    }
    List data = await dbLocal.getPaintingsDataByMuseum(museumService.museumId);
    if (data.length == 0) {
      _dataLoadedSubject.add(false);
    } else {
      await platform.invokeMethod("loadPaintingsData", {"data": data});
      _dataLoadedSubject.add(true);
    }
  }

  Future<void> unloadMuseumData(String id) async {
    // await platform.invokeMethod("unloadPaintingsData");
    if (museumService.activeMuseum.id == id) {
      _dataLoadedSubject.add(false);
    }
  }

  Future<String> loadModel() async {
    return Tflite.loadModel(
        model: "assets/graph/paintings.tflite",
        labels: "assets/graph/paintings.txt");
  }
}
