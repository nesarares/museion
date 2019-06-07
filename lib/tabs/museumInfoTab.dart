import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/museumService.dart';

class MuseumInfoTab extends StatelessWidget {
  static final MuseumService museumService = MuseumService.instance;
  final double sizeIconFacility = 38;

  Widget buildSection(String title, String content, {bool newLines = false}) {
    if (content == null || content == "") {
      return Container();
    }
    if (newLines) {
      content = content.replaceAll(';', '\n');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
      child: Column(
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
      ),
    );
  }

  Widget buildFacilities(String facilities) {
    if (facilities == null || facilities == "") {
      return Container();
    }
    List<String> list = facilities.split(';');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 25,
          ),
          Text('Facilities',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black)),
          SizedBox(
            height: 12,
          ),
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 20,
            children: list.map((facility) {
              print(facility);
              var icon;
              switch (facility) {
                case 'wifi':
                  icon = Icons.wifi;
                  break;
                case 'cloackrooms':
                case 'cloakrooms':
                  icon = Icons.portrait;
                  break;
                case 'lifts':
                  icon = Icons.arrow_upward;
                  break;
                case 'wheelchairs':
                  icon = Icons.accessible;
                  break;
              }
              if (icon == null) return Container();
              return Column(
                children: <Widget>[
                  Icon(icon, size: sizeIconFacility),
                  Text('${facility[0].toUpperCase()}${facility.substring(1)}')
                ],
              );
            }).toList(),
          ),
        ],
      ),
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
                  : ListView(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                          child: Text(
                            (snap.data as Museum).title,
                            style: TextStyle(
                                fontFamily: 'Rufina',
                                fontWeight: FontWeight.w700,
                                fontSize: 32),
                          ),
                        ),
                        buildSection('Open hours', (snap.data as Museum).hours,
                            newLines: true),
                        buildFacilities((snap.data as Museum).facilities),
                        // add address map
                        buildSection('Address', (snap.data as Museum).address),
                        buildSection('Website', (snap.data as Museum).website)
                      ],
                    );
        });
  }
}
