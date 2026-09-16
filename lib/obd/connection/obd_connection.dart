abstract class ObdConnection {
  Stream<String> get incoming;

  Future<void> send(String command);

  Future<void> connect();
  Future<void> disconnect();

  bool get isConnected;
  bool get isReconnecting;
}
