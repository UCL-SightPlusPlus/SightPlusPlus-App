// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sight_plus_plus/bluetooth_beacon_state.dart';
import 'package:sight_plus_plus/retry_interceptor.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  BaseOptions options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 10000,
      sendTimeout: 10000);




  test('When the closestBeacon is -1', () async {
    var bluetoothBeacon = BluetoothBeaconState();
    var dio = Dio(options);
    dio.interceptors.add(RetryOnError(bluetoothBeacon));
    var dioAdapter = DioAdapter(dio:dio);
    dioAdapter.onPost("http://:9999/questions/-1?lastFloor=0", (server) {
      server.reply(400, 'Error');
    });

    bluetoothBeacon.initBeaconScanner();
    Future.delayed(const Duration(milliseconds: 1000), () {
      bluetoothBeacon.setDio = dio;
      bluetoothBeacon.updateInfo('how many seats');
    });
    Future.delayed(const Duration(milliseconds: 1000), (){
      expect(bluetoothBeacon.userMessage, '');
    });
  });

  test('When the lastFloor is not changed', () async {
    var bluetoothBeacon = BluetoothBeaconState();
    var dio = Dio(options);
    dio.interceptors.add(RetryOnError(bluetoothBeacon));
    var dioAdapter = DioAdapter(dio:dio);
    dioAdapter.onGet("http://:9999/notifications/1?lastFloor=0", (server) {
      var data = {'floor' : 0, 'sentence':'You are on the same floor'};
      server.reply(200, data);
    });
    bluetoothBeacon.initBeaconScanner();
    Future.delayed(const Duration(milliseconds: 2000), () {
      bluetoothBeacon.setClosestBeacon = 1;
      bluetoothBeacon.setDio = dio;
      bluetoothBeacon.updateLocation();
    });
    Future.delayed(const Duration(milliseconds: 2000), (){
      expect(bluetoothBeacon.lastFloor, 0);
      expect(bluetoothBeacon.autoMessage, 'You are on the same floor');
    });
  });

  test('When the lastFloor is changed', () async {
    var bluetoothBeacon = BluetoothBeaconState();
    var dio = Dio(options);
    dio.interceptors.add(RetryOnError(bluetoothBeacon));
    var dioAdapter = DioAdapter(dio:dio);
    dioAdapter.onPost("http://:9999/questions/1?lastFloor=0", (server) {
      var data = {'sentence':'There are 100 seats'};
      server.reply(200, data);
    });
    bluetoothBeacon.initBeaconScanner();
    Future.delayed(const Duration(milliseconds: 1000), () {
      bluetoothBeacon.setClosestBeacon = 1;
      bluetoothBeacon.setDio = dio;
      bluetoothBeacon.updateLocation();
    });
    Future.delayed(const Duration(milliseconds: 1000), (){
      expect(bluetoothBeacon.lastFloor, 2);
      expect(bluetoothBeacon.autoMessage, 'You are on the the 2nd floor');
    });
  });

  test('When the closestBeacon is not -1', () async {
    var bluetoothBeacon = BluetoothBeaconState();
    var dio = Dio(options);
    dio.interceptors.add(RetryOnError(bluetoothBeacon));
    var dioAdapter = DioAdapter(dio:dio);
    dioAdapter.onGet("http://:9999/notifications/1?lastFloor=1", (server) {
      var data = {'floor' : 2, 'sentence':'You are on the 2nd floor'};
      server.reply(200, data);
    });
    bluetoothBeacon.initBeaconScanner();
    Future.delayed(const Duration(milliseconds: 1000), (){
      bluetoothBeacon.setClosestBeacon = 1;
      bluetoothBeacon.setDio = dio;
      bluetoothBeacon.updateInfo('how many seats');
    });
    Future.delayed(const Duration(milliseconds: 1000), (){
      expect(bluetoothBeacon.userMessage, 'There are 100 seats');
    });
  });
}
