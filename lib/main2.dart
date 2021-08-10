import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sight_plus_plus/bluetooth_beacon_state.dart';
import 'package:sight_plus_plus/network_server_state.dart';
import 'package:sight_plus_plus/speech_to_text_state.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi_iot/wifi_iot.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in  the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final StreamController<String?> selectNotificationSubject =
StreamController<String?>();

const MethodChannel platform =
MethodChannel('sightplusplus');

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = Platform
      .isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    // When the app opens from the notification the payload is printed.
    // We could potentially use this for determining when the app opens.
    print("Payload: "+selectedNotificationPayload.toString());
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload,
          ) async {
        didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      });
  const MacOSInitializationSettings initializationSettingsMacOS =
  MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );

  // This just makes it so that the notification can appear in when the app is open.
  // But we won't actually do this, this is just for demo purposes.
  // Comment this function out to make notifications appear when the app is
  // running not open, but running in the background
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
        selectedNotificationPayload = payload;
        selectNotificationSubject.add(payload);
      });

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => NetworkState(),
      ),
      ChangeNotifierProvider(
        create: (context) => SpeechToTextState(),
      ),
    ],
    child: MaterialApp(
      routes: {
        '/':(context) => SightPlusPlusApp(),
      },
    )
    )
  );
}

Future<void> _configureLocalTimeZone() async {
  if (Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

class SightPlusPlusApp extends StatefulWidget {
  const SightPlusPlusApp({Key? key, this.notificationAppLaunchDetails}) : super(key: key);

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  State<StatefulWidget> createState() {
    return SightPlusPlusAppState();
  }
}

class SightPlusPlusAppState extends State<SightPlusPlusApp> {
  BluetoothBeaconState beacon = BluetoothBeaconState();
  SpeechToTextState speech = SpeechToTextState();


  @override
  void initState(){
    super.initState();
    _requestPermissions();
    _configureSelectNotificationSubject();

    Provider.of<NetworkState>(context, listen: false).initNetworkConnection(flutterLocalNotificationsPlugin);
    Provider.of<SpeechToTextState>(context, listen: false).initiateSpeechToText();
    beacon.initBeaconScanner();
  }


  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
          print("Title: "+receivedNotification.title.toString());
      await showDialog(
        context: context,
        builder: (BuildContext context) =>
            CupertinoAlertDialog(
              title: receivedNotification.title != null
                  ? Text(receivedNotification.title!)
                  : null,
              content: receivedNotification.body != null
                  ? Text(receivedNotification.body!)
                  : null,
              // actions: <Widget>[
              //   CupertinoDialogAction(
              //     isDefaultAction: true,
              //     onPressed: () async {
              //       Navigator.of(context, rootNavigator: true).pop();
              //       await Navigator.push(
              //         context,
              //         MaterialPageRoute<void>(
              //           builder: (BuildContext context) =>
              //               SightPlusPlusApp(notificationAppLaunchDetails: widget.notificationAppLaunchDetails,),
              //         ),
              //       );
              //     },
              //     child: const Text('Ok'),
              //   )
              // ],
            ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    if(!selectNotificationSubject.hasListener){
      selectNotificationSubject.stream.listen((String? payload) async {
        Provider.of<NetworkState>(context, listen:false).connectToWifi(payload!);
        Navigator.pushNamed(context, '/');
      });
    }

  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    // I don't think we need to word about the first argument here. That's for communicating with FCM.
    AndroidNotificationDetails(
        'finder_001', 'Sight++ Finder', 'Alerts you if a Sight++ location is found',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Location Found', 'Open To Connect', platformChannelSpecifics
        ,payload: 'item x');
  }

  Future<void> _zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Location Found',
        'Open To Connect (2 second delay)',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 7)),
        const NotificationDetails(
            android: AndroidNotificationDetails('finder_001',
                'Sight++ Finder', 'Alerts you if a Sight++ location is found')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  // We need to use this function whenever we want to send a new notification.
  // This erases the old notification are replaces it with a new one.
  // This is what we want so we don't just spam the user with notifications.
  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
      return
        Scaffold(
          appBar: AppBar(
              title: const Text("Sight++")
          ),
          body: TestButton(beacon),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showNotification();
            },
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


