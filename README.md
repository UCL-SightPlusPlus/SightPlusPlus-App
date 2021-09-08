# AVINA Mobile App

This is the App of AVINA system.

## Getting Started
The full instructions can be found at:
https://flutter.dev/docs/get-started/install

To open the project, please download the Flutter sdk and add it to the environment PATH. 

Then you have to install Android Studio and add Flutter and Dart plugin to it.

Go to pubspec.yaml and run 'flutter pub get' to download all the dependencies.

Use Android Studio to open the project, add a run configuration and set the Dart entry point to 'main.dart'.

Go to 'network_server_state.dart' and change the values in the 'connectToWifi' function.

Set up your own network, start local server under that network.

Turn on the developer mode on your phone and connect it to your laptop.

Run the app on your phone.

## How to Set up Bluetooth Beacons
We recommand using beacons from 'jaalee' and using iBeacon mode. If you are not using 'jaalee' beacons, please make sure the beacons support iBeacon protocol and go to 'bluetooth_beacon_state.dart' then change the identifier in the 'initBeaconScanner' function to your identifier(s).

When configuring the Bluetooth beacons, set the Major field as floor id and Minor field as room id.
