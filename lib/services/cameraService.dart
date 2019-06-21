import 'package:flutter/services.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/detectionService.dart';
import 'package:camera/camera.dart';

class CameraService {
  CameraService();

  final DetectionService detectionService = getIt.get<DetectionService>();
  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  List<CameraDescription> cameras;

  Future<void> loadCameras() async {
    cameras = await availableCameras();
  }
}
