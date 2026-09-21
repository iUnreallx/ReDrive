import 'package:redrive/providers/bluetooth_provider.dart';
import 'package:redrive/obd/connection/obd_connection.dart';

class BluetoothObdConnection implements ObdConnection {
  final BluetoothProvider provider;

  BluetoothObdConnection(this.provider);

  @override
  Stream<bool> get reconnectingState => provider.reconnectingState;

  @override
  Stream<bool> get connectionState => provider.connectionState;

  @override
  Stream<String> get incoming => provider.rxStream;

  @override
  bool get isConnected => provider.isConnected;

  @override
  bool get isReconnecting => provider.isReconnectingBackground;

  @override
  Future<void> send(String command) async {
    provider.sendCommand(command);
  }

  /// DONT IMPLEMENTS!!!!!
  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {
    await provider.disconnect();
  }
}
