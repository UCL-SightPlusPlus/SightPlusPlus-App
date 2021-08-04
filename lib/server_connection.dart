import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'network_server_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => NetworkState(),
      child: ServerConnectionTest(),
  ));
}

class ServerConnectionTest extends StatefulWidget {
  ServerConnectionTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ServerConnectionState();
  }
}

class ServerConnectionState extends State<ServerConnectionTest> {
  final myController = TextEditingController();

  @override
  void initState() {
    print("init");
    super.initState();
    Provider.of<NetworkState>(context, listen:false).startStream();
    Provider.of<NetworkState>(context, listen:false).getConnection();
  }

  //Get the server's ip using udp broadcast
  // void getIP() async {
  //   bool connected = await WiFiForIoTPlugin.isConnected();
  //   if (!connected) {
  //     return;
  //   } else {
  //     String? name = await WiFiForIoTPlugin.getSSID();
  //     if (name == null || !name.contains("Sight++")) {
  //       return;
  //     }
  //   }
  //   try {
  //     print('Try to get ip...');
  //     var data = "Sight++";
  //     var codec = const Utf8Codec();
  //     var broadcastAddress = InternetAddress("255.255.255.255");
  //     List<int> dataToSend = codec.encode(data);
  //     //Bind socket to receive udp packets from any ip address.
  //     RawDatagramSocket.bind(InternetAddress.anyIPv4, 9999)
  //         .then((RawDatagramSocket socket) {
  //       socket.broadcastEnabled = true;
  //       socket.listen((event) async {
  //         Datagram? dg = socket.receive();
  //         if (dg != null) {
  //           //If the server responses with 'approve', store the server's ip.
  //           if (codec.decode(dg.data) == 'approve') {
  //             setState(() {
  //               ip = dg.address.host;
  //               _connectionSink.add(true);
  //             });
  //           }
  //         }
  //       });
  //       //Send broadcast message.
  //       socket.send(dataToSend, broadcastAddress, 9999);
  //     });
  //   } catch (exception) {
  //     print(exception);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("WiFi and Server Connection"),
        ),
        body: Column(
          children: [
            Text(Provider.of<NetworkState>(context).ip),
            ElevatedButton(
                onPressed: (){
                  Provider.of<NetworkState>(context, listen: false).sendRequest();
                },
                child: Text("Update")
            )
          ]
        ),
      )
    );
  }
}
