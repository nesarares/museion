import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_museum_guide/pages/imagePage.dart';

import 'package:open_museum_guide/tabs/homeTab.dart';
import 'package:open_museum_guide/tabs/settingsTab.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:open_museum_guide/utils/fabBottomAppBar.dart';

class TabsPage extends StatefulWidget {
  TabsPage({Key key}) : super(key: key);

  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedTab = 0;

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return HomeTab();
      case 3:
        return SettingsTab();
      default:
        return Column();
    }
  }

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  Future<void> openCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("No image selected");
      return;
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImagePage(image: image)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: _buildTab(_selectedTab)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: openCamera,
        tooltip: 'Open Camera',
        child: Icon(Icons.photo_camera, size: 30),
        backgroundColor: colors['primary'],
        elevation: 4.0,
      ),
      bottomNavigationBar: FABBottomAppBar(
        onTabSelected: _changeTab,
        notchedShape: CircularNotchedRectangle(),
        color: colors['darkGray'],
        selectedColor: colors['primary'],
        items: [
          FABBottomAppBarItem(iconData: Icons.home, text: 'Home '),
          FABBottomAppBarItem(iconData: Icons.help, text: 'Museum info'),
          FABBottomAppBarItem(iconData: Icons.history, text: 'History'),
          FABBottomAppBarItem(iconData: Icons.file_download, text: 'Downloads'),
        ],
      ),
    );
  }
}
