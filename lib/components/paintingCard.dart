import 'dart:io';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/pages/paintingDetailsPage.dart';
import 'package:open_museum_guide/services/paintingService.dart';

class PaintingCard extends StatelessWidget {
  final Painting painting;
  final Function beforeNavigate;
  final Function afterNavigate;
  final bool showMuseumName;
  final double textGap = 8.0;
  final double fontSizeCard = 13;
  static final PaintingService paintingService = PaintingService.instance;

  PaintingCard(
      {Key key,
      this.painting,
      this.beforeNavigate,
      this.afterNavigate,
      this.showMuseumName})
      : super(key: key);

  Future<void> onTapCard(BuildContext context) async {
    if (beforeNavigate != null) {
      beforeNavigate();
      await paintingService.addPaintingToHistory(painting);
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaintingDetailsPage(painting: painting)));
    if (afterNavigate != null) afterNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 400),
      firstChild: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(8),
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 2.5),
        ),
      ),
      secondChild: Container(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: InkWell(
          onTap: () => onTapCard(context),
          child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 5,
              child: Container(
                // height: 150,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                        tag: "${painting?.id}",
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    FileImage(File("${painting?.imagePath}")),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${painting?.artist}",
                                  style: TextStyle(
                                      fontSize: fontSizeCard,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: textGap),
                              Text("${painting?.title}",
                                  style: TextStyle(
                                      fontSize: fontSizeCard,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: textGap),
                              Visibility(
                                visible: !showMuseumName,
                                child: Text("${painting?.year}",
                                    style: TextStyle(
                                        fontSize: fontSizeCard - 1,
                                        fontWeight: FontWeight.w400)),
                              ),
                              Visibility(
                                  visible: !showMuseumName,
                                  child: SizedBox(height: textGap)),
                              Visibility(
                                visible: !showMuseumName,
                                child: Text(
                                  "${painting?.text?.substring(0, 50)}...",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: fontSizeCard - 1.5,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Visibility(
                                visible: showMuseumName,
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child:
                                          Icon(FeatherIcons.mapPin, size: 15),
                                    ),
                                    Text("${painting?.museum}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: fontSizeCard,
                                            fontWeight: FontWeight.w400))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ),
      ),
      crossFadeState: painting == null
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      sizeCurve: Curves.ease,
    );
  }
}
