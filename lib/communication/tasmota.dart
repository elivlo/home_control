import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
import 'dart:async';

import 'package:home_control/communication/communication.dart';

// SonoffMinFirmware to control all Tasmota Devices
// TODO: May split in sub Classes when it gets bigger
class TasmotaHTTPConnector extends CommunicationHandler {
  TasmotaHTTPConnector(String hostname) : super(hostname, 80);

  @override
  Future<bool> getStateBool(int relayNumber) async {
    Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Power%d", [relayNumber])});
    return http.get(uri).then((value) {
      if (value.body.contains("ON")){
        return true;
      }
      return false;
    });
  }

  @override
  Future<bool> setStateBool(int relayNumber, bool on) async {
    String state;
    if (on) {
      state = "On";
    } else {
      state = "Off";
    }
    Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Power%d %s", [relayNumber, state])});
    return http.get(uri).then((value) {
      if (value.body.contains("ON")){
        return true;
      }
      return false;
    });
  }

  @override
  Future<int> getDimmState(int relayNumber) async {
    Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Channel%d", [relayNumber])});
    return http.get(uri).then((value) {
      var result = jsonDecode(value.body);
      return result[sprintf("Channel%d", [relayNumber])];
    });
  }

  @override
  Future<int> setDimmState(int relayNumber, int dimmState) async {
    Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Channel%d %d", [relayNumber, dimmState])});
    return http.get(uri).then((value) {
      var result = jsonDecode(value.body);
      return result[sprintf("Channel%d", [relayNumber])];
    });
  }
}