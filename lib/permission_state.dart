
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionState with ChangeNotifier{
  bool _permissionGranted = false;

  Future<bool> checkPermissions() async{
    Map<Permission, PermissionStatus> serviceStatus = await [Permission.microphone, Permission.bluetooth, Permission.locationAlways].request();
    if(serviceStatus[Permission.microphone] != PermissionStatus.granted || serviceStatus[Permission.locationAlways] != PermissionStatus.granted || serviceStatus[Permission.bluetooth] != PermissionStatus.granted){
      _permissionGranted = false;
      return false;
    }

    _permissionGranted = true;
    notifyListeners();
    return true;
  }

  get permissionGranted => _permissionGranted;
}