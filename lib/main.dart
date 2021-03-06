import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sight_plus_plus/bluetooth_beacon_state.dart';
import 'package:sight_plus_plus/network_server_state.dart';
import 'package:sight_plus_plus/permission_state.dart';
import 'package:sight_plus_plus/speech_to_text_state.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
String? languageCode;

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in  the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final StreamController<String?> selectNotificationSubject =
    StreamController<String?>();

const MethodChannel platform = MethodChannel('sightplusplus');

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = Platform
          .isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    // When the app opens from the notification the payload is printed.
    // We could potentially use this for determining when the app opens.
    print("Payload: " + selectedNotificationPayload.toString());
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

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NetworkState(),
        ),
        ChangeNotifierProvider(
          create: (context) => SpeechToTextState(),
        ),
        ChangeNotifierProvider(create: (context) => BluetoothBeaconState()),
        ChangeNotifierProvider(create: (context) => PermissionState())
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
          Locale('el', '')
        ],
        routes: {
          '/': (context) {
            languageCode = Localizations.localeOf(context).languageCode;
            return const SightPlusPlusApp();
          },
        },
      )));
}

class SightPlusPlusApp extends StatefulWidget {
  const SightPlusPlusApp({Key? key, this.notificationAppLaunchDetails})
      : super(key: key);

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
  void initState() {
    super.initState();
    _requestPermissions();
    _configureSelectNotificationSubject();
    Provider.of<PermissionState>(context, listen: false)
        .checkPermissions()
        .then((value) {
      if (!value) {
        return;
      }
      Provider.of<NetworkState>(context, listen: false)
          .initNetworkConnection(flutterLocalNotificationsPlugin);
      Provider.of<BluetoothBeaconState>(context, listen: false)
          .initBeaconScanner();
      Provider.of<BluetoothBeaconState>(context, listen: false)
          .initTextToSpeech(languageCode: languageCode!);
      Provider.of<SpeechToTextState>(context, listen: false)
          .initiateSpeechToText(languageCode : languageCode!);
    });
  }

  @override
  void dispose() {
    super.dispose();
    Provider.of<BluetoothBeaconState>(context, listen: false).stopScanning();
    Provider.of<NetworkState>(context, listen: false).stopStream();
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
    if (!selectNotificationSubject.hasListener) {
      selectNotificationSubject.stream.listen((String? payload) async {
        //selectNotificationSubject.close();
        String? currentRoute = ModalRoute.of(context)!.settings.name;
        Provider.of<NetworkState>(context, listen: false)
            .connectToWifi(payload!);
        if (currentRoute == '/') {
          return;
        }
        Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<PermissionState>(context).permissionGranted) {
      return const PermissionScreen();
    }
    return StatesScreen();
  }
}

// Controls the 'permissions' screen.
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sets screen size, and makes sure it scales across devices.
    ScreenUtil.init(
        BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width),
        designSize: const Size(412, 869),
        //Sets screen orientation to portrait only.
        orientation: Orientation.portrait);
    return Scaffold(
      backgroundColor: const Color(0xff494949),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Container for the status bar at the top of the screen.
            Container(
              // Defines icon container.
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(130)),
              decoration: const BoxDecoration(
                color: Color(0xff333333),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Permissions Icon Container
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xffff1e39),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.cancel,
                      size: ScreenUtil().setHeight(50),
                      color: Colors.white,
                      // Semantic label needed for screen reader.
                      semanticLabel: 'Permission is Not Given',
                    ),
                  ),
                  // Server Connection Icon Container.
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xffff1e39),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.wifi_off,
                      size: ScreenUtil().setHeight(50),
                      color: Colors.white,
                      semanticLabel: 'Server is Not Connected',
                    ),
                  ),
                  // Bluetooth Beacon Icon Container.
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xffff1e39),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.bluetooth_disabled,
                      size: ScreenUtil().setHeight(50),
                      color: Colors.white,
                      semanticLabel: 'Bluetooth Beacon is Not Connected',
                    ),
                  ),
                ],
              ),
            ),

            // Container for the center section of the screen.
            // It uses MergeSemantics to make it only one entity for
            // the screen reader.
            MergeSemantics(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), 0,
                        ScreenUtil().setWidth(10), ScreenUtil().setHeight(50)),
                    width: double.infinity,
                    height: ScreenUtil().setHeight(350),
                    child: IconButton(
                      icon: Icon(Icons.priority_high_outlined,
                          size: ScreenUtil().setHeight(350),
                          color: Colors.white,
                          semanticLabel:
                              'Necessary Permissions is Not Given, Please Give Permissions'),
                      onPressed: () {
                        // Navigate to the second screen using a named route.
                        Provider.of<PermissionState>(context, listen: false)
                            .checkPermissions()
                            .then((value) {
                          if (!value) {
                            return;
                          }
                          Provider.of<NetworkState>(context, listen: false)
                              .initNetworkConnection(
                                  flutterLocalNotificationsPlugin);
                          Provider.of<BluetoothBeaconState>(context,
                                  listen: false)
                              .initBeaconScanner();
                          Provider.of<BluetoothBeaconState>(context,
                                  listen: false)
                              .initTextToSpeech(languageCode: languageCode!);
                          Provider.of<SpeechToTextState>(context, listen: false)
                              .initiateSpeechToText();
                        });
                      },
                    ),
                  ),
                  // Container for the text under the center icon.
                  Semantics(
                      // Excluded from being read by the screen reader.
                      excludeSemantics: true,
                      child: Container(
                          height: ScreenUtil().setHeight(100),
                          margin: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(10),
                              0,
                              ScreenUtil().setWidth(10),
                              ScreenUtil().setHeight(10)),
                          child: Text('Necessary Permissions Not Given',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(32))))),
                ],
              ),
            ),

            // Places where the Intel icon is.
            Padding(
              padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Semantics(
                  // Makes the semantic section (including the logo)
                  // unreadable by the screen reader.
                  excludeSemantics: true,
                  child: Image(
                    image: const AssetImage("images/intel_logo.png"),
                    height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(50),
                    semanticLabel: 'Intel Logo',
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

// Controls all other screens and states for app.
class StatesScreen extends StatelessWidget {
  final TextEditingController textController = TextEditingController();

  StatesScreen({Key? key}) : super(key: key);

  // Sets the status bar icon container colour.
  Color _stateButtonColor(bool state) {
    if (state) {
      return const Color(0xff0b7ae6);
    }
    return const Color(0xffff1e39);
  }

  // Sets the background colour for the app.
  Color _backgroundColor(BuildContext context) {
    if (!Provider.of<NetworkState>(context).connected) {
      return const Color(0xff494949);
    }
    if (Provider.of<SpeechToTextState>(context).isListening) {
      return const Color(0xffff1e39);
    } else if (Provider.of<BluetoothBeaconState>(context).isHandling) {
      return const Color(0xff978d17);
    } else if (Provider.of<BluetoothBeaconState>(context).closestBeacon == -1) {
      return const Color(0xff232981);
    }
    return const Color(0xff0b7ae6);
  }

  //checks the text field is editable or not
  bool _textFieldAble(BuildContext context) {
    return !Provider.of<SpeechToTextState>(context).isListening &&
        !Provider.of<BluetoothBeaconState>(context).isHandling;
  }

  // Creates button for text field on screen.
  Widget _buildQuestionButton(BuildContext context) {
    if (Provider.of<BluetoothBeaconState>(context).isHandling ||
        Provider.of<SpeechToTextState>(context).isListening ||
        textController.text == '') {
      return Container(
          width: ScreenUtil().setWidth(80),
          height: ScreenUtil().setHeight(80),
          decoration: const BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: const IconButton(
            icon: Icon(
              Icons.arrow_forward_outlined,
              color: Colors.white,
              semanticLabel: 'Send Question',
            ),
            onPressed: null,
          ));
    }
    return Container(
        width: ScreenUtil().setWidth(80),
        height: ScreenUtil().setHeight(80),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_forward_outlined,
            color: Colors.white,
            semanticLabel: 'Send Question',
          ),
          onPressed: () {
            Provider.of<BluetoothBeaconState>(context, listen: false)
                .updateInfo(textController.text);
          },
        ));
  }

  // Creates text field.
  Widget _buildTextField(BuildContext context, bool state) {
    if (state) {
      return Container(
        color: Colors.white,
        width: ScreenUtil().setWidth(400),
        height: ScreenUtil().setHeight(100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: ScreenUtil().setWidth(300),
              height: ScreenUtil().setHeight(80),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: TextField(
                enabled: _textFieldAble(context),
                style: const TextStyle(fontSize: 32.0),
                controller: textController,
                decoration: const InputDecoration(hintText: "Question Asked"),
              ),
            ),
            Container(
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setHeight(80),
                child: _buildQuestionButton(context)),
          ],
        ),
      );
    }
    return Container(
      height: ScreenUtil().setHeight(100),
    );
  }

  // Creates center button.
  Widget _buildCenterIcon(BuildContext context) {
    if (Provider.of<NetworkState>(context).connected) {
      return GestureDetector(
        onLongPressStart: (details) {
          textController.clear();
          Provider.of<BluetoothBeaconState>(context, listen: false).stopTTS();
          Provider.of<SpeechToTextState>(context, listen: false)
              .startListening();
        },
        onLongPressEnd: (details) {
          Provider.of<SpeechToTextState>(context, listen: false)
              .stopListening();
          if (Provider.of<SpeechToTextState>(context, listen: false)
                  .transcription !=
              '') {
            textController.text =
                Provider.of<SpeechToTextState>(context, listen: false)
                    .transcription;
            String data = Provider.of<SpeechToTextState>(context, listen: false)
                .transcription;
            Provider.of<BluetoothBeaconState>(context, listen: false)
                .updateInfo(data);
          }
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(10),
              ScreenUtil().setHeight(0),
              ScreenUtil().setWidth(10),
              ScreenUtil().setHeight(50)),
          width: double.infinity,
          height: ScreenUtil().setHeight(350),
          child: Icon(Icons.mic,
              size: ScreenUtil().setHeight(350),
              color: Colors.white,
              semanticLabel: 'Please Hold To Record Your Question'),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(10),
          ScreenUtil().setHeight(0),
          ScreenUtil().setWidth(10),
          ScreenUtil().setHeight(50)),
      width: double.infinity,
      height: ScreenUtil().setHeight(350),
      child: Icon(Icons.wifi_off,
          size: ScreenUtil().setHeight(350),
          color: Colors.white,
          semanticLabel: 'Not connected to the server'),
    );
  }

  // Creates the icon bar at the top of the screen
  // and also sets the state those icons (working/not working)
  Widget _buildStateIcon(IconData icon, bool state) {
    if (icon == Icons.bluetooth) {
      if (state) {
        return Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            color: _stateButtonColor(state),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Icon(
            icon,
            size: 50,
            color: Colors.white,
            semanticLabel: "Bluetooth Beacon is connected",
          ),
        );
      } else {
        return Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            color: _stateButtonColor(state),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: const Icon(
            Icons.bluetooth_disabled,
            size: 50,
            color: Colors.white,
            semanticLabel: "Bluetooth Beacon is not connected",
          ),
        );
      }
    }
    if (icon == Icons.wifi) {
      if (state) {
        return Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            color: _stateButtonColor(state),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Icon(
            icon,
            size: ScreenUtil().setHeight(50),
            color: Colors.white,
            semanticLabel: "Server is connected",
          ),
        );
      } else {
        return Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            color: _stateButtonColor(state),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Icon(
            icon,
            size: ScreenUtil().setHeight(50),
            color: Colors.white,
            semanticLabel: "Server is not connected",
          ),
        );
      }
    }

    if (icon == Icons.wifi) {
      if (state) {
        return Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            color: _stateButtonColor(state),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Icon(
            icon,
            size: ScreenUtil().setHeight(50),
            color: Colors.white,
            semanticLabel: "Server is connected",
          ),
        );
      } else {
        return Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(100),
          decoration: BoxDecoration(
            color: _stateButtonColor(state),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Icon(
            Icons.wifi_off,
            size: ScreenUtil().setHeight(50),
            color: Colors.white,
            semanticLabel: "Server is not connected",
          ),
        );
      }
    }
    return Container(
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
        color: _stateButtonColor(state),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Icon(
        icon,
        size: ScreenUtil().setHeight(50),
        color: Colors.white,
        semanticLabel: "Permission is granted",
      ),
    );
  }

  // Sets the text below the center button according to the app state.
  Widget _buildBottomText(BuildContext context) {
    if (Provider.of<BluetoothBeaconState>(context).isHandling) {
      return Text('Getting Response',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(32)));
    }
    if (Provider.of<NetworkState>(context).connected) {
      return Text(
          Provider.of<SpeechToTextState>(context).isListening
              ? 'Listening...'
              : 'Hold To Record',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(32)));
    }
    return Text('Searching for Sight++ Location',
        textAlign: TextAlign.center,
        style:
            TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(32)));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width),
        designSize: const Size(412, 869),
        orientation: Orientation.portrait);
    return Scaffold(
      //Stops the screen from resizing when the keyboard comes us.
      resizeToAvoidBottomInset: false,
      backgroundColor: _backgroundColor(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(30)),
              decoration: const BoxDecoration(
                color: Color(0xff333333),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStateIcon(Icons.check_circle,
                      Provider.of<PermissionState>(context).permissionGranted),
                  _buildStateIcon(
                      Icons.wifi, Provider.of<NetworkState>(context).connected),
                  _buildStateIcon(
                      Icons.bluetooth,
                      Provider.of<BluetoothBeaconState>(context)
                              .closestBeacon !=
                          -1),
                ],
              ),
            ),
            _buildTextField(
                context, Provider.of<NetworkState>(context).connected),
            // Creates merged entity with center button and text below it.
            MergeSemantics(
              child: Column(
                children: [
                  _buildCenterIcon(context),
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                        height: ScreenUtil().setHeight(100),
                        margin: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(10),
                            0,
                            ScreenUtil().setWidth(10),
                            ScreenUtil().setHeight(10)),
                        child: _buildBottomText(context)),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Semantics(
                  // Makes Intel icon appear invisible to screen reader.
                  excludeSemantics: true,
                  child: Image(
                    image: const AssetImage("images/intel_logo.png"),
                    height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(50),
                    semanticLabel: 'Intel Logo',
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
