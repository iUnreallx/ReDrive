import 'dart:async';

import 'package:redrive/obd/connection/obd_connection.dart';

class FakeObdConnection implements ObdConnection {
  final _incomingController = StreamController<String>();

  final _connectionStateController = StreamController<bool>.broadcast();
  final _reconnectingStateController = StreamController<bool>.broadcast();

  final List<String> sentCommands = [];

  bool _isConnected = false;
  bool _isReconnecting = false;

  Object? sendError;

  @override
  Stream<String> get incoming => _incomingController.stream;

  @override
  Stream<bool> get connectionState => _connectionStateController.stream;

  @override
  Stream<bool> get reconnectingState => _reconnectingStateController.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isReconnecting => _isReconnecting;

  void _setConnected(bool state) {
    if (_isConnected == state) return;

    _isConnected = state;
    _connectionStateController.add(state);
  }

  void setReconnecting(bool state) {
    if (_isReconnecting == state) return;

    _isReconnecting = state;
    _reconnectingStateController.add(state);
  }

  @override
  Future<void> connect() async {
    _setConnected(true);
  }

  @override
  Future<void> disconnect() async {
    _setConnected(false);
  }

  @override
  Future<void> send(String command) async {
    sentCommands.add(command);

    if (sendError != null) {
      throw sendError!;
    }
  }

  void emit(String chunk) {
    _incomingController.add(chunk);
  }

  void emitError(Object error) {
    _incomingController.addError(error);
  }

  Future<void> closeIncoming() {
    return _incomingController.close();
  }

  Future<void> dispose() async {
    await _incomingController.close();
    await _connectionStateController.close();
    await _reconnectingStateController.close();
  }
}
