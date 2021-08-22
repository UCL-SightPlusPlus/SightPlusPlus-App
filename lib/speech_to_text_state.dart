import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

class SpeechToTextState with ChangeNotifier{
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String _transcription = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  final SpeechToText speech = SpeechToText();


  void initiateSpeechToText() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true);
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
      _hasSpeech = hasSpeech;
      notifyListeners();
    }

  }

  void startListening() {
    _transcription = '';
    lastError = '';
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
  }

  void stopListening() {
    speech.stop();
    level = 0.0;
    notifyListeners();
  }

  void cancelListening() {
    speech.cancel();
    level = 0.0;
    notifyListeners();
  }

  void resultListener(SpeechRecognitionResult result) {
    GoogleTranslator().translate(result.recognizedWords, to: 'en').then((value) {
      _transcription = value.text;
      print("Transcription is: " + _transcription);
    }
    );
    notifyListeners();
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    this.level = level;
  }

  void errorListener(SpeechRecognitionError error) {
    lastError = '${error.errorMsg} - ${error.permanent}';
  }

  void statusListener(String status) {
    print("Status is: "+status);
    lastStatus = status;
    notifyListeners();
  }

  get canStart => speech.isNotListening && speech.isAvailable;

  get transcription => _transcription;

  get isListening => speech.isListening;

}