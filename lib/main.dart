import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_museum_guide/pages/homePage.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:open_museum_guide/services/cameraService.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/services/detectionService.dart';
import 'package:open_museum_guide/services/downloadService.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:open_museum_guide/services/locationService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/services/paintingService.dart';
import 'package:open_museum_guide/services/textToSpeechService.dart';

GetIt getIt = new GetIt();

void main() {
  initializeServices();
  runApp(MyApp());
}

void initializeServices() {
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());
  getIt.registerSingleton<TextToSpeechService>(TextToSpeechService());
  getIt.registerSingleton<PaintingService>(PaintingService());
  getIt.registerSingleton<DetectionService>(DetectionService());
  getIt.registerSingleton<CameraService>(CameraService());
  getIt.registerSingleton<MuseumService>(MuseumService());
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<DownloadService>(DownloadService());
  getIt.registerSingleton<LoadingService>(LoadingService());
}

class MyApp extends StatelessWidget {
  MyApp() {
    Firestore.instance.settings(persistenceEnabled: false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Museion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Lato',
        appBarTheme: AppBarTheme(
          elevation: 0,
          color: Colors.transparent,
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.black,
              fontFamily: 'Rufina',
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
