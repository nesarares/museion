import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/utils/roundIconButton.dart';

class PaintingDetailsPage extends StatefulWidget {
  final Painting painting;

  PaintingDetailsPage({Key key, this.painting}) : super(key: key);

  @override
  _PaintingDetailsPageState createState() => _PaintingDetailsPageState();
}

class _PaintingDetailsPageState extends State<PaintingDetailsPage> {
  static const double fontSizeTitle = 14;
  static const double fontSizeText = 18;

  void goBack() {
    Navigator.pop(context);
  }

  Widget buildSection(String title, String content,
      {double fontSText = fontSizeText}) {
    return content == null || content == ""
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style: TextStyle(
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              SizedBox(
                height: 12,
              ),
              Text(
                content,
                style: TextStyle(
                    fontSize: fontSText,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                textAlign: TextAlign.justify,
              ),
              SizedBox(
                height: 25,
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: FileImage(File(widget.painting.imagePath)),
                fit: BoxFit.cover)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: new BoxDecoration(color: Colors.black.withOpacity(0.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(5, 30, 0, 0),
                  child: RoundIconButton(
                    iconSize: 32,
                    icon: Icons.arrow_back,
                    onPressed: goBack,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      buildSection("Artist", "${widget.painting?.artist}"),
                      buildSection("Title", "${widget.painting?.title}"),
                      buildSection("Year", "${widget.painting?.year}"),
                      buildSection("Details", "${widget.painting?.text}",
                          fontSText: fontSizeText - 1.5),
                      buildSection(
                          "Dimensions", "${widget.painting?.dimensions}"),
                      buildSection("Medium", "${widget.painting?.medium}"),
                      buildSection(
                          "Copyright", "${widget.painting?.copyright}"),
                    ],
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
