import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wifi_iot/wifi_iot.dart';

class NetworkState with ChangeNotifier{
  bool connected = false;
  static String ip = "";
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>(); // a stream to get server connection state
  StreamSubscription? _connectionSub;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;// the push notification plugin
  bool notificationTouched = false;// the notification has been pressed or not

  void initNetworkConnection(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin){
    if(_connectionSub == null){
      _connectionSub = startStream();
      _connectionStreamController.add(false);
      this.flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
    }
  }

  //push notification
   _showNotification(String payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
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

    //if the notification is not pressed in 20 seconds, send a false message to the stream
    //which means the connection failed
    Future.delayed(const Duration(milliseconds: 20000), () async{
      if(!notificationTouched){
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

  //start handling the messages in the stream
  StreamSubscription startStream() {
    return _connectionStreamController.stream.listen((event) async {
      print('Receive new result');
      if (!event) {
        //if not connected to the server, reset the IP to empty
        ip = '';
        print('Connection failed. Scan again');
      } else {
        print('Connected');
      }
      //check the connectivity every 3 seconds
      Future.delayed(Duration(milliseconds: 3000), (){
        getConnection();
      });
    });
  }

  void stopStream(){
    _connectionSub!.cancel();
  }

  //check the connectivity
  void getConnection() async {
    this.connected = false;
    bool connected = await WiFiForIoTPlugin.isConnected();
    if (connected) {
      //if connected to the WiFi
      String? ssid = await WiFiForIoTPlugin.getSSID();
      if (ssid != null && ssid.contains("Sight++")) {
        //if the SSID contains "Sight++"
        if(ip != ''){
          //if the IP is not empty(connected to the server)
          this.connected = true;
          notifyListeners();
          _connectionStreamController.add(true);
          return;
        }else{
          //if the server is not connected, get the IP
          _getIP();
          notifyListeners();
          _connectionStreamController.add(false);
          return;
        }
      }
    }
    notifyListeners();
    //if not connected to the WiFi, scanning the WiFi and connect
    getSSID();
  }

  //connect to the WiFi after the notification is pressed
  void connectToWifi(String ssid) async{
    try{
      notificationTouched = true;
      //change the password and security type if you have one
      bool networkFound = await WiFiForIoTPlugin.connect(ssid, password: 'YOURPASSWORD', security: NetworkSecurity.WPA);
      //if you are using an open WiFi, use the following code
      //bool networkFound = await WiFiForIoTPlugin.connect(ssid);
      if (!networkFound) {
        connected = false;
      }
      _connectionStreamController.add(false);
    }catch (exception){
      _connectionStreamController.add(false);
      print(exception);
    }

  }

  //scan the WiFi and get the list of SSID
  void getSSID() async {
    try {
      notificationTouched = false;
      List<WifiNetwork> wifi = await WiFiForIoTPlugin.loadWifiList();
      for(var network in wifi){
        if(network.ssid.toString().contains("Sight++")){
          print('found');
          _cancelAllNotifications();
          //push a notification to let the user connect to the Sight++ WiFi
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
  void _getIP() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
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
