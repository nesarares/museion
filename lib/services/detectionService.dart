import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:tflite/tflite.dart';

class DetectionService {
  DetectionService._privateConstructor();
  static final DetectionService instance =
      DetectionService._privateConstructor();

  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

  Future<dynamic> detectObject(File image) async {
    List<dynamic> recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      numResultsPerClass: 1,
    );

    return recognitions;
  }
}
