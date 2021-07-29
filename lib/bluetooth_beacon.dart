import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';


void main() {
  runApp(BluetoothBeaconTest());
}
class BluetoothBeaconTest<T> extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return BluetoothBeaconTestState();
  }

}
class BluetoothBeaconTestState extends State<BluetoothBeaconTest> {
  var regions = <Region>[];
  late Beacon? closestBeacon = null;
  var _stream;

  @override
  void initState(){
    super.initState();
    getInfo();
  }

  void getInfo() async{
    try {
      print(await flutterBeacon.initializeScanning);
      regions.add(Region(identifier: 'jaalee'));
      _stream = flutterBeacon.ranging(regions).listen((RangingResult result) {
        if(result.beacons.isEmpty){
          return;
        }
        setState(() {
          closestBeacon = null;
          for(var b in result.beacons){
            print(b.minor.toString()+", "+b.accuracy.toString());
            if(closestBeacon == null){
              if(b.accuracy > 0.0 && b.accuracy <= 0.3){
                closestBeacon = b;
              }
            }else if(closestBeacon!.accuracy > b.accuracy && b.accuracy > 0.0 && b.accuracy <= 0.4){
              closestBeacon = b;
            }
          }
        });
      });
    } catch(e) {
      print(e);
    }
  }

  void stopScanning(){
    _stream.cancel();
  }

  Widget getText(){
    if(closestBeacon == null){
      return Text("Error");
    }
    return Text(closestBeacon!.major.toString()+", "+closestBeacon!.minor.toString()+", "+closestBeacon!.accuracy.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Bluetooth Beacon Test"),
        ),
        body:getText()
      )
    );
  }
}