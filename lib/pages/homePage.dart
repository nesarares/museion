import 'package:flutter/material.dart';
import 'package:open_museum_guide/pages/tabsPage.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final LoadingService loadingService = LoadingService.instance;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadingService.loadData();
    await Future.delayed(const Duration(milliseconds: 500), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => TabsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildDiscover(),
          buildTrueArt(),
          buildImage(),
          buildLoading(),
        ],
      ),
    ));
  }

  SizedBox buildLoading() {
    return SizedBox(
      width: 25,
      height: 25,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(colors['darkGray']),
        strokeWidth: 4.0,
      ),
    );
  }

  Padding buildImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 0),
      child: Image.asset(
        'assets/images/loading.png',
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Text buildDiscover() {
    return Text(
      "DISCOVER",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 48,
        fontFamily: 'Rufina',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Row buildTrueArt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "TRUE ",
          style: TextStyle(
            fontSize: 36,
            fontFamily: 'Rufina',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "ART",
          style: TextStyle(
            fontSize: 36,
            fontFamily: 'Rufina',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
