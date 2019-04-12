import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/museumCard.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsTab extends StatefulWidget {
  SettingsTab() : super();

  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static const double _columnCardsGap = 10.0;

  void _deleteDatabase() async {
    DatabaseHelper db = DatabaseHelper.instance;
    try {
      await db.removeAllRecords();

      Fluttertoast.showToast(
          msg: "Deleted all records",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    } catch (e) {
      print("Could not delete records");
      print(e);
    }
  }

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
          // RaisedButton(
          //   onPressed: _deleteDatabase,
          //   child: Text("DeleteDatabase"),
          // ),
          MuseumCard(
            imagePath: "assets/images/orsay.jpg",
            title: "Musée d'Orsay",
            museumId: "GWNdYOmSpgjkLxnLSroV",
          ),
          SizedBox(height: _columnCardsGap),
          MuseumCard(
            imagePath: "assets/images/louvre.jpg",
            title: "Museum of testing",
            museumId: "4bGQk6lrv9cyu0y7l4FZ",
          )
        ],
      ),
    );
  }
}
