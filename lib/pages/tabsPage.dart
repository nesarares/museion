import 'dart:io';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_museum_guide/pages/cameraPage.dart';
import 'package:open_museum_guide/pages/imagePage.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:open_museum_guide/tabs/homeTab.dart';
import 'package:open_museum_guide/tabs/museumInfoTab.dart';
import 'package:open_museum_guide/tabs/settingsTab.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:open_museum_guide/utils/fabBottomAppBar.dart';
import 'dart:math' as math;

class TabsPage extends StatefulWidget {
  TabsPage({Key key}) : super(key: key);

  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  LoadingService loadingService = LoadingService.instance;
  int _selectedTab = 0;

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return HomeTab(onErrorTap: () => this.openErrorNoData(context));
      case 1:
        return MuseumInfoTab();
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CameraPage()));
  }

  Future<void> openGallery() async {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: maxWidth, maxHeight: maxHeight);

    if (image == null) {
      print("No image selected");
      return;
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImagePage(image: image)));
  }

  void openErrorNoData(BuildContext context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      messageText: Text(
        'Please download the data for <museum_name> from the "Downloads" tab',
        style: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15),
      ),
      icon: Icon(
        FeatherIcons.alertCircle,
        color: Colors.white,
        size: 24,
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 5),
      animationDuration: Duration(milliseconds: 400),
      aroundPadding: EdgeInsets.all(8),
      borderRadius: 8,
      forwardAnimationCurve: Curves.ease,
      boxShadow: BoxShadow(
          color: Colors.black38,
          blurRadius: 5,
          offset: Offset.fromDirection(math.pi / 2, 2)),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: _buildTab(_selectedTab)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: StreamBuilder<Object>(
          stream: loadingService.isDataLoaded$,
          builder: (ctx, snap) {
            return FloatingActionButton(
              onPressed: snap.hasData && snap.data
                  ? openCamera
                  : () => openErrorNoData(ctx),
              tooltip: 'Open Camera',
              child: Icon(FeatherIcons.camera, size: 30),
              backgroundColor: snap.hasData && snap.data
                  ? colors['primary']
                  : colors['disabledGray'],
              elevation: 4.0,
            );
            // var childButtons = List<UnicornButton>();
            // childButtons.add(UnicornButton(
            //     hasLabel: true,
            //     labelText: "Camera",
            //     currentButton: FloatingActionButton(
            //       heroTag: "camera",
            //       backgroundColor: Colors.blueAccent,
            //       mini: true,
            //       child: Icon(FeatherIcons.camera),
            //       onPressed: openCamera,
            //     )));
            // childButtons.add(UnicornButton(
            //     hasLabel: true,
            //     labelText: "Gallery",
            //     currentButton: FloatingActionButton(
            //       heroTag: "gallery",
            //       backgroundColor: Colors.blueAccent,
            //       mini: true,
            //       child: Icon(FeatherIcons.image),
            //       onPressed: openGallery,
            //     )));
            // return Container(
            //   margin: EdgeInsets.only(bottom: 10),
            //   child: UnicornDialer(
            //       hasNotch: true,

            //       // backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
            //       parentButtonBackground: snap.hasData && snap.data
            //           ? colors['primary']
            //           : colors['disabledGray'],
            //       orientation: UnicornOrientation.VERTICAL,
            //       parentButton: Icon(
            //         FeatherIcons.camera,
            //         size: 30,
            //       ),
            //       childButtons: snap.hasData && snap.data ? childButtons : []),
            // );
          }),
      bottomNavigationBar: FABBottomAppBar(
        onTabSelected: _changeTab,
        notchedShape: CircularNotchedRectangle(),
        color: colors['darkGray'],
        selectedColor: colors['primary'],
        items: [
          FABBottomAppBarItem(iconData: FeatherIcons.home, text: 'Home '),
          FABBottomAppBarItem(
              iconData: FeatherIcons.helpCircle, text: 'Museum info'),
          FABBottomAppBarItem(iconData: Icons.history, text: 'History'),
          FABBottomAppBarItem(
              iconData: FeatherIcons.download, text: 'Downloads'),
        ],
      ),
    );
  }
}
