import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:home_control/communication/communication.dart';

class TasmotaHTTPConnector extends CommunicationHandler {
  TasmotaHTTPConnector(String hostname) : super(hostname, 80);

  Future<bool> getState() async {
    bool state = false;
    Future<http.Response> resp = http.get('http://'+hostname+'/cm?cmnd=Power');

    await resp.then((value) => {
      if (value.body.contains("ON")){
        state = true
      }
    });
    return state;
  }

  Future<bool> setState(bool on) async {
    bool state = false;
    Future<http.Response> resp;
    if (on) {
      resp = http.get('http://'+hostname+'/cm?cmnd=Power%20On');
    } else {
      resp = http.get('http://'+hostname+'/cm?cmnd=Power%20Off');
    }

    await resp.then((value) => {
      if (value.body.contains("ON")){
        state = true
      }
    });
    return state;
  }
}