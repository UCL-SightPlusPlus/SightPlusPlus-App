import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wifi_iot/wifi_iot.dart';

class NetworkState with ChangeNotifier{
  bool connected = false;
  static String ip = "";
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>();
  late StreamSink _connectionSink;
  late Stream _connectionStream;

  void setConnected(bool connection) {
    connected = connection;
  }

  void initNetworkConnection(){
    _connectionStream = _connectionStreamController.stream;
    _connectionSink = _connectionStreamController.sink;
    startStream();
    getConnection();
  }

  void startStream() {
    _connectionStream.listen((event) async {
      print('Receive new result');
      if (!event) {
        print('Connection failed. Scan again');
      } else {
        print('Connected');
      }
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 5000), () {
        getConnection();
      }).then((value) => print("Finished"));
    });
  }

  void getConnection() async {

    this.connected = false;
    bool connected = await WiFiForIoTPlugin.isConnected();
    if (connected) {
      String? ssid = await WiFiForIoTPlugin.getSSID();
      if (ssid != null && ssid.contains("Sight++") && ip != '') {
        this.connected = true;
        _connectionSink.add(true);
      }else{
        ip = "";
      }
    }
    connectToWifi();
  }

  void connectToWifi() async {
    if (connected) {
      return;
    }
    bool networkFound = false;
    try {
      //Replace the ssid and password to yours setting.
      networkFound = await WiFiForIoTPlugin.connect("Sight++",
          password: "liuzhaoxi", security: NetworkSecurity.WPA);
      //If the network is public, use the following one.
      //networkFound = await WiFiForIoTPlugin.connect("YOUR_SSID");
      if (!networkFound) {
        connected = false;
        _connectionSink.add(false);
      } else {
        await WiFiForIoTPlugin.forceWifiUsage(true);
        getIP();
      }
    } catch (exception) {
      _connectionSink.add(false);
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
                _connectionSink.add(true);
              }
            }
          } catch (exception) {
            ip = "";
            _connectionSink.add(false);
            print(exception);
          }
        });
        //Send broadcast message.
        socket.send(dataToSend, broadcastAddress, 9999);
      });
    } catch (exception) {
      _connectionSink.add(false);
      print(exception);
    }
  }

  void updateInfo({required int lastFloor, data}) {
    if(data != null){
      print(data);
      Dio().post("http://" + ip + ":9999/records", data: data);
    }else{
      Dio().get("http://" + ip + ":9999/records?lastFloor="+lastFloor.toString()).then((response) {
        print(response.data);
      });
    }
  }

}
