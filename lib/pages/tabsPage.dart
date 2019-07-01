import 'dart:async';
import 'dart:io';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/pages/cameraPage.dart';
import 'package:open_museum_guide/pages/imagePage.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/tabs/historyTab.dart';
import 'package:open_museum_guide/tabs/homeTab.dart';
import 'package:open_museum_guide/tabs/museumInfoTab.dart';
import 'package:open_museum_guide/tabs/downloadsTab.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:open_museum_guide/utils/guiUtils.dart';

import 'package:unicorndial/unicorndial.dart';

class TabsPage extends StatefulWidget {
  TabsPage({Key key}) : super(key: key);

  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  final MuseumService museumService = getIt.get<MuseumService>();

  StreamController<int> indexcontroller = StreamController<int>.broadcast();
  int selectedPage = 0;
  final controller = PageController(initialPage: 0);

  Future<void> openCamera() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CameraPage()));
  }

  Future<void> openGallery() async {
    final double maxDimensions = 2500;
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxDimensions,
        maxHeight: maxDimensions);

    if (image == null) {
      print("No image selected");
      return;
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImagePage(image: image)));
  }

  void openErrorNoData() {
    var message = museumService.activeMuseum != null
        ? 'Please download the data for "${museumService.activeMuseum.title}" from the "Downloads" tab'
        : 'Please select your current location from the "Home" tab';
    GuiUtils.showErrorNotification(context, message: message);
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
          HomeTab(onErrorTap: () => this.openErrorNoData()),
          MuseumInfoTab(),
          HistoryTab(),
          DownloadsTab()
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: StreamBuilder<Object>(
          stream: museumService.isDataLoaded$,
          builder: (ctx, snap) {
            var childButtons = List<UnicornButton>();
            childButtons.add(
              UnicornButton(
                hasLabel: true,
                labelText: "Camera",
                currentButton: FloatingActionButton(
                  heroTag: "camera",
                  backgroundColor: Colors.redAccent,
                  mini: true,
                  child: Icon(FeatherIcons.camera),
                  onPressed: openCamera,
                ),
              ),
            );
            childButtons.add(
              UnicornButton(
                hasLabel: true,
                labelText: "Gallery",
                currentButton: FloatingActionButton(
                  heroTag: "gallery",
                  backgroundColor: Colors.redAccent,
                  mini: true,
                  child: Icon(FeatherIcons.image),
                  onPressed: openGallery,
                ),
              ),
            );
            return UnicornDialer(
              parentButtonBackground: snap.hasData && snap.data
                  ? colors['primary']
                  : colors['disabledGray'],
              orientation: UnicornOrientation.VERTICAL,
              parentButton: Icon(
                FeatherIcons.camera,
                size: 30,
                color: Colors.white,
              ),
              backgroundColor: Colors.white.withOpacity(0.85),
              hasBackground: true,
              animationDuration: 100,
              onMainButtonPressed:
                  snap.hasData && snap.data ? () {} : () => openErrorNoData(),
              childButtons: snap.hasData && snap.data ? childButtons : [],
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
                activeColor: Colors.purpleAccent,
              ),
              BottomNavyBarItem(
                icon: Icon(Icons.history),
                title: Text('History'),
                activeColor: Colors.redAccent,
              ),
              BottomNavyBarItem(
                icon: Icon(FeatherIcons.download),
                title: Text('Downloads'),
                activeColor: Colors.blueAccent,
              ),
            ],
          );
        },
      ),
    );
  }
}
