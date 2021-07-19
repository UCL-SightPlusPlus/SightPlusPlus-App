import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:text_to_speech/text_to_speech.dart';

void main(){
  runApp(TextToSpeechTest());
}

class TextToSpeechTest extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TextToSpeechState();
  }
}

class TextToSpeechState extends State<TextToSpeechTest>{
  late TextToSpeech _tts;
  var languages = [];
  String? language;
  String? languageCode;
  List<String> languageCodes = [];
  String? voice;
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    _tts = TextToSpeech();
    // populate lang code (i.e. en-US)
    languageCodes = await _tts.getLanguages();

    // get default language
    final String? defaultLangCode = await _tts.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = languages.first.code;
    }

    // get voice
    voice = await getVoiceByLang(languageCode!);
    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getVoiceByLang(String lang) async {
    List<String> voices = await _tts.getVoiceByLang(languageCode!);
    if (voices.isNotEmpty) {
      return voices.first;
    }
    return null;
  }

  //Star the TTS.
  void speak() {
    if (languageCode != null) {
      _tts.setLanguage(languageCode!);
    }
    _tts.setVolume(1.0);
    _tts.speak(myController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
        appBar: AppBar(
            title: const Text('WiFi Scanner')
        ),
        body: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: myController,
            ),
            ElevatedButton(
                onPressed: speak,
                child: const Text("Text to Speech")
            )
          ],
        )
      )
    );
  }

}