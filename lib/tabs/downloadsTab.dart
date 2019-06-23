import 'dart:async';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/textHeader.dart';
import 'package:open_museum_guide/components/museumCard.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/downloadService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class DownloadsTab extends StatefulWidget {
  DownloadsTab() : super();

  _DownloadsTabState createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  final MuseumService museumService = getIt.get<MuseumService>();
  final DownloadService downloadService = getIt.get<DownloadService>();

  List<Museum> museumList = [];
  List<Museum> filteredMuseumList = [];

  TextEditingController editingController = TextEditingController();
  String searchText = "";
  Timer debounce;

  Icon searchIcon = Icon(FeatherIcons.search);
  Widget appBarTitle = Padding(
    padding: EdgeInsets.only(top: 25),
    child: Text('Download data'),
  );

  static const double _columnCardsGap = 10.0;

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
    List<Museum> list = museumService.museums;
    setState(() {
      museumList = list;
      filteredMuseumList = list;
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

  void _deleteDatabase() async {
    DatabaseHelper db = getIt.get<DatabaseHelper>();
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
              hintText: 'Type museum, city, country...',
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
          child: Text('Download data'),
        );
        filteredMuseumList = museumList;
        editingController.clear();
      }
    });
  }

  Widget buildListItem(BuildContext ctxt, int index, List<Museum> museums,
      Map<String, DownloadState> states) {
    Museum current = museums[index];
    return Column(
      children: <Widget>[
        MuseumCard(
          imageUrl: current.imageUrl,
          title: current.title,
          museumId: current.id,
          downloadState: states[current.id],
        ),
        SizedBox(height: _columnCardsGap),
      ],
    );
  }

  Widget buildList(Map<String, DownloadState> museumStates) {
    if (searchText.isNotEmpty) {
      searchText = searchText.toLowerCase();
      var filtered = museumList.where((museum) {
        return museum.title.toLowerCase().contains(searchText) ||
            museum.country.toLowerCase().contains(searchText) ||
            museum.city.toLowerCase().contains(searchText);
      }).toList();
      filteredMuseumList = filtered;
    } else {
      filteredMuseumList = museumList;
    }

    return filteredMuseumList.length != 0
        ? ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            itemCount: filteredMuseumList.length,
            itemBuilder: (ctxt, index) => buildListItem(
                  ctxt,
                  index,
                  filteredMuseumList,
                  museumStates,
                ),
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
      body: StreamBuilder<Map<String, DownloadState>>(
          stream: downloadService.museumStates$,
          builder: (context, snapStates) {
            return snapStates.hasData
                ? buildList(snapStates.data)
                : Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(colors['darkGray']),
                        strokeWidth: 4.0,
                      ),
                    ),
                  );
          }),
    );
  }
}
