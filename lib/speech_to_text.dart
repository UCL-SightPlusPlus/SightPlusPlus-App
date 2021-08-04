import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sight_plus_plus/speech_to_text_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => SpeechToTextState(),
      child : MaterialApp(
        home: SpeechToTextTest(),
      )
  ));
}

class SpeechToTextTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SpeechToTextTestState();
  }
}

class SpeechToTextTestState extends State<SpeechToTextTest> {

  @override
  void initState() {
    super.initState();
    Provider.of<SpeechToTextState>(context, listen: false).initiateSpeechToText();
  }

  // void onSpeechAvailability(bool result) =>
  //     setState(() => _speechRecognitionAvailable = result);
  //
  // void onCurrentLocale(String locale) {
  //   print('_MyAppState.onCurrentLocale... $locale');
  //   setState(
  //       () => selectedLang = languages.firstWhere((l) => l.code == locale));
  // }
  //
  // void onRecognitionStarted() {
  //   setState(() => _isListening = true);
  // }
  //
  // void onRecognitionResult(String text) {
  //   print('_MyAppState.onRecognitionResult... $text');
  //   setState(() => transcription = text);
  // }
  //
  // void onRecognitionComplete(String text) {
  //   print('_MyAppState.onRecognitionComplete... $text');
  //   setState(() => _isListening = false);
  // }
  //
  // void errorHandler() => initiateSpeechToText();
  //
  // List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
  //     .map((l) => CheckedPopupMenuItem<Language>(
  //           value: l,
  //           checked: selectedLang == l,
  //           child: Text(l.name),
  //         ))
  //     .toList();
  //
  // void start() => _speech.activate(selectedLang.code).then((_) {
  //       print("aaaaaa" + selectedLang.name);
  //       return _speech.listen().then((result) {
  //         print('_VoiceCommandState.start => result $result');
  //         setState(() {
  //           transcription = "";
  //           _isListening = result;
  //         });
  //       });
  //     });
  //
  // void stop() => _speech.stop().then((_) async {
  //       setState(() => _isListening = false);
  //     });
  //
  // void _selectLangHandler(Language lang) {
  //   setState(() => selectedLang = lang);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Sight++"),
        actions: <Widget>[
          PopupMenuButton<Language>(
            icon: const Icon(Icons.control_point),
            onSelected: Provider.of<SpeechToTextState>(context).selectLangHandler,
            itemBuilder: (BuildContext context) => Provider.of<SpeechToTextState>(context, listen: false).buildLanguagesWidgets,
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
                  child: Text(Provider.of<SpeechToTextState>(context, listen: false).transcription),
                  decoration: BoxDecoration(border: Border.all())),
              GestureDetector(
                onTapDown: (details) =>
                    Provider.of<SpeechToTextState>(context, listen: false).speechRecognitionAvailable && !Provider.of<SpeechToTextState>(context, listen: false).isListening
                        ? Provider.of<SpeechToTextState>(context, listen: false).start()
                        : null,
                onTapUp: (details) {
                  Provider.of<SpeechToTextState>(context, listen: false).stop();
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
