import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/services/cameraService.dart';
import 'package:open_museum_guide/services/detectionService.dart';
import 'package:open_museum_guide/services/downloadService.dart';
import 'package:open_museum_guide/services/locationService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/services/paintingService.dart';
import 'package:open_museum_guide/services/textToSpeechService.dart';
import 'package:tflite/tflite.dart';

class LoadingService {
  LoadingService();

  final TextToSpeechService textToSpeechService =
      getIt.get<TextToSpeechService>();
  final PaintingService paintingService = getIt.get<PaintingService>();
  final MuseumService museumService = getIt.get<MuseumService>();
  final CameraService cameraService = getIt.get<CameraService>();
  final DetectionService detectionService = getIt.get<DetectionService>();
  final LocationService locationService = getIt.get<LocationService>();
  final DownloadService downloadService = getIt.get<DownloadService>();
  final DatabaseHelper dbLocal = getIt.get<DatabaseHelper>();

  Future<void> loadData() async {
    await loadModel();
    await cameraService.loadCameras();
    await textToSpeechService.loadTTS();

    await museumService.loadMuseums();
    await downloadService.loadMuseumStates();
    // String currentMuseumId = "GWNdYOmSpgjkLxnLSroV";
    await locationService.detectAndChangeActiveMuseum();
  }

  Future<String> loadModel() async {
    return Tflite.loadModel(
        model: "assets/graph/paintings.tflite",
        labels: "assets/graph/paintings.txt");
  }
}
