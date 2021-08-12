import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class SpeechToTextState with ChangeNotifier{
  late SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String _transcription = '';
  String _languageCode = '';

  void initiateSpeechToText({String languageCode = 'en'}) {
    print('_MyAppState.activateSpeechRecognizer... ');
    _languageCode = languageCode;
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate(_languageCode).then((res) {
      _speechRecognitionAvailable = res;
    });
  }

  void onSpeechAvailability(bool result){
    _speechRecognitionAvailable = result;
    notifyListeners();
  }

  void onRecognitionStarted() {
    _isListening = true;
    notifyListeners();
  }

  void onRecognitionResult(String text) async{
    print('_MyAppState.onRecognitionResult... $text');

    GoogleTranslator().translate(text, to: 'en').then((value){
      _transcription = "$value";
    });
  }

  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    _isListening = false;
    notifyListeners();
  }

  void errorHandler() => initiateSpeechToText(languageCode: _languageCode);

  void start() {
    _speech.activate(_languageCode).then((_) {
        return _speech.listen().then((result) {
          _transcription = "";
          _isListening = result;
        });
    });
  }

  void stop(){
    _speech.stop().then((_) async {
      _isListening = false;
    });
  }

  get speechRecognitionAvailable => _speechRecognitionAvailable;

  get isListening => _isListening;

  get transcription => _transcription;

  get canStart => _speechRecognitionAvailable && !_isListening;

  get languageCode => _languageCode;
}


class Language {
  final String name;
  final String code;
  const Language(this.name, this.code);
}