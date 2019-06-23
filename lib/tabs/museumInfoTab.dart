import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MuseumInfoTab extends StatelessWidget {
  final MuseumService museumService = getIt.get<MuseumService>();

  final double sizeIconFacility = 35;

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
          Container(
            width: double.infinity,
            child: Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceEvenly,
              runSpacing: 20,
              spacing: 20,
              children: list.map((facility) {
                var icon;
                switch (facility) {
                  case 'audio guide':
                    icon = FontAwesomeIcons.headphonesAlt;
                    break;
                  case 'café-restaurant':
                    icon = FontAwesomeIcons.utensils;
                    break;
                  case 'changing rooms':
                    icon = FontAwesomeIcons.baby;
                    break;
                  case 'cloakrooms':
                    icon = FontAwesomeIcons.portrait;
                    break;
                  case 'guided tours':
                    icon = FontAwesomeIcons.userCheck;
                    break;
                  case 'left-luggage office':
                    icon = FontAwesomeIcons.suitcase;
                    break;
                  case 'lifts':
                    icon = FontAwesomeIcons.arrowUp;
                    break;
                  case 'parking':
                    icon = FontAwesomeIcons.parking;
                    break;
                  case 'photography':
                    icon = FontAwesomeIcons.cameraRetro;
                    break;
                  case 'shopping':
                    icon = FontAwesomeIcons.shoppingCart;
                    break;
                  case 'wheelchairs':
                    icon = FontAwesomeIcons.wheelchair;
                    break;
                  case 'wifi':
                    icon = FontAwesomeIcons.wifi;
                    break;
                }
                if (icon == null) return Container();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, size: sizeIconFacility),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 82),
                        child: Text(
                          '${facility[0].toUpperCase()}${facility.substring(1)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
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
