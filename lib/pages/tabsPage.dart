import 'dart:async';
import 'dart:io';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:open_museum_guide/components/fabMenu.dart';
import 'package:open_museum_guide/pages/cameraPage.dart';
import 'package:open_museum_guide/pages/imagePage.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:open_museum_guide/tabs/historyTab.dart';
import 'package:open_museum_guide/tabs/homeTab.dart';
import 'package:open_museum_guide/tabs/museumInfoTab.dart';
import 'package:open_museum_guide/tabs/settingsTab.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'dart:math' as math;

import 'package:unicorndial/unicorndial.dart';

class TabsPage extends StatefulWidget {
  TabsPage({Key key}) : super(key: key);

  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  LoadingService loadingService = LoadingService.instance;
  StreamController<int> indexcontroller = StreamController<int>.broadcast();
  int selectedPage = 0;
  final controller = PageController(initialPage: 0);

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

  void onPageChanged(int pageIndex) {
    indexcontroller.add(pageIndex);
  }

  void onItemSelected(int itemIndex) {
    indexcontroller.add(itemIndex);
    // controller.animateToPage(itemIndex,
    //     duration: Duration(milliseconds: 300), curve: Curves.ease);
    controller.jumpToPage(itemIndex);
  }

  @override
  void dispose() {
    indexcontroller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: controller,
          onPageChanged: onPageChanged,
          children: <Widget>[
            HomeTab(onErrorTap: () => this.openErrorNoData(context)),
            MuseumInfoTab(),
            HistoryTab(),
            SettingsTab()
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: StreamBuilder<Object>(
            stream: loadingService.isDataLoaded$,
            builder: (ctx, snap) {
              var childButtons = List<UnicornButton>();
              childButtons.add(UnicornButton(
                  hasLabel: true,
                  labelText: "Camera",
                  currentButton: FloatingActionButton(
                    heroTag: "camera",
                    backgroundColor: Colors.blueAccent,
                    mini: true,
                    child: Icon(FeatherIcons.camera),
                    onPressed: openCamera,
                  )));
              childButtons.add(UnicornButton(
                  hasLabel: true,
                  labelText: "Gallery",
                  currentButton: FloatingActionButton(
                    heroTag: "gallery",
                    backgroundColor: Colors.blueAccent,
                    mini: true,
                    child: Icon(FeatherIcons.image),
                    onPressed: openGallery,
                  )));
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                child: UnicornDialer(
                    parentButtonBackground: snap.hasData && snap.data
                        ? colors['primary']
                        : colors['disabledGray'],
                    orientation: UnicornOrientation.VERTICAL,
                    parentButton: Icon(
                      FeatherIcons.camera,
                      size: 30,
                    ),
                    onMainButtonPressed: snap.hasData && snap.data
                        ? () {}
                        : () => openErrorNoData(ctx),
                    childButtons:
                        snap.hasData && snap.data ? childButtons : []),
              );
            }),
        bottomNavigationBar: StreamBuilder(
            stream: indexcontroller.stream,
            initialData: 0,
            builder: (c, snap) {
              int currentindex = snap.data;
              return BottomNavyBar(
                selectedIndex: currentindex,
                showElevation: true,
                onItemSelected: onItemSelected,
                items: [
                  BottomNavyBarItem(
                    icon: Icon(FeatherIcons.home),
                    title: Text('Home'),
                    activeColor: Colors.deepOrange,
                  ),
                  BottomNavyBarItem(
                      icon: Icon(FeatherIcons.helpCircle),
                      title: Text('Museum info'),
                      activeColor: Colors.purpleAccent),
                  BottomNavyBarItem(
                      icon: Icon(Icons.history),
                      title: Text('History'),
                      activeColor: Colors.redAccent),
                  BottomNavyBarItem(
                      icon: Icon(FeatherIcons.download),
                      title: Text('Downloads'),
                      activeColor: Colors.blueAccent),
                ],
              );
            }));
  }
}
