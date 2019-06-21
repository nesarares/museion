import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:open_museum_guide/components/customDivider.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/pages/changeMuseumPage.dart';
import 'package:open_museum_guide/services/locationService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class HomeTab extends StatefulWidget {
  final Widget child;
  final Function onErrorTap;

  HomeTab({Key key, this.child, this.onErrorTap}) : super(key: key);

  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final LocationService locationService = getIt.get<LocationService>();
  final MuseumService museumService = getIt.get<MuseumService>();

  void changeLocation() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChangeMuseumPage()));
  }

  void tryDetectAgain() async {
    await locationService.detectAndChangeActiveMuseum();
  }

  Widget buildOrDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 20,
            child: Divider(color: colors['darkGray']),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Text(
              "OR",
              style: TextStyle(
                color: colors['darkGray'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 20,
            child: Divider(color: colors['darkGray']),
          ),
        ],
      ),
    );
  }

  Widget buildNoLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Could not detect your location",
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Rufina',
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          CustomDivider(),
          Image.asset(
            'assets/images/no-location.png',
            fit: BoxFit.fitWidth,
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Text(
                    "Try again",
                    style: TextStyle(color: colors['primary']),
                  ),
                  onTap: tryDetectAgain,
                ),
                buildOrDivider(),
                InkWell(
                  child: Text(
                    "Select location manually",
                    style: TextStyle(color: colors['primary']),
                  ),
                  onTap: changeLocation,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stack buildMuseum(AsyncSnapshot<Object> snapMuseum) {
    return Stack(
      children: <Widget>[
        StreamBuilder<Object>(
            stream: museumService.isDataLoaded$,
            builder: (ctxLoaded, snapLoaded) {
              return !snapLoaded.hasData ||
                      (snapLoaded.hasData && snapLoaded.data)
                  ? Container()
                  : buildTopErrorButton();
            }),
        Container(
            padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "WELCOME TO",
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Rufina',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomDivider(),
                Text(
                  (snapMuseum.data as Museum).title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'Rufina',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomDivider(),
                Image.asset(
                  'assets/images/museum.png',
                  width: 132,
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Not here? "),
                      InkWell(
                        child: Text(
                          "Change location",
                          style: TextStyle(color: colors['primary']),
                        ),
                        onTap: changeLocation,
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget buildTopErrorButton() {
    return Container(
        alignment: Alignment.topRight,
        margin: EdgeInsets.fromLTRB(0, 30, 30, 0),
        child: IconButton(
            icon: Icon(FeatherIcons.alertCircle, color: Colors.red),
            iconSize: 42,
            onPressed: widget.onErrorTap));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: museumService.activeMuseum$,
        builder: (ctxMuseum, snapMuseum) {
          return snapMuseum.connectionState != ConnectionState.active
              ? Container()
              : snapMuseum.data == null
                  ? buildNoLocation()
                  : buildMuseum(snapMuseum);
        });
  }
}
