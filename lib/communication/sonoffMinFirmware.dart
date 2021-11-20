import 'dart:io';
import 'dart:async';

import 'package:home_control/communication/communication.dart';

// SonoffMinFirmware to controll my MinSonoffBasicFirmware
class SonoffMinFirmware extends CommunicationHandler {
  SonoffMinFirmware(String hostname, int port) : super(hostname, port);

  @override
  Future<bool> getStateBool(int relayNumber) async {
    Socket socket = await Socket.connect(hostname, port);

    socket.add([3]);

    return socket.first.then((value) {
      socket.close();
      if (value.first == 1) {
        return true;
      }
      return false;
    }, onError: (err) {
      socket.close();
      throw err;
    });
  }

  @override
  Future<bool> setStateBool(int relayNumber, bool on) async {
    Socket socket = await Socket.connect(hostname, port);

    if (on) {
      socket.add([1]);
    } else {
      socket.add([2]);
    }

    return socket.first.then((value) {
      socket.close();
      if (value.first == 1) {
        return true;
      }
      return false;
    }, onError: (err) {
      socket.close();
      throw err;
    });
  }

  @override
  Future<int> getDimmState(int relayNumber) {
    throw UnimplementedError();
  }

  @override
  Future<int> setDimmState(int relayNumber, int dimmState) {
    throw UnimplementedError();
  }
}
