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
    bool state = false;
    Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Power%d", [relayNumber])});
    Future<http.Response> resp = http.get(uri);

    await resp.then((value) => {
      if (value.body.contains("ON")){
        state = true
      }
    });
    return state;
  }

  @override
  Future<bool> setStateBool(int relayNumber, bool on) async {
    bool state = false;
    Future<http.Response> resp;
    if (on) {
      Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Power%d On", [relayNumber])});
      resp = http.get(uri);
    } else {
      Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Power%d Off", [relayNumber])});
      resp = http.get(uri);
    }

    await resp.then((value) => {
      if (value.body.contains("ON")){
        state = true
      }
    });
    return state;
  }

  @override
  Future<int> getDimmState(int relayNumber) async {
    Map<String, dynamic> result;
    Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Channel%d", [relayNumber])});
    Future<http.Response> resp = http.get(uri);

    await resp.then((value) => {
      result = jsonDecode(value.body)
    });
    return result[sprintf("Channel%d", [relayNumber])];
  }

  @override
  Future<int> setDimmState(int relayNumber, int dimmState) async {
    Map<String, dynamic> result;
    Uri uri = Uri.http(hostname, "/cm", {"cmnd": sprintf("Channel%d %d", [relayNumber, dimmState])});
    Future<http.Response> resp = http.get(uri);

    await resp.then((value) => {
      result = jsonDecode(value.body)
    });


    return result[sprintf("Channel%d", [relayNumber])];
  }
}