import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:open_museum_guide/utils/customDivider.dart';

class HomeTab extends StatefulWidget {
  final Widget child;
  final Function onErrorTap;

  HomeTab({Key key, this.child, this.onErrorTap}) : super(key: key);

  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  LoadingService loadingService = LoadingService.instance;

  void _changeLocation() {
    print('Change location clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        StreamBuilder<Object>(
            stream: loadingService.isDataLoaded$,
            builder: (ctx, snap) {
              return !snap.hasData || (snap.hasData && snap.data)
                  ? Container()
                  : Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.fromLTRB(0, 30, 30, 0),
                      child: IconButton(
                          icon:
                              Icon(FeatherIcons.alertCircle, color: Colors.red),
                          iconSize: 42,
                          onPressed: widget.onErrorTap));
            }),
        Container(
            padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("WELCOME TO",
                    style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Rufina',
                        fontWeight: FontWeight.w700)),
                CustomDivider(),
                Text("MUSÉE D'ORSAY",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'Rufina',
                        fontWeight: FontWeight.w700)),
                CustomDivider(),
                Image.asset('assets/images/museum.png', width: 132),
                Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Not here? "),
                        InkWell(
                          child: Text(
                            "Change location.",
                            style: TextStyle(color: colors['primary']),
                          ),
                          onTap: _changeLocation,
                        )
                      ],
                    ))
              ],
            )),
      ],
    );
  }
}
