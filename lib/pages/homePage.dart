import 'package:flutter/material.dart';
import 'package:open_museum_guide/pages/tabsPage.dart';
import 'package:open_museum_guide/services/paintingDataService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  static final PaintingDataService service = PaintingDataService.instance;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await service.loadMuseumData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.white,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colors['darkGray']),
                    strokeWidth: 4.0),
              ),
            ))
        : TabsPage();
  }
}
