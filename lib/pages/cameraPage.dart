import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/paintingCard.dart';
import 'package:open_museum_guide/components/roundIconButton.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/services/cameraService.dart';
import 'package:open_museum_guide/services/detectionService.dart';
import 'package:open_museum_guide/services/paintingService.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final PaintingService paintingService = getIt.get<PaintingService>();
  final CameraService cameraService = getIt.get<CameraService>();
  final DetectionService detectionService = getIt.get<DetectionService>();

  CameraController controller;
  CameraImage currentImage;
  String detectedId;
  Painting painting;
  bool paused = false;

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(cameraService.cameras[0], ResolutionPreset.high);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      await controller.initialize();
      if (!mounted) {
        return;
      }
      setState(() {});

      startDetection();
    } catch (e) {
      print("Permisions denied or initialization failed.");
      Navigator.pop(context);
    }
  }

  void startDetection() async {
    if (!mounted || paused || currentImage != null) {
      return;
    }
    controller.startImageStream((image) {
      if (currentImage == null) {
        currentImage = image;
        controller.stopImageStream();
        detectOnImage();
      }
    });
  }

  Future<void> detectOnImage() async {
    print('${currentImage.width} x ${currentImage.height}');
    if (!mounted) return;
    String id = await detectionService.recognizePaintingStream(currentImage);
    if (id != null && detectedId != id) {
      Painting p = await paintingService.loadPainting(id);
      if (!mounted) return;
      setState(() {
        detectedId = id;
        painting = p;
      });
    }
    currentImage = null;
    startDetection();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void beforeNavigate() {
    paused = true;
  }

  void afterNavigate() {
    paused = false;
    startDetection();
  }

  void goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              CameraPreview(controller),
              Container(
                margin: EdgeInsets.fromLTRB(5, 30, 0, 0),
                child: RoundIconButton(
                  iconSize: 32,
                  icon: Icons.arrow_back,
                  onPressed: goBack,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: PaintingCard(
                    painting: painting,
                    beforeNavigate: beforeNavigate,
                    afterNavigate: afterNavigate),
              )
            ],
          ),
        ));
  }
}
