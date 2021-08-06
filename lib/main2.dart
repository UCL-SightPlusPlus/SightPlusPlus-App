import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sight_plus_plus/bluetooth_beacon_state.dart';
import 'package:sight_plus_plus/network_server_state.dart';
import 'package:sight_plus_plus/speech_to_text_state.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => NetworkState(),
      ),
      ChangeNotifierProvider(
        create: (context) => SpeechToTextState(),
      ),
    ],
    child: SightPlusPlusApp()
    )
  );
}

class SightPlusPlusApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SightPlusPlusAppState();
  }
}

class SightPlusPlusAppState extends State<SightPlusPlusApp> {
  BluetoothBeaconState beacon = BluetoothBeaconState();
  SpeechToTextState speech = SpeechToTextState();

  @override
  void initState() {
    super.initState();
    Provider.of<NetworkState>(context, listen: false).initNetworkConnection();
    Provider.of<SpeechToTextState>(context, listen: false).initiateSpeechToText();
    beacon.initBeaconScanner();
  }

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
              title: const Text("Sight++")
          ),
          body: TestButton(beacon),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Provider.of<NetworkState>(context, listen: false).getConnection(),
          ),
          ),
        );
  }

}

class TestButton extends StatelessWidget{
  BluetoothBeaconState beacon;
  TestButton(this.beacon);

  @override
  Widget build(BuildContext context) {
    return Provider<bool>.value(
        value: Provider.of<NetworkState>(context).connected,
        builder: (BuildContext context, Widget? child) {
          print('Rebuild');
          if(Provider.of<NetworkState>(context).connected){
            return Provider<bool>.value(
                value: Provider.of<SpeechToTextState>(context).canStart,
                builder: (BuildContext context, Widget? child) {
                  if(Provider.of<SpeechToTextState>(context).canStart || Provider.of<SpeechToTextState>(context).isListening){
                    return GestureDetector(
                        onTapDown: (details) {
                          beacon.stopTTS();
                          Provider.of<SpeechToTextState>(context, listen: false).start();
                        },
                        onTapUp: (details) {
                          Provider.of<SpeechToTextState>(context, listen: false).stop();
                          if(Provider.of<SpeechToTextState>(context, listen: false).transcription != ''){
                            var data = {'message':Provider.of<SpeechToTextState>(context, listen: false).transcription};
                            Provider.of<NetworkState>(context, listen: false).updateInfo(lastFloor: beacon.lastFloor, data: data);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).buttonColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(Provider.of<SpeechToTextState>(context).isListening ? 'Listening...':'My Button'),
                        )
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).buttonColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text('STT Not Available'),
                  );
                }
            );
          }
          return const Text("Not Connected To The Server");
        },
    );
  }

}
