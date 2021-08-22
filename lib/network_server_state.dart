import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sight_plus_plus/text_to_speech_state.dart';
import 'package:wifi_iot/wifi_iot.dart';

class NetworkState with ChangeNotifier{
  bool connected = false;
  static String ip = "";
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>();
  StreamSubscription? _connectionSub;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextToSpeechState tts = TextToSpeechState();

  void setConnected(bool connection) {
    connected = connection;
  }

  void initNetworkConnection(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin){
    if(_connectionSub == null){
      _connectionSub = startStream();
      _connectionStreamController.add(false);
      this.flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
    }
  }

  void initTextToSpeech({String languageCode = 'en'}){
    tts.initTextToSpeech(languageCode:languageCode);
  }

  void _showNotification(String payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    // I don't think we need to word about the first argument here. That's for communicating with FCM.
    AndroidNotificationDetails(
        'finder_001', 'Sight++ Finder', 'Alerts you if a Sight++ location is found',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        0, 'Location Found', 'Open To Connect', platformChannelSpecifics
        ,payload: payload);
    Future.delayed(const Duration(milliseconds: 60000), () async{
      String? ssid = await WiFiForIoTPlugin.getSSID();
      if(ssid == null || !ssid.contains("Sight++")){
        _connectionStreamController.add(false);
      }
    });
  }

  // We need to use this function whenever we want to send a new notification.
  // This erases the old notification are replaces it with a new one.
  // This is what we want so we don't just spam the user with notifications.
  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  StreamSubscription startStream() {
    return _connectionStreamController.stream.listen((event) async {
      print('Receive new result');
      if (!event) {
        ip = '';
        print('Connection failed. Scan again');
      } else {
        print('Connected');
      }
      Future.delayed(Duration(milliseconds: 3000), (){
        getConnection();
      });
    });
  }

  void getConnection() async {
    this.connected = false;
    bool connected = await WiFiForIoTPlugin.isConnected();
    if (connected) {
      String? ssid = await WiFiForIoTPlugin.getSSID();
      if (ssid != null && ssid.contains("Sight++")) {
        getIP();
        if(ip != ''){
          this.connected = true;
          notifyListeners();
          _connectionStreamController.add(true);
          return;
        }else{
          notifyListeners();
          _connectionStreamController.add(false);
          return;
        }
      }
    }
    notifyListeners();
    getSSID();
  }

  void connectToWifi(String ssid) async{
    try{
      bool networkFound = await WiFiForIoTPlugin.connect(ssid, password: 'liuzhaoxi', security: NetworkSecurity.WPA);
      if (!networkFound) {
        connected = false;
      } else {
        await WiFiForIoTPlugin.forceWifiUsage(true);
      }
      _connectionStreamController.add(false);
    }catch (exception){
      _connectionStreamController.add(false);
      print(exception);
    }

  }

  void getSSID() async {
    try {
      List<WifiNetwork> wifi = await WiFiForIoTPlugin.loadWifiList();
      for(var network in wifi){
        if(network.ssid.toString().contains("Sight++")){
          print('found');
          _cancelAllNotifications();
          _showNotification(network.ssid.toString());
          return;
        }
      }
      _connectionStreamController.add(false);
      //Replace the ssid and password to yours setting.
      //networkFound = await WiFiForIoTPlugin.connect("Sight++",password: "liuzhaoxi", security: NetworkSecurity.WPA);
      //If the network is public, use the following one.
      //networkFound = await WiFiForIoTPlugin.connect("YOUR_SSID");
    } catch (exception) {
      _connectionStreamController.add(false);
      print(exception);
    }
  }

  //This function can get the local server's IP through UDP broadcast.
  void getIP() async {
    try {
      var data = "Sight++";
      var codec = const Utf8Codec();
      var broadcastAddress = InternetAddress("255.255.255.255");
      List<int> dataToSend = codec.encode(data);
      //Bind socket to receive udp packets from any ip address.
      RawDatagramSocket.bind(InternetAddress.anyIPv4, 9999)
          .then((RawDatagramSocket socket) {
        socket.broadcastEnabled = true;
        socket.listen((event) async {
          try {
            Datagram? dg = socket.receive();
            if (dg != null) {
              //If the server responses with 'approve', store the server's ip.
              if (codec.decode(dg.data) == 'approve') {
                ip = dg.address.host;
                print(ip);
              }
            }
          } catch (exception) {
            ip = "";
            print(exception);
          }
        });
        //Send broadcast message.
        socket.send(dataToSend, broadcastAddress, 9999);
      });
    } catch (exception) {
      print(exception);
    }
  }

}
