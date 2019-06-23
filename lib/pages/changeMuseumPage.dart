import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/roundIconButton.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class ChangeMuseumPage extends StatefulWidget {
  @override
  _ChangeMuseumPageState createState() => _ChangeMuseumPageState();
}

class _ChangeMuseumPageState extends State<ChangeMuseumPage> {
  final MuseumService museumService = getIt.get<MuseumService>();

  List<Museum> museumList = [];
  List<Museum> filteredMuseumList = [];

  TextEditingController editingController = TextEditingController();
  String searchText = "";
  Timer debounce;

  Icon searchIcon = Icon(FeatherIcons.search);
  Widget appBarTitle = Padding(
    padding: EdgeInsets.only(top: 25),
    child: Text('Select location'),
  );

  final double imageSize = 60;

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
          child: Text('Select location'),
        );
        filteredMuseumList = museumList;
        editingController.clear();
      }
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  void changeMuseum(String id) {
    museumService.changeActiveMuseum(id);
    goBack();
  }

  Widget buildList() {
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
            itemCount: filteredMuseumList.length,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            itemBuilder: (BuildContext context, int index) {
              return museumView(filteredMuseumList[index]);
            },
          )
        : Center(child: Text("Empty"));
  }

  Widget museumView(Museum museum) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => changeMuseum(museum.id),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: imageSize,
                height: imageSize,
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(museum.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(imageSize)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    museum.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    museum.city,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          titleSpacing: 20,
          title: appBarTitle,
          leading: Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
            child: IconButton(
              icon: Icon(
                FeatherIcons.arrowLeft,
              ),
              onPressed: goBack,
            ),
          ),
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
