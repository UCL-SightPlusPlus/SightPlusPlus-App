import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MaterialApp(
          home: Scaffold(
            body: Center(
              child: WifiScan(),
            ),
          )
      )
  );
}

//Scanning the WiFi in the area and connect to the one which SSID contains "Sight++"
class WifiScan extends StatefulWidget {
  @override
  WifiScanState createState() => WifiScanState();
}

class WifiScanState extends State<WifiScan> {
  List<WifiNetwork?> _htResultNetwork = [];
  late String ip;
  StreamController<bool> _connectionStreamController = StreamController<bool>();
  late Stream _connectionStream;
  late StreamSink _connectionSink;

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
    getConnection();
    getIP();
    super.initState();
    activateSpeechRecognizer();
    //_checkStatus();
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
            ip = dg.address.host;
            print(ip);
            try {
              var data = {'id': '1234'};
              var response =
                  await Dio().post('http://' + ip + ":9999/add", data: data);
              print(response);
            } catch (e) {
              print(e);
            }
          }
        }
      });
      socket.send(dataToSend, broadcastAddress, 9999);
    });
  }

  //Scan the WiFi
  void connectToWifi() async {
    print('Start scanning...');
    List<WifiNetwork> htResultNetwork = <WifiNetwork>[];
    bool networkFound = false;
    try {
      WiFiForIoTPlugin.forceWifiUsage(true);
      networkFound = await WiFiForIoTPlugin.connect("Sight++",
          password: "liuzhaoxi", security: NetworkSecurity.WPA);
      if (!networkFound) {
        _connectionSink.add(false);
      } else {
        getIP();
        _connectionSink.add(true);
      }
    } catch (exception){
      print(exception);
    }
  }

  late SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = 'No text';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;

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
        _isListening = result;
      });
    });
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
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.grey.shade200,
                            child: Text(transcription)),
                      ),
                      ElevatedButton(
                        onPressed: _speechRecognitionAvailable && !_isListening
                            ? () => start()
                            : null,
                        child: Text(
                          _isListening
                              ? 'Listening...'
                              : 'Listen (${selectedLang.code})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
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

class VoiceCommand extends StatefulWidget {
  @override
  VoiceCommandState createState() => VoiceCommandState();
}

var languages = [
  Language('English', 'en_US'),
  Language('Francais', 'fr_FR'),
  Language('Pусский', 'ru_RU'),
  Language('Italiano', 'it_IT'),
  Language('Español', 'es_ES'),
];

class VoiceCommandState extends State<VoiceCommand> {
  late SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = 'No text';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
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
            _isListening = result;
          });
        });
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
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey.shade200,
                    child: Text(transcription)),
              ),
              ElevatedButton(
                onPressed: _speechRecognitionAvailable && !_isListening
                    ? () => start()
                    : null,
                child: Text(
                  _isListening
                      ? 'Listening...'
                      : 'Listen (${selectedLang.code})',
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ))),
    ));
  }
}
