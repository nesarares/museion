import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_museum_guide/components/roundIconButton.dart';
import 'package:open_museum_guide/main.dart';
import 'package:open_museum_guide/models/painting.dart';
import 'package:open_museum_guide/services/textToSpeechService.dart';
import 'package:open_museum_guide/utils/constants.dart';
import 'package:open_museum_guide/utils/guiUtils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PaintingDetailsPage extends StatefulWidget {
  final Painting painting;

  PaintingDetailsPage({Key key, this.painting}) : super(key: key);

  @override
  _PaintingDetailsPageState createState() => _PaintingDetailsPageState();
}

class _PaintingDetailsPageState extends State<PaintingDetailsPage> {
  final TextToSpeechService ttsService = getIt.get<TextToSpeechService>();

  static const double fontSizeTitle = 14;
  static const double fontSizeText = 18;
  static const Color fontColor = Colors.black;
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(16.0),
    topRight: Radius.circular(16.0),
  );

  void goBack() async {
    await ttsService.stop();
    Navigator.pop(context);
  }

  Widget buildSection(String title, String content,
      {double fontSText = fontSizeText, String wiki}) {
    return content?.isEmpty ?? true
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style: TextStyle(
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.w900,
                      color: fontColor)),
              SizedBox(
                height: 12,
              ),
              Text(
                content,
                style: TextStyle(
                    fontSize: fontSText,
                    fontWeight: FontWeight.w400,
                    color: fontColor),
                textAlign: TextAlign.justify,
              ),
              if (wiki != null && wiki.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () => GuiUtils.launchWebpage(wiki),
                    child: Text(
                      "Read more on wikipedia",
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.w400,
                        color: colors['links'],
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 25,
              ),
            ],
          );
  }

  Widget buildWikidataSection() {
    return Row(
      children: <Widget>[
        Text(
          "Data prvided by ",
          style: TextStyle(
            fontSize: fontSizeTitle,
            fontWeight: FontWeight.w400,
            color: fontColor,
          ),
        ),
        InkWell(
          onTap: () => GuiUtils.launchWebpage('https://www.wikidata.org'),
          child: Text(
            "WikiData",
            style: TextStyle(
              fontSize: fontSizeTitle,
              fontWeight: FontWeight.w400,
              color: colors['links'],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: buildFAB(),
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: MediaQuery.of(context).size.height - 100,
            borderRadius: radius,
            parallaxEnabled: true,
            parallaxOffset: 0.3,
            body: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(
                        File(widget.painting.imagePath),
                      ),
                      fit: BoxFit.cover),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration:
                        new BoxDecoration(color: Colors.black.withOpacity(0.4)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Hero(
                          tag: widget.painting.id,
                          child: Image.file(
                            File(
                              widget.painting.imagePath,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            panel: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(30, 12, 30, 25),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          height: 5,
                          width: 25,
                          margin: EdgeInsets.only(bottom: 25),
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        Text(
                          widget.painting?.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: fontColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        buildSection("Artist", widget.painting?.artist),
                        buildSection(
                          "Details",
                          widget.painting?.text,
                          fontSText: fontSizeText - 1.5,
                          wiki: widget.painting?.wiki,
                        ),
                        buildSection("Year", widget.painting?.year),
                        buildSection("Dimensions", widget.painting?.dimensions),
                        buildSection("Medium", widget.painting?.medium),
                        buildSection("Location", widget.painting?.museum),
                        buildSection("Copyright", widget.painting?.copyright),
                        if ((widget.painting?.museum ?? '') != "Musée d'Orsay")
                          buildWikidataSection(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 30, 0, 0),
                child: RoundIconButton(
                  iconSize: 32,
                  icon: Icons.arrow_back,
                  onPressed: goBack,
                ),
              )),
        ],
      ),
    );
  }

  StreamBuilder<TtsState> buildFAB() {
    return (widget.painting?.text ?? null) == null
        ? null
        : StreamBuilder<TtsState>(
            stream: ttsService.ttsState$,
            builder: (ctx, snap) {
              return snap.data == TtsState.stopped
                  ? FloatingActionButton(
                      onPressed: () {
                        ttsService.speak(widget.painting.text);
                      },
                      child: Icon(Icons.music_note),
                    )
                  : FloatingActionButton(
                      onPressed: ttsService.stop,
                      child: Icon(Icons.stop),
                    );
            });
  }
}
