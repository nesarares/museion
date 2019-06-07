import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/header.dart';
import 'package:open_museum_guide/components/museumCard.dart';
import 'package:open_museum_guide/components/paintingCard.dart';
import 'package:open_museum_guide/database/databaseHelpers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:path_provider/path_provider.dart';

class HistoryTab extends StatefulWidget {
  HistoryTab() : super();

  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final DatabaseHelper dbLocal = DatabaseHelper.instance;
  List<Painting> paintingList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    String savedDirPath = (await getApplicationDocumentsDirectory()).path;
    List<Painting> lst = await dbLocal.getPaintingsViewed();
    lst = lst.map((p) {
      p.imagePath = "$savedDirPath/${p.imagePath}";
      return p;
    }).toList();
    setState(() {
      paintingList = lst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextHeader(
          header: "History",
        ),
        Visibility(
          visible: paintingList.length != 0,
          child: Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 30),
              itemCount: paintingList.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return PaintingCard(
                  painting: paintingList[index],
                  showMuseumName: true,
                );
              },
            ),
          ),
        ),
        Visibility(
          visible: paintingList.length == 0,
          child: Expanded(child: Center(child: Text("Empty"))),
        )
      ],
    );
  }
}
