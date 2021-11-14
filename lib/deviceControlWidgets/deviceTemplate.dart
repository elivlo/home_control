import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_control/communication/communication.dart';
import 'package:string_validator/string_validator.dart';

import '../MainTabWidget.dart';

class DeviceData {
  final String name;
  final String hostname;
  final int page;
  final String type;
  final Map<String, dynamic> config;

  DeviceData(this.name, this.hostname, this.page, this.config, this.type);

  DeviceData.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        hostname = json["hostname"],
        page = json["page"],
        config = json["config"],
        type = json["type"];

  Map<String, dynamic> toJson() => {
        "name": name,
        "hostname": hostname,
        "page": page,
        "config": config,
        "type": type
      };
}

// DeviceControl Widget Base for all Devices to control
abstract class DeviceControl extends StatefulWidget {
  final DeviceData data;

  DeviceControl({Key key, @required this.data}) : super(key: key);

  Map<String, dynamic> toJson() => data.toJson();
}

// DeviceControlState Widget Base for all Devices to control
abstract class DeviceControlState<T extends DeviceControl> extends State<T> with AutomaticKeepAliveClientMixin {
  Timer poller;
  CommunicationHandler server;

  void setupCommunicationHandler();

  void pollDeviceStatus();

  void startTimer(int sec) {
    if (poller != null) {
      poller.cancel();
    }
    if (sec > 0) {
      poller = Timer.periodic(Duration(seconds: sec), (Timer t) {
        pollDeviceStatus();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final HomeController h = HomeController.of(context);
    if (h != null) {
      if (!h.wifiConnection) {
        poller.cancel();
      } else if (h.pollingTime > 0) {
        startTimer(h.pollingTime);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setupCommunicationHandler();
    Timer.run(() {
      pollDeviceStatus();
    });
    startTimer(2);
  }

  @override
  void dispose() {
    poller.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
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
    RegExp hostname = RegExp(
        r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$');

    if (value.isEmpty) {
      return "Please enter a hostname";
    }
    if (!hostname.hasMatch(value)) {
      if (!isIP(value)) {
        return "Please enter a valid IP or hostname";
      }
      return null;
    }
    return null;
  }
}
