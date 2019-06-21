import 'dart:ui';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/downloadService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:open_museum_guide/utils/guiUtils.dart';

class MuseumCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String museumId;
  final DownloadState downloadState;

  MuseumCard(
      {Key key, this.imageUrl, this.title, this.museumId, this.downloadState})
      : super(key: key);

  _MuseumCardState createState() => _MuseumCardState();
}

class _MuseumCardState extends State<MuseumCard> {
  final DownloadService downloadService = getIt.get<DownloadService>();
  final MuseumService museumService = getIt.get<MuseumService>();

  static final double columnTextGap = 6.0;

  int recordsCount = 0;

  @override
  void initState() {
    super.initState();
  }

  onDownload() async {
    try {
      await downloadService.downloadData(widget.museumId);
    } on DownloadException catch (e) {
      GuiUtils.showWarningNotification(context, message: e.message);
    }
  }

  onDeleteData() async {
    try {
      await this.downloadService.deleteData(widget.museumId);
    } on DownloadException catch (e) {
      GuiUtils.showWarningNotification(context, message: e.message);
    }
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
                        image: CachedNetworkImageProvider(widget.imageUrl),
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
                                      visible: widget.downloadState ==
                                          DownloadState.NOT_DOWNLOADED,
                                      child: InkWell(
                                          onTap: onDownload,
                                          child: Icon(FeatherIcons.download,
                                              color: Colors.white))),
                                  Visibility(
                                      visible: [
                                        DownloadState.DOWNLOADING_DETAILS,
                                        DownloadState.DOWNLOADING_IMAGES,
                                        DownloadState.GENERATING_DATA,
                                        DownloadState.DELETING
                                      ].contains(widget.downloadState),
                                      child: SizedBox(
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                            strokeWidth: 2.0),
                                        height: 22,
                                        width: 22,
                                      )),
                                  Visibility(
                                      visible: widget.downloadState ==
                                          DownloadState.DOWNLOADED,
                                      child: InkWell(
                                          onTap: onDeleteData,
                                          child: Icon(FeatherIcons.trash,
                                              color: Colors.white)))
                                ]))
                          ]))),
              AnimatedCrossFade(
                  duration: Duration(milliseconds: 350),
                  crossFadeState: [
                    DownloadState.DOWNLOADING_DETAILS,
                    DownloadState.DOWNLOADING_IMAGES,
                    DownloadState.GENERATING_DATA,
                  ].contains(widget.downloadState)
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  sizeCurve: Curves.ease,
                  firstChild: Container(
                      // padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      // child: Text('# of records: $recordsCount'),
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
                              style: buildTextStyle(
                                  DownloadState.DOWNLOADING_DETAILS)),
                          SizedBox(height: columnTextGap),
                          Text("Downloading images",
                              style: buildTextStyle(
                                  DownloadState.DOWNLOADING_IMAGES)),
                          SizedBox(height: columnTextGap),
                          Text("Generating data",
                              style:
                                  buildTextStyle(DownloadState.GENERATING_DATA))
                        ],
                      )))
            ])));
  }

  TextStyle buildTextStyle(DownloadState downloadState) {
    Color col;
    if (downloadState == widget.downloadState)
      col = colors['primary'];
    else if (downloadState.index < widget.downloadState.index)
      col = Colors.black38;
    else
      col = colors['darkgray'];
    return TextStyle(fontSize: 11, color: col);
  }
}
