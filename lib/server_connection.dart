import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ServerConnectionTest());
}

class ServerConnectionTest extends StatefulWidget {
  ServerConnectionTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ServerConnectionState();
  }
}

class ServerConnectionState extends State<ServerConnectionTest> {
  String ip = "";
  StreamController<bool> _connectionStreamController = StreamController<bool>();
  late Stream _connectionStream;
  late StreamSink _connectionSink;
  final myController = TextEditingController();

  //Check the WiFi is connected or not
  void getConnection() async {
    bool result = false;
    bool connected = await WiFiForIoTPlugin.isConnected();
    if (connected) {
      String? name = await WiFiForIoTPlugin.getSSID();
      if (name != null && name.contains("Sight++") && ip != '') {
        result = true;
      }
    }
    _connectionSink.add(result);
  }

  @override
  void initState() {
    //Create the listener for WiFi and server connection.
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
  }

  void sendMessage(bool isPost) async {
    var response;
    if(isPost){
      var data = {'message': myController.text};
      response = await Dio().post("http://" + ip + ":9999/testPost", data:data);
    }else{
      response = await Dio().get("http://" + ip + ":9999/testGet");
    }
    if(response != null){
      print(response.data.toString());
    }
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
    try {
      print('Try to get ip...');
      var data = "Sight++";
      var codec = const Utf8Codec();
      var broadcastAddress = InternetAddress("255.255.255.255");
      List<int> dataToSend = codec.encode(data);
      //Bind socket to receive udp packets from any ip address.
      RawDatagramSocket.bind(InternetAddress.anyIPv4, 9999)
          .then((RawDatagramSocket socket) {
        socket.broadcastEnabled = true;
        socket.listen((event) async {
          Datagram? dg = socket.receive();
          if (dg != null) {
            //If the server responses with 'approve', store the server's ip.
            if (codec.decode(dg.data) == 'approve') {
              setState(() {
                ip = dg.address.host;
                _connectionSink.add(true);
              });
            }
          }
        });
        //Send broadcast message.
        socket.send(dataToSend, broadcastAddress, 9999);
      });
    } catch (exception) {
      print(exception);
    }
  }

  //Scan the WiFi
  void connectToWifi() async {
    print('Start scanning...');
    bool networkFound = false;
    try {
      //Replace the ssid and password to yours setting.
      networkFound = await WiFiForIoTPlugin.connect("YOUR_SSID",
          password: "YOUR_PASSWORD", security: NetworkSecurity.WPA);
      //If the network is public, use the following one.
      //networkFound = await WiFiForIoTPlugin.connect("YOUR_SSID");
      if (!networkFound) {
        _connectionSink.add(false);
      } else {
        WiFiForIoTPlugin.forceWifiUsage(true);
        getIP();
      }
    } catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
    Text(ip),
    ElevatedButton(
    onPressed: connectToWifi,
    child: const Text('Connect to WiFi'),
    ),
              ElevatedButton(
                onPressed: () => sendMessage(true),
                child: const Text('Send Post Request'),
              ),
              ElevatedButton(
                onPressed: () => sendMessage(false),
                child: const Text('Send Get Request'),
              ),
    ],
    ),

    )
    );
  }

}