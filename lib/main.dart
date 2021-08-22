import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sight_plus_plus/bluetooth_beacon_state.dart';
import 'package:sight_plus_plus/network_server_state.dart';
import 'package:sight_plus_plus/permission_state.dart';
import 'package:sight_plus_plus/speech_to_text_state.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
String? languageCode;

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
        ChangeNotifierProvider(
            create: (context) => BluetoothBeaconState()
        ),
        ChangeNotifierProvider(
          create: (context) => PermissionState()
        )
      ],
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
              Locale('zh', ''),
              Locale('fr', ''),
              Locale('jp', ''),
            ],
            routes: {
              '/':(context) {
                languageCode = Localizations.localeOf(context).languageCode;
                return const SightPlusPlusApp();
              },
              '/page2': (context){
                return Page2();
              }
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

  @override
  void initState(){
    super.initState();
    _requestPermissions();
    Provider.of<PermissionState>(context, listen: false).checkPermissions().then((value) {
      if(!value){
        return;
      }
      _configureSelectNotificationSubject();
      languageCode ??= Localizations.localeOf(context).languageCode;
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Provider.of<NetworkState>(context, listen: false).initNetworkConnection(flutterLocalNotificationsPlugin);
        Provider.of<NetworkState>(context, listen: false).initTextToSpeech(languageCode: languageCode!);
        Provider.of<BluetoothBeaconState>(context, listen: false).initBeaconScanner();
        Provider.of<BluetoothBeaconState>(context, listen: false).initTextToSpeech(languageCode: languageCode!);
        Provider.of<SpeechToTextState>(context, listen: false).initiateSpeechToText();
      });
    });

   }



   @override
   void dispose(){
    super.dispose();
    Provider.of<BluetoothBeaconState>(context, listen: false).stopScanning();
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

  void _configureSelectNotificationSubject() {
    if(!selectNotificationSubject.hasListener){
      selectNotificationSubject.stream.listen((String? payload) async {
        //selectNotificationSubject.close();
        String? currentRoute = ModalRoute.of(context)!.settings.name;
        Provider.of<NetworkState>(context, listen:false).connectToWifi(payload!);
        if(currentRoute == '/'){
          return;
        }
        Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(Provider.of<NetworkState>(context).connected){
      return initialPage();
    }
    return Page2();
  }

}


class initialPage extends StatelessWidget{

  Widget _buildButton(BuildContext context) {
    return Provider<bool>.value(
      value: Provider.of<NetworkState>(context).connected,
      builder: (BuildContext context, Widget? child) {
        if(Provider.of<NetworkState>(context).connected){
          return Provider<bool>.value(
              value: Provider.of<SpeechToTextState>(context).canStart,
              builder: (BuildContext context, Widget? child) {
                if(Provider.of<SpeechToTextState>(context).canStart || Provider.of<SpeechToTextState>(context).isListening){
                  return GestureDetector(
                      onTap: () {
                        Provider.of<BluetoothBeaconState>(context, listen: false).stopTTS();
                        Provider.of<SpeechToTextState>(context, listen: false).startListening();
                      },
                      //
                      // onLongPressEnd: (details) {
                      //   Provider.of<SpeechToTextState>(context, listen: false).stopListening();
                      //   if(Provider.of<SpeechToTextState>(context, listen: false).transcription != ''){
                      //     var data = {'question':Provider.of<SpeechToTextState>(context, listen: false).transcription};
                      //     Provider.of<BluetoothBeaconState>(context, listen: false).updateInfo(data);
                      //   }
                      // },

                      child: Center(
                          child:Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).buttonColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(Provider.of<SpeechToTextState>(context).isListening ? 'Listening...':'Ask Question'),
                          )
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



  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
            title: const Text("Sight++")
        ),
        body: Column(
          children: [
            GestureDetector(
            onLongPressStart: (details) {
                Provider.of<BluetoothBeaconState>(context, listen: false).stopTTS();
                Provider.of<SpeechToTextState>(context, listen: false).startListening();
            },

          onLongPressEnd: (details) {
            Provider.of<SpeechToTextState>(context, listen: false).stopListening();
            if(Provider.of<SpeechToTextState>(context, listen: false).transcription != ''){
              var data = {'question':Provider.of<SpeechToTextState>(context, listen: false).transcription};
              Provider.of<BluetoothBeaconState>(context, listen: false).updateInfo(data);
            }
          },

          child: Center(
              child:Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(Provider.of<SpeechToTextState>(context).isListening ? 'Listening...':'Ask Question'),
              )
          )
      ),
            Text("The closest beacon id is ${Provider.of<BluetoothBeaconState>(context).closestBeacon}\n"),
            Text("User asks: ${Provider.of<SpeechToTextState>(context).transcription}. The server responded with: ${Provider.of<BluetoothBeaconState>(context).userMessage}\n"),
            Text("The current floor is ${Provider.of<BluetoothBeaconState>(context).lastFloor}. The server message is: ${Provider.of<BluetoothBeaconState>(context).autoMessage}\n"),
          ],
        ),
      );
  }

}

class Page2 extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return Page2State();
  }

}
class Page2State extends State<Page2>{
  @override
  void initState(){
    super.initState();
  }

  Widget buildButton(){
    if(Provider.of<PermissionState>(context).permissionGranted){
      return FloatingActionButton(
        onPressed: (){
          Provider.of<PermissionState>(context, listen: false).checkPermissions();
        },
        backgroundColor: Colors.blue,
      );
    }
    return FloatingActionButton(
      onPressed: (){
        Provider.of<PermissionState>(context, listen: false).checkPermissions();
      },
      backgroundColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Permission: "+Provider.of<PermissionState>(context).permissionGranted.toString()),
        ),
        body: Text("Hello"),
        floatingActionButton: buildButton()
      ),
    );

  }
}