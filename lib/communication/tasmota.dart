import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
import 'dart:async';

import 'package:home_control/communication/communication.dart';

// SonoffMinFirmware to controll all Tasmota Devices
// TODO: May split in sub Classes when it gets bigger
class TasmotaHTTPConnector extends CommunicationHandler {
  TasmotaHTTPConnector(String hostname) : super(hostname, 80);

  Future<bool> getStateBool(int relayNumber) async {
    bool state = false;
    Future<http.Response> resp = http.get(sprintf('http://%s/cm?cmnd=Power%d', [hostname, relayNumber]));

    await resp.then((value) => {
      if (value.body.contains("ON")){
        state = true
      }
    });
    return state;
  }

  Future<bool> setStateBool(int relayNumber, bool on) async {
    bool state = false;
    Future<http.Response> resp;
    if (on) {
      resp = http.get(sprintf('http://%s/cm?cmnd=Power%d%%20On', [hostname, relayNumber]));
    } else {
      resp = http.get(sprintf('http://%s/cm?cmnd=Power%d%%20Off', [hostname, relayNumber]));
    }

    await resp.then((value) => {
      if (value.body.contains("ON")){
        state = true
      }
    });
    return state;
  }
}