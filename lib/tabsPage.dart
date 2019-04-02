import 'package:flutter/material.dart';
import 'package:open_museum_guide/tabs/homeTab.dart';
import 'package:open_museum_guide/tabs/settingsTab.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:open_museum_guide/utils/fabBottomAppBar.dart';

class TabsPage extends StatefulWidget {
  TabsPage() : super();

  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedTab = 3;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: _buildTab(_selectedTab)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
