import 'package:http/http.dart' as http;
import 'dart:async';

class TasmotaHTTPConnector {
  TasmotaHTTPConnector(this.hostname);

  final int port = 80;
  String hostname;

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