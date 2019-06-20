import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/roundIconButton.dart';
import 'package:open_museum_guide/components/textHeader.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class ChangeMuseumPage extends StatefulWidget {
  @override
  _ChangeMuseumPageState createState() => _ChangeMuseumPageState();
}

class _ChangeMuseumPageState extends State<ChangeMuseumPage> {
  final double imageSize = 60;
  MuseumService museumService = MuseumService.instance;
  LoadingService loadingService = LoadingService.instance;

  void goBack() {
    Navigator.pop(context);
  }

  void changeMuseum(String id) {
    museumService.changeActiveMuseum(id);
    goBack();
  }

  Widget museumView(Museum museum) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => changeMuseum(museum.id),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: imageSize,
                height: imageSize,
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(museum.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(imageSize)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    museum.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    museum.city,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Museum>>(
        stream: museumService.museums$,
        builder: (context, snapshot) {
          var museumList = snapshot.data;
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RoundIconButton(
                        icon: Icons.arrow_back,
                        onPressed: goBack,
                        iconSize: 24,
                        color: Colors.black,
                      ),
                      Text(
                        "Select location",
                        softWrap: true,
                        style: TextStyle(
                            fontFamily: 'Rufina',
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: !snapshot.hasData
                      ? Center(
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(colors['darkGray']),
                                strokeWidth: 2.5),
                          ),
                        )
                      : ListView.builder(
                          itemCount: museumList.length,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          itemBuilder: (BuildContext context, int index) {
                            return museumView(museumList[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        });
  }
}
