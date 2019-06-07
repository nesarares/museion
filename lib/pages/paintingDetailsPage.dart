import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/utils/roundIconButton.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PaintingDetailsPage extends StatefulWidget {
  final Painting painting;

  PaintingDetailsPage({Key key, this.painting}) : super(key: key);

  @override
  _PaintingDetailsPageState createState() => _PaintingDetailsPageState();
}

class _PaintingDetailsPageState extends State<PaintingDetailsPage> {
  static const double fontSizeTitle = 14;
  static const double fontSizeText = 18;
  static const Color fontColor = Colors.black;
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(16.0),
    topRight: Radius.circular(16.0),
  );

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
                      color: fontColor)),
              SizedBox(
                height: 12,
              ),
              Text(
                content,
                style: TextStyle(
                    fontSize: fontSText,
                    fontWeight: FontWeight.w400,
                    color: fontColor),
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
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: MediaQuery.of(context).size.height - 100,
            borderRadius: radius,
            parallaxEnabled: true,
            parallaxOffset: 0.3,
            body: Center(
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(File(widget.painting.imagePath)),
                          fit: BoxFit.cover)),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: new BoxDecoration(
                            color: Colors.black.withOpacity(0.4)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          //   PhotoView(
                          //       imageProvider:
                          //           FileImage(File(widget.painting.imagePath))),
                          // )
                          child: Hero(
                              tag: widget.painting.id,
                              child:
                                  Image.file(File(widget.painting.imagePath))),
                        )),
                      ))),
            ),
            panel: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(30, 12, 30, 25),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          height: 5,
                          width: 25,
                          margin: EdgeInsets.only(bottom: 25),
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        Text(
                          widget.painting?.title,
                          style: TextStyle(
                              color: fontColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        buildSection("Artist", "${widget.painting?.artist}"),
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
          Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 30, 0, 0),
                child: RoundIconButton(
                  iconSize: 32,
                  icon: Icons.arrow_back,
                  onPressed: goBack,
                ),
              )),
        ],
      ),
    );
  }
}
