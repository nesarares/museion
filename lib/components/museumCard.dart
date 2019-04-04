import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'dart:ui';

import 'package:open_museum_guide/utils/constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class MuseumCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String museumId;

  MuseumCard({Key key, this.imagePath, this.title, this.museumId})
      : super(key: key);

  _MuseumCardState createState() => _MuseumCardState();
}

enum DownloadState { DOWNLOADING, DOWNLOADED, NOT_DOWNLOADED }

class _MuseumCardState extends State<MuseumCard> {
  static final double columnTextGap = 6.0;

  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  DocumentReference museumDoc;

  DownloadState downloadState = DownloadState.NOT_DOWNLOADED;
  int downloadStep = 1;
  int recordsCount = 0;

  String downloadTaskId;

  @override
  void initState() {
    super.initState();
    museumDoc = db.collection('museums').document(widget.museumId);

    checkDownloaded();
  }

  @override
  void dispose() {
    FlutterDownloader.registerCallback(null);
    super.dispose();
  }

  checkDownloaded() async {
    // Check for downloaded paintings data
    final int paintingsCount =
        await dbLocal.countPaintingsByMuseum(widget.museumId);
    print('# of Paintings: $paintingsCount');

    setState(() {
      recordsCount = paintingsCount;
    });
  }

  Future<void> downloadDetails() async {
    setState(() {
      downloadState = DownloadState.DOWNLOADING;
      downloadStep = 1;
    });

    try {
      QuerySnapshot docs =
          await museumDoc.collection('paintings').getDocuments();
      List<Map<String, dynamic>> paintings = docs.documents.map((doc) {
        var map = doc.data;
        map[Painting.columnMuseum] = widget.museumId;
        return map;
      }).toList();

      await dbLocal.insertPaintingsMap(paintings);
      await checkDownloaded();
    } catch (ex) {
      print("Download details failed");
      print(ex);
    }
  }

  Future<void> downloadImages() async {
    setState(() {
      downloadState = DownloadState.DOWNLOADING;
      downloadStep = 2;
    });

    try {
      String downloadUrl =
          await storage.ref().child('${widget.museumId}.zip').getDownloadURL();

      print(downloadUrl);

      FlutterDownloader.registerCallback((id, status, progress) {
        print(
            'Download task ($id) is in status ($status) and process ($progress)');
        if (id != downloadTaskId || status != DownloadTaskStatus.complete)
          return;

        print('Completed downloading task $id');
        FlutterDownloader.registerCallback(null);
      });

      String savedDirPath = (await getApplicationDocumentsDirectory()).path;
      downloadTaskId = await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: savedDirPath,
        showNotification: true,
        openFileFromNotification: false,
      );
    } catch (err) {
      print("Could not download images for museum ${widget.museumId}");
    }
  }

  onDownload() async {
    // await downloadDetails();
    await downloadImages();
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
                                      visible: downloadState ==
                                          DownloadState.NOT_DOWNLOADED,
                                      child: InkWell(
                                          onTap: onDownload,
                                          child: Icon(Icons.file_download,
                                              color: Colors.white))),
                                  Visibility(
                                      visible: downloadState ==
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
                                      visible: downloadState ==
                                          DownloadState.DOWNLOADED,
                                      child:
                                          Icon(Icons.done, color: Colors.white))
                                ]))
                          ]))),
              AnimatedCrossFade(
                  duration: Duration(milliseconds: 350),
                  crossFadeState: downloadState == DownloadState.DOWNLOADING
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  sizeCurve: Curves.ease,
                  firstChild: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Text('# of records: $recordsCount'),
                  ),
                  secondChild: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Downloading painting details",
                              style: buildTextStyle(1)),
                          SizedBox(height: columnTextGap),
                          Text("Downloading images", style: buildTextStyle(2)),
                          SizedBox(height: columnTextGap),
                          Text("Generating data", style: buildTextStyle(3))
                        ],
                      )))
            ])));
  }

  TextStyle buildTextStyle(int textStep) {
    Color col;
    if (textStep == downloadStep)
      col = colors['primary'];
    else if (textStep < downloadStep)
      col = Colors.black38;
    else
      col = colors['darkgray'];
    return TextStyle(fontSize: 11, color: col);
  }
}
