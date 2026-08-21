import 'dart:async';

import 'package:redrive/services/obd_connection.dart';

class FakeObdConnection implements ObdConnection {
  final StreamController<String> _incomingController =
      StreamController<String>();

  final List<String> sentCommands = [];

  bool _isConnected = false;

  Object? sendError;

  @override
  Stream<String> get incoming => _incomingController.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isReconnecting => false;

  @override
  Future<void> connect() async {
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
  }

  @override
  Future<void> send(String command) async {
    if (sendError != null) {
      throw sendError!;
    }

    sentCommands.add(command);
  }

  void emit(String chunk) {
    _incomingController.add(chunk);
  }

  Future<void> dispose() {
    return _incomingController.close();
  }
}
