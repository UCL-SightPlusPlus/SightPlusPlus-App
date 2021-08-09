import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in  the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
BehaviorSubject<String?>();

const MethodChannel platform =
MethodChannel('dexterx.dev/sightplusplus');

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _configureLocalTimeZone();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = Platform
      .isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    // When the app opens from the notification the payload is printed.
    // We could potentially use this for determining when the app opens.
    print(selectedNotificationPayload);
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

  // runApp(const HomePage());
  runApp(MaterialApp(
      title: 'Welcome to Flutter',
      initialRoute:"/",
      routes: {
        "/": (context) => const HomePage()
      },
  ));
}

// Used for getting the time of the device.
Future<void> _configureLocalTimeZone() async {
  if (Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.notificationAppLaunchDetails}) : super(key: key);


  // static const String routeName = '/';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    // Probably don't even need the next two. But will keep them for now.
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();

    //Different types of notification test. Here I show and example and
    // use the sleep statement to show how the old notification disappears.

    _showNotification();
    // _zonedScheduleNotification();
    sleep(const Duration(seconds:4));
    _cancelAllNotifications();
    _zonedScheduleNotification();

  }

  // Jut permissions. We need this.
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

  // I don't even think we need this and the next function for our purposes.
  // Since we only have 1 screen, all we need is to direct uses back to that.
  // And by default, if you don't specify where to return is will go to the home screen by default.
  void _configureDidReceiveLocalNotificationSubject() {
    print('here');
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
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
              //               SecondPage(receivedNotification.payload),
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
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(context, '/');
    });

  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Welcome to Flutter'),
          ),
          body: const Center(
            child: Text('Hello World'),
          ),
      );
  }

  // These next two functions are types of notifications that can be shown.
  // The two here I've used as an example are notification that appear when
  // you call them and notification that appear after 5 second when you call them.
  // We'll probably just need to use the first notification.

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



}