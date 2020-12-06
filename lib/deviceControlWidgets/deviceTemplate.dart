import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

abstract class DeviceControl extends StatefulWidget {
  DeviceControl({Key key, this.name, this.hostname}) : super(key: key);

  final String name;
  final String hostname;

  String getDeviceName();
}

abstract class DeviceConfig extends StatefulWidget {
  DeviceConfig({Key key, this.addItem}) : super(key: key);

  final TextEditingController name = TextEditingController();
  final TextEditingController hostname = TextEditingController();

  final void Function(DeviceControl d) addItem;

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