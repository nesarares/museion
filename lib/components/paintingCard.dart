import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/pages/paintingDetailsPage.dart';

class PaintingCard extends StatelessWidget {
  final Painting painting;
  final Function beforeNavigate;
  final Function afterNavigate;
  final double textGap = 8.0;
  final double fontSizeCard = 13;

  PaintingCard(
      {Key key, this.painting, this.beforeNavigate, this.afterNavigate})
      : super(key: key);

  Future<void> onTapCard(BuildContext context) async {
    if (beforeNavigate != null) beforeNavigate();
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
        margin: EdgeInsets.all(8),
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
                        tag: "painting",
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
                              Text("${painting?.year}",
                                  style: TextStyle(
                                      fontSize: fontSizeCard - 1,
                                      fontWeight: FontWeight.w400)),
                              SizedBox(height: textGap),
                              Text(
                                "${painting?.text?.substring(0, 50)}...",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: fontSizeCard - 1.5,
                                    fontWeight: FontWeight.w400),
                              ),
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
