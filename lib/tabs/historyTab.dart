import 'dart:async';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/paintingCard.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/services/databaseHelper.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/services/paintingService.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HistoryTab extends StatefulWidget {
  HistoryTab() : super();

  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final DatabaseHelper dbLocal = getIt.get<DatabaseHelper>();
  final PaintingService paintingService = getIt.get<PaintingService>();

  List<Painting> paintingsList = [];
  List<Painting> filteredPaintingList = [];

  TextEditingController editingController = TextEditingController();
  String searchText = "";
  Timer debounce;

  Icon searchIcon = Icon(FeatherIcons.search);
  Widget appBarTitle = Padding(
    padding: EdgeInsets.only(top: 25),
    child: Text('History'),
  );

  final animatedListKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    editingController.addListener(onSearch);
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
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
        filteredPaintingList = paintingsList;
        editingController.clear();
      }
    });
  }

  Future<void> clearHistory() async {
    paintingService.removeAllPaintingsFromHistory();
  }

  Future<void> removeItem(int index) async {
    Painting toRemove = filteredPaintingList[index];
    paintingService.removePaintingFromHistory(toRemove.id);
  }

  Widget clearHistoryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(FeatherIcons.barChart2),
                  ),
                ),
                Text(
                  "CLEAR HISTORY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
            onPressed: clearHistory,
          ),
        ],
      ),
    );
  }

  Widget buildList() {
    if (searchText.isNotEmpty) {
      searchText = searchText.toLowerCase();
      var filtered = paintingsList.where((painting) {
        return painting.artist.toLowerCase().contains(searchText) ||
            painting.title.toLowerCase().contains(searchText) ||
            painting.museum.toLowerCase().contains(searchText);
      }).toList();
      filteredPaintingList = filtered;
    } else {
      filteredPaintingList = paintingsList;
    }

    bool isSearching = filteredPaintingList.length != paintingsList.length;
    int last = filteredPaintingList.length;

    return filteredPaintingList.length != 0
        ? ListView.builder(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 20),
            itemCount: filteredPaintingList.length + 1,
            itemBuilder: (BuildContext ctxt, int index) {
              if (!isSearching && index == last) {
                return clearHistoryButton();
              }
              return buildListItem(index);
            },
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/empty-history.png',
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          );
  }

  Widget buildListItem(int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.4,
      child: PaintingCard(
        painting: filteredPaintingList[index],
        showMuseumName: true,
      ),
      actions: <Widget>[
        IconSlideAction(
          // caption: 'Remove',
          color: Colors.transparent,
          iconWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Icon(
                  FeatherIcons.trash,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              Text(
                "REMOVE",
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 4,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          foregroundColor: Colors.red,
          onTap: () => removeItem(index),
        ),
      ],
    );
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
      body: StreamBuilder<List<Painting>>(
          stream: paintingService.historyPaintings$,
          builder: (context, snapshot) {
            paintingsList = snapshot.data ?? [];
            return buildList();
          }),
    );
  }
}
