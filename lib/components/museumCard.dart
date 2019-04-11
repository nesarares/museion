import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_museum_guide/models/paintingData.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/utils/constants.dart';

class MuseumCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String museumId;

  MuseumCard({Key key, this.imagePath, this.title, this.museumId})
      : super(key: key);

  _MuseumCardState createState() => _MuseumCardState();
}

enum DownloadState { DOWNLOADING, DOWNLOADED, NOT_DOWNLOADED, DELETING }

class _MuseumCardState extends State<MuseumCard> {
  static final double columnTextGap = 6.0;

  static const platform =
      const MethodChannel('com.openmg.open_museum_guide/opencv');

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
    final int paintingsDataCount =
        await dbLocal.countPaintingsDataByMuseum(widget.museumId);

    if (paintingsCount > 0 && paintingsCount == paintingsDataCount) {
      setState(() {
        downloadState = DownloadState.DOWNLOADED;
        recordsCount = paintingsCount;
      });
    } else {
      setState(() {
        downloadState = DownloadState.NOT_DOWNLOADED;
        recordsCount = paintingsCount;
      });
    }
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

      String savedDirPath = (await getApplicationDocumentsDirectory()).path;
      String savePath = '$savedDirPath/${widget.museumId}';
      String archiveName = '${widget.museumId}.zip';
      Directory saveDir = Directory(savePath);
      if (saveDir.existsSync()) saveDir.deleteSync(recursive: true);
      saveDir.createSync();

      FlutterDownloader.registerCallback((id, status, progress) async {
        if (id != downloadTaskId || status != DownloadTaskStatus.complete)
          return;

        extractArchive(savePath, archiveName);
        await generateData();

        FlutterDownloader.registerCallback(null);
      });

      downloadTaskId = await FlutterDownloader.enqueue(
          url: downloadUrl,
          savedDir: savePath,
          showNotification: true,
          openFileFromNotification: false,
          fileName: archiveName);
    } catch (err) {
      print("Could not download images for museum ${widget.museumId}");
      print(err);
    }
  }

  void extractArchive(String savePath, String archiveName) {
    // Read the Zip file from disk.
    File archiveFile = new File('$savePath/$archiveName');
    List<int> bytes = archiveFile.readAsBytesSync();

    // Decode the Zip file
    Archive archive = new ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    for (ArchiveFile file in archive) {
      String filename = file.name;
      if (file.isFile) {
        List<int> data = file.content;
        try {
          new File('$savePath/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } catch (ex) {
          print("cannot write file");
          print(ex);
        }
      } else {
        new Directory(filename)..create(recursive: true);
      }
    }

    archiveFile.deleteSync();
  }

  Future<void> generateData() async {
    setState(() {
      downloadState = DownloadState.DOWNLOADING;
      downloadStep = 3;
    });

    var paintings = await dbLocal.getPaintingsWithColumnsByMuseum(
        [Painting.columnId, Painting.columnImagePath], widget.museumId);

    paintings = (await platform.invokeMethod<List<dynamic>>(
            "generateImageData", {"paintings": paintings}))
        .map((p) => Map<String, String>.from(p))
        .toList();

    await dbLocal.insertPaintingsDataMap(paintings);

    checkDownloaded();
  }

  onDownload() async {
    await downloadDetails();
    await downloadImages();
    // await generateData();
  }

  onDeleteData() async {
    setState(() {
      downloadState = DownloadState.DELETING;
    });

    String savedDirPath = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$savedDirPath/${widget.museumId}';
    Directory saveDir = Directory(savePath);
    if (saveDir.existsSync()) saveDir.deleteSync(recursive: true);
    await dbLocal.deletePaintingsByMuseum(widget.museumId);

    checkDownloaded();
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
                                              DownloadState.DOWNLOADING ||
                                          downloadState ==
                                              DownloadState.DELETING,
                                      child: SizedBox(
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                            strokeWidth: 2.0),
                                        height: 22,
                                        width: 22,
                                      )),
                                  Visibility(
                                      visible: downloadState ==
                                          DownloadState.DOWNLOADED,
                                      child: InkWell(
                                          onTap: onDeleteData,
                                          child: Icon(Icons.delete_forever,
                                              color: Colors.white)))
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
