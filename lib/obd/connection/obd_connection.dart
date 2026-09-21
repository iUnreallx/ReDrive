/// Defines the transport interface used for OBD communication.
///
/// Implementations may use (Bluetooth/WiFi/Usb) or other transports while
/// keeping the OBD layer independent from transport details.
abstract class ObdConnection {
  Stream<String> get incoming;
  Stream<bool> get connectionState;
  Stream<bool> get reconnectingState;

  Future<void> send(String command);

  Future<void> connect();
  Future<void> disconnect();

  bool get isConnected;
  bool get isReconnecting;
}
