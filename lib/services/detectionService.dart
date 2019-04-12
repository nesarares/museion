import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;

class DetectionService {
  DetectionService._privateConstructor();
  static final DetectionService instance =
      DetectionService._privateConstructor();

  static final DatabaseHelper dbLocal = DatabaseHelper.instance;
  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  Uint8List _imageToByteListUint8(img.Image image) {
    int width = image.width;
    int height = image.height;
    var convertedBytes = Uint8List(1 * width * height * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var x = 0; x < height; x++) {
      for (var y = 0; y < width; y++) {
        var pixel = image.getPixel(y, x);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future<img.Image> _imageFromFile(File image) async {
    var bytes = await image.readAsBytes();
    return img.decodeImage(bytes);
  }

  Future<List<dynamic>> _detectObjectFile(File image) async {
    List<dynamic> recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      numResultsPerClass: 1,
    );

    return recognitions;
  }

  Future<String> recognizePaintingFile(File image) async {
    // Detect painting in picture
    List<dynamic> detections = await _detectObjectFile(image);
    if (detections.length == 0) return null; // no painting detected

    Stopwatch stopwatch = new Stopwatch();
    stopwatch.start();
    Map<dynamic, dynamic> detection = detections[0];

    img.Image imageObj = await _imageFromFile(image);
    int x = ((detection["rect"]["x"] as double) * imageObj.width).round();
    int y = ((detection["rect"]["y"] as double) * imageObj.height).round();
    int w = ((detection["rect"]["w"] as double) * imageObj.width).round();
    int h = ((detection["rect"]["h"] as double) * imageObj.height).round();
    img.Image croppedImage = img.copyCrop(imageObj, x, y, w, h);

    List bytes = _imageToByteListUint8(croppedImage);
    String id = await platform.invokeMethod<String>(
        "detectPainting", {"bytes": bytes, "width": w, "height": h});
    stopwatch.stop();

    print("Recognition took: ${stopwatch.elapsedMilliseconds} ms.");

    return id;
  }
}
