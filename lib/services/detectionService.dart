import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;

class DetectionService {
  DetectionService._privateConstructor();
  static final DetectionService instance =
      DetectionService._privateConstructor();

  Stopwatch stopwatch = new Stopwatch();
  static const int DETECT_MAX_SIZE = 720;
  static final DatabaseHelper dbLocal = DatabaseHelper.instance;
  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

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
    // img.Image newImage = await _imageFromFile(image);
    // int width = -1;
    // int height = -1;
    // if (newImage.width > newImage.height) {
    //   width = DETECT_MAX_SIZE;
    // } else {
    //   height = DETECT_MAX_SIZE;
    // }
    // newImage = img.copyResize(newImage, width, height);

    // Uint8List binary = imageToByteListFloat32(newImage, 224, 127.5, 127.5);

    // List<dynamic> recognitions = await Tflite.detectObjectOnBinary(
    //     binary: binary, numResultsPerClass: 1, asynch: true);
    List<dynamic> recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 1, asynch: true);

    return recognitions;
  }

  Future<String> recognizePaintingFile(File image) async {
    // Detect painting in picture
    stopwatch.reset();
    stopwatch.start();

    List<dynamic> detections = await _detectObjectFile(image);
    if (detections.length == 0) {
      stopwatch.stop();
      return null; // no painting detected
    }

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

  Future<List<dynamic>> _detectObjectFrame(
      List<Uint8List> bytesList, width, height) async {
    List<dynamic> recognitions = await Tflite.detectObjectOnFrame(
        bytesList: bytesList,
        numResultsPerClass: 1,
        imageHeight: height,
        imageWidth: width,
        asynch: true);

    return recognitions;
  }

  Future<String> recognizePaintingStream(CameraImage image) async {
    // Detect painting in picture
    stopwatch.reset();
    stopwatch.start();

    var bytesList = image.planes.map((plane) {
      return plane.bytes;
    }).toList();

    List<dynamic> detections =
        await _detectObjectFrame(bytesList, image.width, image.height);
    if (detections.length == 0) {
      print("No paintings detected");
      stopwatch.stop();
      return null; // no painting detected
    }
    print(detections);

    Map<dynamic, dynamic> detection = detections[0];
    int x = ((detection["rect"]["x"] as double) * image.width).round();
    int y = ((detection["rect"]["y"] as double) * image.height).round();
    int w = ((detection["rect"]["w"] as double) * image.width).round();
    int h = ((detection["rect"]["h"] as double) * image.height).round();

    print(
        'width: ${image.width}, height: ${image.height}, x: $x, y: $y, w: $w, h: $h');

    String id = await platform.invokeMethod<String>("detectPaintingFrame", {
      "bytes": bytesList,
      "width": image.width,
      "height": image.height,
      "x": x,
      "y": y,
      "w": w,
      "h": h
    });
    print(id);

    stopwatch.stop();
    print("Recognition took: ${stopwatch.elapsedMilliseconds} ms.");

    return id;
  }
}
