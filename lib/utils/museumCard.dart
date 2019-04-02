import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:open_museum_guide/utils/constants.dart';

class MuseumCard extends StatefulWidget {
  final String imagePath;
  final String title;

  MuseumCard({Key key, this.imagePath, this.title}) : super(key: key);

  _MuseumCardState createState() => _MuseumCardState();
}

enum DownloadState { DOWNLOADING, DOWNLOADED, NOT_DOWNLOADED }

class _MuseumCardState extends State<MuseumCard>
    with SingleTickerProviderStateMixin {
  static const double _columnTextGap = 6.0;
  DownloadState _downloadState = DownloadState.NOT_DOWNLOADED;
  int _downloadStep = 1;

  @override
  void initState() {
    super.initState();
  }

  _onDownload() {
    setState(() {
      _downloadState = DownloadState.DOWNLOADING;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: Column(children: <Widget>[
              Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: ExactAssetImage(widget.imagePath),
                        fit: BoxFit.cover),
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [
                            0.25,
                            0.75
                          ],
                              colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ])),
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            IntrinsicWidth(
                              child: Stack(children: <Widget>[
                                Container(
                                    height: 6,
                                    margin: EdgeInsets.only(top: 21),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.deepOrange.withOpacity(0.7),
                                        shape: BoxShape.rectangle)),
                                Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Text(
                                      widget.title,
                                      style: TextStyle(
                                          fontFamily: 'Rufina',
                                          color: Colors.white,
                                          fontSize: 28),
                                    ))
                              ]),
                            ),
                            Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: Row(children: <Widget>[
                                  Visibility(
                                      visible: _downloadState ==
                                          DownloadState.NOT_DOWNLOADED,
                                      child: InkWell(
                                          onTap: _onDownload,
                                          child: Icon(Icons.file_download,
                                              color: Colors.white))),
                                  Visibility(
                                      visible: _downloadState ==
                                          DownloadState.DOWNLOADING,
                                      child: SizedBox(
                                        child: new CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation(
                                                    Colors.white),
                                            strokeWidth: 2.0),
                                        height: 22,
                                        width: 22,
                                      )),
                                  Visibility(
                                      visible: _downloadState ==
                                          DownloadState.DOWNLOADED,
                                      child:
                                          Icon(Icons.done, color: Colors.white))
                                ]))
                          ]))),
              AnimatedCrossFade(
                  duration: Duration(milliseconds: 350),
                  crossFadeState: _downloadState == DownloadState.DOWNLOADING
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  sizeCurve: Curves.ease,
                  firstChild: Container(),
                  secondChild: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Downloading painting images",
                              style: buildTextStyle(1)),
                          SizedBox(height: _columnTextGap),
                          Text("Downloading painting and museum details",
                              style: buildTextStyle(2)),
                          SizedBox(height: _columnTextGap),
                          Text("Generating data", style: buildTextStyle(3))
                        ],
                      )))
            ])));
  }

  TextStyle buildTextStyle(int textStep) {
    Color col;
    if (textStep == _downloadStep)
      col = colors['primary'];
    else if (textStep < _downloadStep)
      col = Colors.black38;
    else
      col = colors['darkgray'];
    return TextStyle(fontSize: 11, color: col);
  }
}
