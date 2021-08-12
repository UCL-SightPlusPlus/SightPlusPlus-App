import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:sight_plus_plus/text_to_speech_state.dart';

import 'network_server_state.dart';



class BluetoothBeaconState with ChangeNotifier{
  List<Region> _regions = <Region>[];
  int _closestBeacon = -1;
  late StreamSubscription<RangingResult> _scanResultStream;
  int _lastFloor = 0;
  TextToSpeechState tts = TextToSpeechState();
  String autoMessage = '';
  String userMessage = '';
  final StreamController<bool> _connectionStreamController = StreamController<bool>();
  bool isRunning = false;


  void initBeaconScanner() async {
    try {

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

  void initTextToSpeech({String languageCode = 'en'}){
    tts.initTextToSpeech(languageCode:languageCode);
  }

  void checkIP(){
    if(NetworkState.ip == ''){
      print("Stop bluetooth");
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
        Dio().get("http://${NetworkState.ip}:9999/notifications/$_closestBeacon?lastFloor=$_lastFloor").then((response){
          _lastFloor = response.data['floor'];
          autoMessage = response.data['sentence'];
          tts.start(autoMessage);
        });
      }
      notifyListeners();
    });
  }

  void updateInfo(data){
    Dio().post("http://${NetworkState.ip}:9999/questions/$closestBeacon?lastFloor=$lastFloor", data: data).then((response) {
      tts.start(response.data['sentence']);
      userMessage = response.data['sentence'];
      notifyListeners();
    });
  }

  void stopScanning() {
    isRunning = false;
    _scanResultStream.cancel();
  }

  get scanResultStream => _scanResultStream;

  get regions => _regions;

  get closestBeacon => _closestBeacon;

  get lastFloor => _lastFloor;
}
