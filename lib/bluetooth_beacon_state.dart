import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:sight_plus_plus/retry_interceptor.dart';
import 'package:sight_plus_plus/text_to_speech_state.dart';
import 'package:translator/translator.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter_beep/flutter_beep.dart';

import 'network_server_state.dart';



class BluetoothBeaconState with ChangeNotifier{
  List<Region> _regions = <Region>[];
  int _closestBeacon = -1;
  late StreamSubscription<RangingResult> _scanResultStream;
  int _lastFloor = 0;
  TextToSpeechState tts = TextToSpeechState();
  String autoMessage = '';
  String userMessage = '';
  StreamController<bool> _connectionStreamController = StreamController<bool>();
  bool isRunning = false;
  late Dio _dio;
  int lost = 0;
  bool _isHandling = false;


  void initBeaconScanner() async {
    try {
      BaseOptions options = BaseOptions(
          connectTimeout: 10000,
          receiveTimeout: 10000,
          sendTimeout: 10000);
      _dio = Dio(options);
      _dio.interceptors.add(RetryOnError(this));
      _regions = <Region>[];
      if(!_regions.contains(Region(identifier: 'jaalee'))){
        _regions.add(Region(identifier: 'jaalee'));
      }
      startStream();
      checkIP();
    } catch (e) {
      print(e);
    }
  }

  void initTextToSpeech({String languageCode = 'en-US'}){
    tts.initTextToSpeech(languageCode:languageCode);
  }

  void checkIP(){
    if(NetworkState.ip == ''){
      _connectionStreamController.add(false);
    }else{
      _connectionStreamController.add(true);
    }
  }

  void startStream() {
    _connectionStreamController.stream.listen((event) async {
      if (!event) {
        if(isRunning){
          print("Not scanning");
          stopScanning();
        }
      } else {
        if(!isRunning){
          print("Scanning");
          startScanning();
        }
      }
      Future.delayed(const Duration(milliseconds: 5000), (){
        checkIP();
      });
    });
  }

  void stopTTS(){
    tts.stop();
  }

  void startScanning(){
    isRunning = true;
    _scanResultStream = flutterBeacon.ranging(_regions).listen((RangingResult result) {
      if (result.beacons.isEmpty) {
        if(_closestBeacon != -1){
          print("No result, $_closestBeacon lost!");
          lost++;
        }
        if(lost > 9){
          _closestBeacon = -1;
          lost = 0;
        }
        return;
      }
      int tempBeacon = _closestBeacon;
      double tempAccuracy = -1.0;
      if(_closestBeacon != -1){
        for(var b in result.beacons){
          if(b.minor == _closestBeacon){
            if(b.accuracy <= 1.0 && b.accuracy > 0){
              tempAccuracy = b.accuracy;
            }
            break;
          }
        }
      }

      if((tempAccuracy == -1.0 || tempAccuracy >= 1.0) && _closestBeacon != -1){
        print("$_closestBeacon lost!");
        lost++;
        if(lost > 9){
          _closestBeacon = -1;
          lost = 0;
        }
      }else if(tempAccuracy != -1.0 && tempAccuracy <= 1.0){
        print("Find $_closestBeacon again.");
        lost = 0;
      }

      for (var b in result.beacons) {
        print(b.minor.toString() + ", " + b.accuracy.toString());
        if (_closestBeacon == -1) {
          if (b.accuracy > 0.0 && b.accuracy <= 1.0) {
            _closestBeacon = b.minor;
            tempAccuracy = b.accuracy;
          }
        } else {
          if(tempAccuracy != -1.0){
            if(b.accuracy < tempAccuracy){
              _closestBeacon = b.minor;
              tempAccuracy = b.accuracy;
            }
          }else if(b.accuracy > 0 && b.accuracy <= 1.0){
              _closestBeacon = b.minor;
          }
        }
      }

      if(NetworkState.ip != '' && tempBeacon != _closestBeacon && _closestBeacon != -1){
        print("http://${NetworkState.ip}:9999/notifications/$_closestBeacon?lastFloor=$_lastFloor");
        updateLocation();
      }
      notifyListeners();
    });
  }

  void updateLocation(){
      _dio.get("http://${NetworkState.ip}:9999/notifications/$_closestBeacon?lastFloor=$_lastFloor").then((response) async {
        if(response.statusCode == 200){
          FlutterBeep.beep();
          if(await Vibrate.canVibrate){
            Vibrate.vibrate();
          }
          _lastFloor = response.data['floor'];
          autoMessage = response.data['sentence'];
          tts.start(autoMessage);
        }else{
          tts.start("Server error");
        }
      });
  }

  void updateInfo(String data) async{
      _isHandling = true;
      print("http://${NetworkState.ip}:9999/questions/$closestBeacon?lastFloor=$lastFloor");
      await GoogleTranslator().translate(data, to: 'en').then((value) {
        data = value.text;
        var msg = {'question': data};
        return msg;
      }
      ).then((msg) async{
        _dio.post("http://${NetworkState
            .ip}:9999/questions/$closestBeacon?lastFloor=$lastFloor", data: msg)
            .then((response) async {
          if (response.statusCode == 200) {
            FlutterBeep.beep();
            if(await Vibrate.canVibrate){
              Vibrate.vibrate();
            }
            tts.start(response.data['sentence']);
            userMessage = response.data['sentence'];
          } else {
            tts.start('Server error');
          }
          _isHandling = false;
          notifyListeners();
        });
      });
  }

  void notifyFromError(){
    notifyListeners();
  }

  void stopScanning() {
    isRunning = false;
    _scanResultStream.cancel();
  }

  get scanResultStream => _scanResultStream;

  get regions => _regions;

  get closestBeacon => _closestBeacon;

  set setClosestBeacon(int closestBeacon) {
    _closestBeacon = closestBeacon;
  }

  StreamController<bool> get connectionStreamController =>
      _connectionStreamController;

  set setConnectionStreamController(StreamController<bool> value) {
    _connectionStreamController = value;
  }

  get lastFloor => _lastFloor;

  Dio get dio => _dio;

  get isHandling => _isHandling;

  set setIsHandling(bool isHandling){
    _isHandling = isHandling;
  }

  set setDio(Dio value) {
    _dio = value;
  }
}
