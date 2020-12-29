import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
import 'dart:async';

import 'package:home_control/communication/communication.dart';

// SonoffMinFirmware to controll all Tasmota Devices
// TODO: May split in sub Classes when it gets bigger
class TasmotaHTTPConnector extends CommunicationHandler {
  TasmotaHTTPConnector(String hostname) : super(hostname, 80);

  @override
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

  @override
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

  @override
  Future<int> getDimmState(int relayNumber) async {
    Map<String, dynamic> result;
    Future<http.Response> resp = http.get(sprintf('http://%s/cm?cmnd=Channel%d', [hostname, relayNumber]));

    await resp.then((value) => {
      result = jsonDecode(value.body)
    });
    return result[sprintf("Channel%d", [relayNumber])];
  }

  @override
  Future<int> setDimmState(int relayNumber, int dimmState) async {
    Map<String, dynamic> result;
    Future<http.Response> resp = http.get(sprintf('http://%s/cm?cmnd=Channel%d%%20%d', [hostname, relayNumber, dimmState]));

    await resp.then((value) => {
      result = jsonDecode(value.body)
    });


    return result[sprintf("Channel%d", [relayNumber])];
  }
}