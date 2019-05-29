import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/museumService.dart';

class MuseumInfoTab extends StatelessWidget {
  static final MuseumService museumService = MuseumService.instance;

  Widget buildSection(String title, String content, {bool newLines = false}) {
    if (content == null || content == "") {
      return Container();
    }
    if (newLines) {
      content = content.replaceAll(';', '\n');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 25,
        ),
        Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.black)),
        SizedBox(
          height: 12,
        ),
        Text(
          content,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: museumService.activeMuseum$,
        builder: (ctx, snap) {
          return !snap.hasData
              ? Container()
              : snap.data == null
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      (snap.data as Museum).imageUrl),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 30, horizontal: 30),
                              scrollDirection: Axis.vertical,
                              children: <Widget>[
                                Text(
                                  (snap.data as Museum).title,
                                  style: TextStyle(
                                      fontFamily: 'Rufina',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 32),
                                ),
                                buildSection(
                                    'Open hours', (snap.data as Museum).hours,
                                    newLines: true),
                                buildSection(
                                    'Address', (snap.data as Museum).address),
                                buildSection(
                                    'Website', (snap.data as Museum).website)
                              ],
                            ),
                          )
                        ]);
        });
  }
}
