import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_museum_guide/tabsPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Varela Round'
      ),
      home: TabsPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform =
  const MethodChannel('demo.openmuseumguide.com/opencv');

  Image _proc;

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String path = image.path;
    var resultBitmap = await platform.invokeMethod("runEdgeDetectionOnImage", {"path": path});
    var newimg = Image.memory(resultBitmap);

    setState(() {
      _proc = newimg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenCV Test'),
      ),
      body: Center(
        child: _proc == null ? Text('No image selected.') : _proc,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
