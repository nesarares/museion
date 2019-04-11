import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_museum_guide/services/detectionService.dart';
import 'package:open_museum_guide/utils/roundIconButton.dart';
import 'package:after_layout/after_layout.dart';

class ImagePage extends StatefulWidget {
  final File image;

  ImagePage({Key key, this.image}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage>
    with AfterLayoutMixin<ImagePage> {
  static final DetectionService detectionService = DetectionService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    runDetection();
  }

  Future<void> runDetection() async {
    var detections = await detectionService.detectObject(widget.image);
    print(detections);
  }

  void goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: FileImage(widget.image), fit: BoxFit.cover)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: new BoxDecoration(color: Colors.white.withOpacity(0.2)),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Image.file(widget.image),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(5, 30, 0, 0),
                  child: RoundIconButton(
                    iconSize: 32,
                    icon: Icons.arrow_back,
                    onPressed: goBack,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
