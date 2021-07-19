import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SpeechToTextTest());
}

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

var languages = [
  const Language('English', 'en_US'),
  const Language('Francais', 'fr_FR'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
  const Language('Español', 'es_ES'),
];

class SpeechToTextTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SpeechToTextState();
  }
}

class SpeechToTextState extends State<SpeechToTextTest> {
  late SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String transcription = '';
  Language selectedLang = languages.first;

  @override
  void initState() {
    super.initState();
    initiateSpeechToText();
  }

  void initiateSpeechToText() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('en_US').then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    setState(() => transcription = text);
  }

  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  void errorHandler() => initiateSpeechToText();

  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      .map((l) => CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: Text(l.name),
          ))
      .toList();

  void start() => _speech.activate(selectedLang.code).then((_) {
        print("aaaaaa" + selectedLang.name);
        return _speech.listen().then((result) {
          print('_VoiceCommandState.start => result $result');
          setState(() {
            transcription = "";
            _isListening = result;
          });
        });
      });

  void stop() => _speech.stop().then((_) async {
        setState(() => _isListening = false);
      });

  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Sight++"),
        actions: <Widget>[
          PopupMenuButton<Language>(
            icon: const Icon(Icons.control_point),
            onSelected: _selectLangHandler,
            itemBuilder: (BuildContext context) => _buildLanguagesWidgets,
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 15.0),
                  child: Text(transcription),
                  decoration: BoxDecoration(border: Border.all())),
              GestureDetector(
                onTapDown: (details) =>
                    _speechRecognitionAvailable && !_isListening
                        ? start()
                        : null,
                onTapUp: (details) {
                  stop();
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).buttonColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text('My Button'),
                ),
              ),
              // ElevatedButton(
              //   onLongPress:  _speechRecognitionAvailable && !_isListening && ip != ""
              //       ? () => start()
              //       : null,
              //   onPressed: _speechRecognitionAvailable && !_isListening && ip != ""
              //       ? () => start()
              //       : null,
              //   child: Text(
              //     _isListening
              //         ? 'Listening...'
              //         : 'Listen (${selectedLang.code})',
              //     style: const TextStyle(color: Colors.white),
              //   ),
              // )
            ],
          ))),
    ));
  }
}
