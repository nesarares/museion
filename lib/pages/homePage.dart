import 'package:flutter/material.dart';
import 'package:open_museum_guide/pages/tabsPage.dart';
import 'package:open_museum_guide/services/loadingService.dart';
import 'package:open_museum_guide/utils/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  static final LoadingService loadingService = LoadingService.instance;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadingService.loadMuseumData();
    await loadingService.loadModel();
    await loadingService.loadCameras();
    await loadingService.loadTTS();
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
