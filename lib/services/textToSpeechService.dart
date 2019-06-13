import 'package:flutter_tts/flutter_tts.dart';
import 'package:rxdart/rxdart.dart';

enum TtsState { playing, stopped }

class TextToSpeechService {
  TextToSpeechService._privateConstructor();
  static final TextToSpeechService instance =
      TextToSpeechService._privateConstructor();

  FlutterTts flutterTts;

  BehaviorSubject<TtsState> _ttsStateSubject =
      BehaviorSubject.seeded(TtsState.stopped);
  Observable<TtsState> get ttsState$ => _ttsStateSubject.stream;

  Future<void> loadTTS() async {
    flutterTts = new FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      _ttsStateSubject.add(TtsState.playing);
    });

    flutterTts.setCompletionHandler(() {
      _ttsStateSubject.add(TtsState.stopped);
    });

    flutterTts.setErrorHandler((msg) {
      print('ERROR ON TTS: $msg');
      _ttsStateSubject.add(TtsState.stopped);
    });
  }

  Future<void> speak(String text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) {
      _ttsStateSubject.add(TtsState.playing);
    }
  }

  Future<void> stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      _ttsStateSubject.add(TtsState.stopped);
    }
  }
}
