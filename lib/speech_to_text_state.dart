import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';

List<Language> languages = [
  const Language('English', 'en_US'),
  const Language('Francais', 'fr_FR'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
  const Language('Español', 'es_ES'),
];

class SpeechToTextState with ChangeNotifier {
  late SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String _transcription = '';
  Language _selectedLang = languages.first;

  void initiateSpeechToText() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('en_US').then((res) {
      _speechRecognitionAvailable = res;
    });
  }

  void onSpeechAvailability(bool result){
    _speechRecognitionAvailable = result;
    notifyListeners();
  }

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    _selectedLang = languages.firstWhere((l) => l.code == locale);
    notifyListeners();
  }

  void onRecognitionStarted() {
    _isListening = true;
    notifyListeners();
  }

  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    _transcription = text;
    notifyListeners();
  }

  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    _isListening = false;
    notifyListeners();
  }

  void errorHandler() => initiateSpeechToText();

  List<CheckedPopupMenuItem<Language>> get buildLanguagesWidgets => languages
      .map((l) => CheckedPopupMenuItem<Language>(
    value: l,
    checked: selectedLang == l,
    child: Text(l.name),
  )).toList();

  void start() => _speech.activate(selectedLang.code).then((_) {
    print("Lang: "+_selectedLang.name);
    return _speech.listen().then((result) {
      print('_VoiceCommandState.start => result $result');
      _transcription = "";
      _isListening = result;
      notifyListeners();
    });
  });

  void stop() => _speech.stop().then((_) async {
    _isListening = false;
    notifyListeners();
  });

  void selectLangHandler(Language lang) {
    _selectedLang = lang;
    notifyListeners();
  }

  get speechRecognitionAvailable => _speechRecognitionAvailable;

  get isListening => _isListening;

  get transcription => _transcription;

  get selectedLang => _selectedLang;
}


class Language {
  final String name;
  final String code;
  const Language(this.name, this.code);
}