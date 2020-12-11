import 'dart:async';

import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

import '../MainTabWidget.dart';

const List<String> devices = [
  "Simple Switch",
];

// DeviceControl Widget Base for all Devices to control
abstract class DeviceControl extends StatefulWidget {
  DeviceControl({Key key, @required this.name, @required this.hostname, @required this.page, @required this.deviceNAME}) : super(key: key);

  final String deviceNAME;

  final int page;
  final String name;
  final String hostname;

  void saveToDataBase();
}

// DeviceControlState Widget Base for all Devices to control
abstract class DeviceControlState<T extends DeviceControl> extends State<T> {
  DeviceControlState(){
    homeController = HomeController.of(context);
    Timer.run(() { pollDeviceStatus(); });
    poller = Timer.periodic(Duration(seconds: 2), (Timer t) {
      if (homeController.wifiConnection)
        pollDeviceStatus();
    });
  }

  HomeController homeController;
  Timer poller;

  void pollDeviceStatus();

  @override
  void dispose(){
    super.dispose();
    poller.cancel();
  }
}

// DeviceConfig Widget Base for add/setup DeviceControl to List
abstract class DeviceConfig extends StatefulWidget {
  DeviceConfig({Key key, @required this.page}) : super(key: key);

  final TextEditingController name = TextEditingController();
  final TextEditingController hostname = TextEditingController();

  final int page;

  void clearFields();

  String validateName(String value) {
    if (value.isEmpty) {
      return "Please enter a name";
    }
    return null;
  }

  String validateHostname(String value) {
    RegExp hostname = RegExp(r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$');

    if (value.isEmpty) {
      return "Please enter a hostname";
    }
    if (!hostname.hasMatch(value)) {
      if (!isIP(value)){
        return "Please enter a valid IP or hostname";
      }
      return null;
    }
    return null;
  }
}