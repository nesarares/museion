import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/textHeader.dart';
import 'package:open_museum_guide/components/museumCard.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class DownloadsTab extends StatefulWidget {
  DownloadsTab() : super();

  _DownloadsTabState createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  static const double _columnCardsGap = 10.0;
  static final MuseumService museumService = MuseumService.instance;

  @override
  void initState() {
    super.initState();
  }

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

  Widget buildListItem(BuildContext ctxt, int index, List<Museum> museums) {
    Museum current = museums[index];
    return Column(
      children: <Widget>[
        MuseumCard(
          imageUrl: current.imageUrl,
          title: current.title,
          museumId: current.id,
        ),
        SizedBox(height: _columnCardsGap),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextHeader(header: 'Download museum data'),
        // RaisedButton(
        //   onPressed: _deleteDatabase,
        //   child: Text("DeleteDatabase"),
        // ),
        StreamBuilder<Object>(
            stream: museumService.museums$,
            builder: (ctx, snap) {
              return !snap.hasData
                  ? SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(colors['darkGray']),
                          strokeWidth: 2.5),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        itemCount: (snap.data as List<Museum>).length,
                        itemBuilder: (ctxt, index) => buildListItem(
                            ctxt, index, (snap.data as List<Museum>)),
                      ),
                    );
            })
      ],
    );
  }
}
