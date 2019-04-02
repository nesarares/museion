import 'package:flutter/material.dart';
import 'package:open_museum_guide/utils/museumCard.dart';

class SettingsTab extends StatefulWidget {
  SettingsTab() : super();

  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static const double _columnCardsGap = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 55, 25, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Text("Download data for museums",
                style: TextStyle(fontSize: 16)),
          ),
          MuseumCard(
            imagePath: "assets/images/orsay.jpg",
            title: "Musée d'Orsay",
          ),
          SizedBox(height: _columnCardsGap),
          MuseumCard(
            imagePath: "assets/images/louvre.jpg",
            title: "Musée du Louvre",
          )
        ],
      ),
    );
  }
}
