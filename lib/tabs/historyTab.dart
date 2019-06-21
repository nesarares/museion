import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/textHeader.dart';
import 'package:open_museum_guide/components/paintingCard.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:path_provider/path_provider.dart';

class HistoryTab extends StatefulWidget {
  HistoryTab() : super();

  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final DatabaseHelper dbLocal = getIt.get<DatabaseHelper>();

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
