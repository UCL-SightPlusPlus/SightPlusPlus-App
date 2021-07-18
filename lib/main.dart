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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  } else if (Platform.isAndroid) {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  }
  runApp(SightPlusPlus());
}

//Scanning the WiFi in the area and connect to the one which SSID contains "Sight++"
class SightPlusPlus extends StatefulWidget {
  @override
  SightPlusPlusState createState() => SightPlusPlusState();
}

class SightPlusPlusState extends State<SightPlusPlus> {
  List<WifiNetwork?> _htResultNetwork = [];
  String ip = "";
  StreamController<bool> _connectionStreamController = StreamController<bool>();
  late Stream _connectionStream;
  late StreamSink _connectionSink;
  late SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String transcription = '';
  String serverMessage = '';
  Language selectedLang = languages.first;
  late TextToSpeech _tts;

  /// language
  String? language;
  String? languageCode;
  List<String> languageCodes = [];

  /// voice
  String? voice;

  @override
  void dispose() {
    super.dispose();
  }

  //Check the WiFi is connected or not
  void getConnection() async {
    bool result = false;
    bool connected = await WiFiForIoTPlugin.isConnected();
    if (connected) {
      String? name = await WiFiForIoTPlugin.getSSID();
      if (name != null && name.contains("Sight++")) {
        result = true;
      }
    }
    _connectionSink.add(result);
  }

  @override
  void initState() {
    _connectionStream = _connectionStreamController.stream;
    _connectionSink = _connectionStreamController.sink;
    _connectionStream.listen((event) async {
      print('Receive new result');
      if (!event) {
        setState(() {
          ip = "";
        });
        print('Connection failed. Scan again');
        Future.delayed(const Duration(milliseconds: 5000), () {
          connectToWifi();
        });
      } else {
        print('Connected');
        Future.delayed(const Duration(milliseconds: 5000), () {
          getConnection();
        });
      }
    });
    super.initState();
    activateSpeechRecognizer();
    getConnection();
    getIP();
    _tts = TextToSpeech();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initLanguages();
    });
  }

  Future<void> initLanguages() async {
    /// populate lang code (i.e. en-US)
    languageCodes = await _tts.getLanguages();

    /// get default language
    final String? defaultLangCode = await _tts.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = languages.first.code;
    }

    /// get voice
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

  void speak() {
    if (languageCode != null) {
      _tts.setLanguage(languageCode!);
    }
    _tts.speak(serverMessage);
  }

  //Get the server's ip using udp broadcast
  void getIP() async {
    bool connected = await WiFiForIoTPlugin.isConnected();
    if (!connected) {
      return;
    } else {
      String? name = await WiFiForIoTPlugin.getSSID();
      if (name == null || !name.contains("Sight++")) {
        return;
      }
    }
    print('Try to get ip...');
    var data = "Sight++";
    var codec = new Utf8Codec();
    var broadcastAddress = InternetAddress("255.255.255.255");
    List<int> dataToSend = codec.encode(data);
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9999)
        .then((RawDatagramSocket socket) {
      socket.broadcastEnabled = true;
      socket.listen((event) async {
        Datagram? dg = socket.receive();
        if (dg != null) {
          if (codec.decode(dg.data) == 'approve') {
            setState(() {
              ip = dg.address.host;
            });
          }
        }
      });
      socket.send(dataToSend, broadcastAddress, 9999);
    });
  }

  //Scan the WiFi
  void connectToWifi() async {
    print('Start scanning...');
    bool networkFound = false;
    try {
      networkFound = await WiFiForIoTPlugin.connect("Sight++",
          password: "liuzhaoxi", security: NetworkSecurity.WPA);
      if (!networkFound) {
        _connectionSink.add(false);
      } else {
        WiFiForIoTPlugin.forceWifiUsage(true);
        getIP();
        _connectionSink.add(true);
      }
    } catch (exception) {
      print(exception);
    }
  }

  void activateSpeechRecognizer() {
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

  void errorHandler() => activateSpeechRecognizer();

  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      .map((l) => CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: Text(l.name),
          ))
      .toList();

  void start() => _speech.activate(selectedLang.code).then((_) {
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
        if (transcription != "") {
          var data = {'message': transcription};
          var response =
              await Dio().post("http://" + ip + ":9999/add", data: data);
          setState(() {
            serverMessage = response.data.toString();
            speak();
          });
        }
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("Speech Recognition"),
        actions: <Widget>[
          PopupMenuButton<Language>(
            icon: const Icon(Icons.control_point),
            itemBuilder: (BuildContext context) => _buildLanguagesWidgets,
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 15.0),
                  child: Text(transcription),
                  decoration: BoxDecoration(border: Border.all())),
              Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 15.0),
                  child: Text(serverMessage),
                  decoration: BoxDecoration(border: Border.all())),
              GestureDetector(
                onTapDown: (details) =>
                    _speechRecognitionAvailable && !_isListening && ip != ""
                        ? start()
                        : null,
                onTapUp: (details) {
                  stop();
                },
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).buttonColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text('My Button'),
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

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

var languages = [
  Language('English', 'en_US'),
  Language('Francais', 'fr_FR'),
  Language('Pусский', 'ru_RU'),
  Language('Italiano', 'it_IT'),
  Language('Español', 'es_ES'),
];
