import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:open_museum_guide/components/customDivider.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/museum.dart';
import 'package:open_museum_guide/pages/changeMuseumPage.dart';
import 'package:open_museum_guide/services/locationService.dart';
import 'package:open_museum_guide/services/museumService.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'dart:math' as math;

class HomeImageClipper extends CustomClipper<Path> {
  num degToRad(num deg) => deg * (math.pi / 180.0);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height * 0.7);
    path.cubicTo(
      0,
      size.height,
      size.width * 0.45,
      size.height,
      size.width * 0.5,
      size.height,
    );
    path.cubicTo(
      size.width * 0.55,
      size.height,
      size.width * 0.9,
      size.height,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(HomeImageClipper oldClipper) => false;
}

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

  Widget buildMuseum(Museum museum) {
    return LayoutBuilder(builder: (context, viewportConstraints) {
      return Stack(
        children: <Widget>[
          buildBackgroundImage(context, museum),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(50, 80, 50, 20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "WELCOME TO",
                          style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Rufina',
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        CustomDivider(),
                        Text(
                          museum.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 50,
                              fontFamily: 'Rufina',
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        SizedBox.fromSize(
                          size: Size.fromHeight(30),
                        ),
                        Text(
                          "${museum.city} - ${museum.country}".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.15),
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
              ),
            ),
          ),
          StreamBuilder<Object>(
            stream: museumService.isDataLoaded$,
            builder: (ctxLoaded, snapLoaded) {
              return !snapLoaded.hasData ||
                      (snapLoaded.hasData && snapLoaded.data)
                  ? Container()
                  : buildTopErrorButton();
            },
          ),
        ],
      );
    });
  }

  Widget buildBackgroundImage(BuildContext context, Museum museum) {
    double val = (museum.title.hashCode % 360).toDouble();
    return ClipPath(
      clipper: HomeImageClipper(),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(museum.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              HSLColor.fromAHSL(1, val, 0.85, 0.2).toColor(),
              // Color.fromRGBO(val, 7, 7, 1),
              BlendMode.multiply,
            ),
          ),
        ),
      ),
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
    return StreamBuilder<Museum>(
        stream: museumService.activeMuseum$,
        builder: (ctxMuseum, snapMuseum) {
          return snapMuseum.connectionState != ConnectionState.active
              ? Container()
              : snapMuseum.data == null
                  ? buildNoLocation()
                  : buildMuseum(snapMuseum.data);
        });
  }
}
