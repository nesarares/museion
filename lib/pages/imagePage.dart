import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/paintingCard.dart';
import 'package:open_museum_guide/components/roundIconButton.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/services/detectionService.dart';
import 'package:after_layout/after_layout.dart';
import 'package:open_museum_guide/services/paintingService.dart';

class ImagePage extends StatefulWidget {
  final File image;

  ImagePage({Key key, this.image}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage>
    with AfterLayoutMixin<ImagePage> {
  final PaintingService paintingService = getIt.get<PaintingService>();
  final DetectionService detectionService = getIt.get<DetectionService>();

  Painting painting;
  bool noDetection = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    runDetection();
    // loadPainting("PSMc10DTUJAHGZAHy9OP");
  }

  Future<void> runDetection() async {
    String id = await detectionService.recognizePaintingFile(widget.image);
    if (id != null) {
      loadPainting(id);
    } else {
      setState(() {
        noDetection = true;
      });
    }
  }

  Future<void> loadPainting(String id) async {
    Painting p = await paintingService.loadPainting(id);
    setState(() {
      painting = p;
    });
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
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: noDetection
                      ? Container(
                          margin: EdgeInsets.only(bottom: 40),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color.fromRGBO(225, 225, 225, 0.8),
                                  Color.fromRGBO(255, 255, 255, 0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset.fromDirection(math.pi / 2, 10),
                                ),
                              ]),
                          child: Text(
                            "Could not recognize any painting 😢",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : PaintingCard(
                          beforeNavigate: () {},
                          painting: painting,
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
