// CommunicationHandler as base for all Devices communication
abstract class CommunicationHandler {
  CommunicationHandler(this.hostname, this.port);

  int port;
  String hostname;

  Future<bool> getState();

  Future<bool> setState(bool on);
}