import 'dart:io';
import 'dart:async';

import 'package:home_control/communication/communication.dart';

// SonoffMinFirmware to controll my MinSonoffBasicFirmware
class SonoffMinFirmware extends CommunicationHandler{
  SonoffMinFirmware(String hostname, int port) : super(hostname, port);

  Future<bool> getStateBool(int relayNumber) async {
    int state;
    Socket socket = await Socket.connect(hostname, port);

    socket.add([3]);

    await socket.first.then((value) {
      state = value.first;
    }, onError: (err){
      state = null;
    });

    socket.close();

    if (state == null) {
      return null;
    } else if (state == 1) {
      return true;
    }
    return false;
  }

  Future<bool> setStateBool(int relayNumber, bool on) async {
    int state;
    Socket socket = await Socket.connect(hostname, port);

    if (on) {
      socket.add([1]);
    } else {
      socket.add([2]);
    }

    await socket.first.then((value) {
      state = value.first;
    }, onError: (err){
      state = null;
    });

    socket.close();

    if (state == null) {
      return null;
    } else if (state == 1) {
      return true;
    }
    return false;
  }
}