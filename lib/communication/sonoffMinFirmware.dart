import 'dart:io';
import 'dart:async';

class SonoffMinFirmware {
  SonoffMinFirmware(this.hostname, this.port);

  int port;
  String hostname;

  Future<bool> getState() async {
    int state;
    Socket socket = await Socket.connect(hostname, port);
    print("connected " + hostname);

    socket.listen((List<int> event) {
      state = event[event.length-1];
    });

    socket.add([3]);

    await Future.delayed(Duration(seconds: 1));

    socket.close();

    if (state == 1) {
      return true;
    }
    return false;
  }

  Future<bool> setState(bool on) async {
    int state;
    Socket socket = await Socket.connect(hostname, port);
    print("connected " + hostname);

    socket.listen((List<int> event) {
      state = event[event.length-1];
    });

    if (on) {
      socket.add([1]);
    } else {
      socket.add([2]);
    }

    await Future.delayed(Duration(milliseconds: 400));

    socket.close();

    print(state);

    if (state == 1) {
      return true;
    }
    return false;
  }
}