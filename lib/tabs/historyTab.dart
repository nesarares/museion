import 'dart:async';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
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
  List<Painting> filteredPaintingList = [];

  TextEditingController editingController = TextEditingController();
  String searchText = "";
  Timer debounce;

  Icon searchIcon = Icon(FeatherIcons.search);
  Widget appBarTitle = Padding(
    padding: EdgeInsets.only(top: 25),
    child: Text('History'),
  );

  @override
  void initState() {
    super.initState();
    loadData();
    editingController.addListener(onSearch);
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
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
      filteredPaintingList = List.from(lst);
    });
  }

  void onSearch() {
    String query = editingController.text;
    if (debounce?.isActive ?? false) debounce.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() {
        searchText = query;
      });
    });
  }

  void searchPressed() {
    setState(() {
      if (this.searchIcon.icon == FeatherIcons.search) {
        this.searchIcon = Icon(FeatherIcons.x);
        this.appBarTitle = Padding(
          padding: EdgeInsets.only(top: 25),
          child: TextField(
            controller: editingController,
            autofocus: true,
            style: TextStyle(
              fontFamily: 'Rufina',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration.collapsed(
              hintText: 'Type artist, title, or museum...',
              hintStyle: TextStyle(
                fontFamily: 'Rufina',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        this.searchIcon = Icon(FeatherIcons.search);
        this.appBarTitle = Padding(
          padding: EdgeInsets.only(top: 25),
          child: Text('History'),
        );
        filteredPaintingList = paintingList;
        editingController.clear();
      }
    });
  }

  Widget buildList() {
    if (searchText.isNotEmpty) {
      searchText = searchText.toLowerCase();
      var filtered = paintingList.where((painting) {
        return painting.artist.toLowerCase().contains(searchText) ||
            painting.title.toLowerCase().contains(searchText) ||
            painting.museum.toLowerCase().contains(searchText);
      }).toList();
      filteredPaintingList = filtered;
    } else {
      filteredPaintingList = paintingList;
    }

    return filteredPaintingList.length != 0
        ? ListView.builder(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 30),
            itemCount: filteredPaintingList.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return PaintingCard(
                painting: filteredPaintingList[index],
                showMuseumName: true,
              );
            },
          )
        : Center(child: Text("Empty"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          titleSpacing: 30,
          title: appBarTitle,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
              child: IconButton(
                icon: searchIcon,
                onPressed: searchPressed,
              ),
            )
          ],
        ),
      ),
      body: buildList(),
    );
  }
}
