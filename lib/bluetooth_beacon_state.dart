import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

class BluetoothBeaconState with ChangeNotifier {
  final _regions = <Region>[];
  late Beacon? _closestBeacon;
  late StreamSubscription<RangingResult> _stream;

  void getInfo() async {
    try {
      print(await flutterBeacon.initializeScanning);
      _regions.add(Region(identifier: 'jaalee'));
      _stream = flutterBeacon.ranging(_regions).listen((RangingResult result) {
        if (result.beacons.isEmpty) {
          return;
        }
        _closestBeacon = null;
        for (var b in result.beacons) {
          print(b.minor.toString() + ", " + b.accuracy.toString());
          if (_closestBeacon == null) {
            if (b.accuracy > 0.0 && b.accuracy <= 0.3) {
              _closestBeacon = b;
            }
          } else if (_closestBeacon!.accuracy > b.accuracy &&
              b.accuracy > 0.0 &&
              b.accuracy <= 0.4) {
            _closestBeacon = b;
          }
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  void stopScanning() {
    _stream.cancel();
  }

  get stream => _stream;
  get regions => _regions;
  get cloestBeacon => _closestBeacon;
}
