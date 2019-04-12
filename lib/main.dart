// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_museum_guide/pages/homePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    Firestore.instance.settings(persistenceEnabled: false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepOrange, fontFamily: 'Lato'),
      home: HomePage(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   static const platform =
//   const MethodChannel('demo.openmuseumguide.com/opencv');

//   Image _proc;

//   Future _getImage() async {
//     var image = await ImagePicker.pickImage(source: ImageSource.gallery);

//     String path = image.path;
//     var resultBitmap = await platform.invokeMethod("runEdgeDetectionOnImage", {"path": path});
//     var newimg = Image.memory(resultBitmap);

//     setState(() {
//       _proc = newimg;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('OpenCV Test'),
//       ),
//       body: Center(
//         child: _proc == null ? Text('No image selected.') : _proc,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _getImage,
//         tooltip: 'Pick Image',
//         child: Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }
