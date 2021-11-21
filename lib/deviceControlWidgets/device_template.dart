import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_control/communication/communication.dart';

import '../main_tab_widget.dart';

class DeviceData {
  final String name;
  final String hostname;
  final int page;
  final String type;
  final Map<String, dynamic>? config;

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

  const DeviceControl({required Key key, required this.data}) : super(key: key);

  Map<String, dynamic> toJson() => data.toJson();
}

// DeviceControlState Widget Base for all Devices to control
abstract class DeviceControlState<T extends DeviceControl> extends State<T>
    with AutomaticKeepAliveClientMixin {
  var timerTime = -1;
  Timer? poller;
  CommunicationHandler? server;

  void setupCommunicationHandler();

  void pollDeviceStatus();

  void startTimer(int sec) {
    if (sec != timerTime) {
      timerTime = sec;
      poller?.cancel();
      if (sec > 0) {
        poller = Timer.periodic(Duration(seconds: sec), (Timer t) {
          pollDeviceStatus();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final HomeController? h = HomeController.of(context);
    if (!h!.wifiConnection) {
      poller?.cancel();
    }
    startTimer(h.pollingTime);
  }

  @override
  void initState() {
    super.initState();
    setupCommunicationHandler();
    Timer.run(() {
      pollDeviceStatus();
    });
  }

  @override
  void dispose() {
    poller?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

// DeviceConfig Widget Base for add/setup DeviceControl to List
abstract class DeviceConfig {
  DeviceConfig({required this.page});

  final int page;
  void createDeviceControl(BuildContext context, String name, String hostname);

  Widget customConfigWidgets(void Function(void Function() fn) setState);
}
