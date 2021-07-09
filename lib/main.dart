import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
class WifiScan extends StatefulWidget{
  @override
  WifiScanState createState() => WifiScanState();
}

class WifiScanState extends State<WifiScan>{
  late final channel;
  bool _initialised = false;
  bool _error = false;
  List<WifiNetwork?> _htResultNetwork = [];
  late String ip;
  StreamController<bool> _connectionStreamController = StreamController<bool>();
  late Stream _connectionStream;
  late StreamSink _connectionSink;


  void initialiseFlutterFire() async{
    try{
      await Firebase.initializeApp();
      setState(() {
        _initialised = true;
      });
    }catch(e){
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void dispose(){
    super.dispose();
  }

  void getConnection() async{
    bool result = false;
    bool connected = await WiFiForIoTPlugin.isConnected();
    if(connected){
      String? name = await WiFiForIoTPlugin.getSSID();
      if(name != null && name.contains("Sight++")){
        result = true;
      }
    }
    _connectionSink.add(result);
  }

  @override
  void initState(){
    initialiseFlutterFire();
    _connectionStream = _connectionStreamController.stream;
    _connectionSink = _connectionStreamController.sink;
    _connectionStream.listen((event) async {
      print('Receive new result');
      if(!event){
        print('Connection failed. Scan again');
        Future.delayed(const Duration(milliseconds: 5000), (){
          loadWifiList();
        });
      }else{
        print('Connected');
        Future.delayed(const Duration(milliseconds: 5000),(){
          getConnection();
        });
      }
    });
    loadWifiList();
    super.initState();
    //_checkStatus();
  }

  void getIP(){
    var data = "Sight++";
    var codec = new Utf8Codec();
    var broadcastAddress = InternetAddress("255.255.255.255");
    List<int> dataToSend = codec.encode(data);
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9999).then((RawDatagramSocket socket){
      socket.broadcastEnabled = true;
      socket.listen((event) async {
        Datagram? dg = socket.receive();
        if(dg != null){
          if(codec.decode(dg.data) == 'approve'){
            ip = dg.address.host;
            print(ip);
            try {
              var response = await Dio().get('http://'+ip+":9999/listUsers");
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

  void loadWifiList() async {
      print('Start scanning...');
      List<WifiNetwork> htResultNetwork;
      bool networkFound = false;
      try {
        htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
        for(var network in htResultNetwork){
          if(network.ssid.toString().contains("Sight++")){
              WiFiForIoTPlugin.forceWifiUsage(true);
              networkFound = true;
              if(await WiFiForIoTPlugin.connect(network.ssid.toString(), password:"liuzhaoxi", security: NetworkSecurity.WPA)){
                getIP();
                _connectionSink.add(true);
                break;
              }else{
                _connectionSink.add(false);
              }
            }
        }
        if(!networkFound){
          _connectionSink.add(false);
        }
      } on PlatformException {
        htResultNetwork = <WifiNetwork>[];
      }
      setState(() {
        _htResultNetwork = htResultNetwork;
      });
  }

  void _sendMessage(){
    var data = "Sight++";
    var codec = new Utf8Codec();
    var broadcastAddress = InternetAddress("255.255.255.255");
    List<int> dataToSend = codec.encode(data);
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9999).then((RawDatagramSocket socket){
      socket.broadcastEnabled = true;
      socket.send(dataToSend, broadcastAddress, 9999);
    });
  }


  Widget _buildNames(){
      return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _htResultNetwork.length,
        itemBuilder: (context, i){
          if(i.isOdd){
            return new Divider();
          }
          final index = i ~/ 2;
          return Text(_htResultNetwork[index]!.ssid.toString()+','+_htResultNetwork[index]!.level.toString());
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    if(_error){
      print('Firebase initialisation failed!');
      return new Scaffold(
        appBar: new AppBar(
          title:new Text("Firebase initialisation failed!")
        )
      );
    }

    if(!_initialised){
      return new Scaffold(
          appBar: new AppBar(
              title:new Text("Loading...")
          )
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Wifi Names")
      ),
      body: _buildNames(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _sendMessage
              /*() async {
            //WiFiForIoTPlugin.forceWifiUsage(true);
            //bool a = await WiFiForIoTPlugin.connect("Sight++", password:"liuzhaoxi", security: NetworkSecurity.WPA);

          }*/
      ),

    );
  }

}