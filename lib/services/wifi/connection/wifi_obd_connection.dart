import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:redrive/obd/connection/obd_connection.dart';

/// [ObdConnection] to a Wi-Fi ELM327 adapter over a TCP socket.
///
/// Most adapters run their own access point and listen on
/// 192.168.0.10:35000, other addresses can be passed to [connect].
class WifiObdConnection extends ChangeNotifier implements ObdConnection {
  static const String defaultHost = '192.168.0.10';
  static const int defaultPort = 35000;

  static const Duration _quickDropWindow = Duration(seconds: 15);
  static const int _maxQuickDrops = 3;

  final Duration connectTimeout;
  final Duration reconnectDelay;
  final int reconnectAttempts;

  WifiObdConnection({
    this.connectTimeout = const Duration(seconds: 5),
    this.reconnectDelay = const Duration(seconds: 2),
    this.reconnectAttempts = 3,
  });

  String _host = defaultHost;
  String get host => _host;

  int _port = defaultPort;
  int get port => _port;

  bool _isConnected = false;
  @override
  bool get isConnected => _isConnected;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  bool _isReconnecting = false;
  @override
  bool get isReconnecting => _isReconnecting;

  Socket? _socket;
  StreamSubscription<Uint8List>? _socketSubscription;

  /// Bumped by every connect, reconnect and disconnect, so a late result
  /// of an older attempt is dropped.
  int _connectionId = 0;

  DateTime? _lastReconnectSuccessAt;
  int _quickDrops = 0;

  final _incomingController = StreamController<String>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();
  final _reconnectingStateController = StreamController<bool>.broadcast();

  @override
  Stream<String> get incoming => _incomingController.stream;

  @override
  Stream<bool> get connectionState => _connectionStateController.stream;

  @override
  Stream<bool> get reconnectingState => _reconnectingStateController.stream;

  void _setConnected(bool state) {
    if (_isConnected == state) return;

    _isConnected = state;
    _connectionStateController.add(state);
  }

  void _setReconnecting(bool state) {
    if (_isReconnecting == state) return;

    _isReconnecting = state;
    _reconnectingStateController.add(state);
  }

  /// Opens a socket to the adapter. Returns `false` if it could not be
  /// reached in [connectTimeout] or the attempt was cancelled by [disconnect].
  Future<bool> connect({String? host, int? port}) async {
    if (_isConnecting) return false;

    final targetHost = host ?? _host;
    final targetPort = port ?? _port;

    if (_isConnected || _isReconnecting) {
      if (_isConnected && targetHost == _host && targetPort == _port) {
        return true;
      }
      await disconnect();
    }

    final currentId = ++_connectionId;

    _host = targetHost;
    _port = targetPort;
    _isConnecting = true;
    notifyListeners();

    try {
      final socket = await _openSocket();

      if (currentId != _connectionId) {
        socket.destroy();
        return false;
      }

      _listen(socket);
      _quickDrops = 0;
      _lastReconnectSuccessAt = null;
      _isConnecting = false;
      _setConnected(true);
      notifyListeners();
      return true;
    } catch (e) {
      developer.log(
        'Connect to $_host:$_port failed',
        name: 'reWifi',
        error: e,
      );
      if (currentId != _connectionId) return false;

      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  Future<Socket> _openSocket() async {
    final socket = await Socket.connect(_host, _port, timeout: connectTimeout);
    socket.setOption(SocketOption.tcpNoDelay, true);
    return socket;
  }

  void _listen(Socket socket) {
    _socket = socket;

    // Write errors also end the input stream, which is handled below.
    socket.done.catchError((_) {});

    _socketSubscription = socket.listen(
      (data) => _incomingController.add(String.fromCharCodes(data)),
      onDone: () => _handleSocketLost(socket),
      onError: (Object e) {
        developer.log('Socket error', name: 'reWifi', error: e);
        _handleSocketLost(socket);
      },
      cancelOnError: true,
    );
  }

  void _handleSocketLost(Socket socket) {
    if (!identical(_socket, socket)) return;

    unawaited(reconnect());
  }

  @override
  Future<void> send(String command) async {
    final socket = _socket;
    if (socket == null) {
      throw StateError('Wi-Fi adapter is not connected');
    }

    socket.add(command.codeUnits);
  }

  /// Replaces the socket with a new one to the same adapter and disconnects
  /// after [reconnectAttempts] failed tries.
  @override
  Future<void> reconnect() async {
    if (!_isConnected || _isReconnecting) return;

    final lastSuccessAt = _lastReconnectSuccessAt;
    final isQuickDrop =
        lastSuccessAt != null &&
        DateTime.now().difference(lastSuccessAt) < _quickDropWindow;
    _quickDrops = isQuickDrop ? _quickDrops + 1 : 0;

    if (_quickDrops >= _maxQuickDrops) {
      developer.log('Adapter keeps dropping, giving up', name: 'reWifi');
      await disconnect();
      return;
    }

    final currentId = ++_connectionId;

    _setReconnecting(true);
    notifyListeners();

    await _closeSocket();

    for (var i = 1; i <= reconnectAttempts; i++) {
      await Future<void>.delayed(reconnectDelay);
      if (currentId != _connectionId) return;

      try {
        final socket = await _openSocket();

        if (currentId != _connectionId) {
          socket.destroy();
          return;
        }

        _listen(socket);
        _lastReconnectSuccessAt = DateTime.now();
        _setReconnecting(false);
        notifyListeners();
        return;
      } catch (e) {
        developer.log('Reconnect attempt $i failed', name: 'reWifi', error: e);
        if (currentId != _connectionId) return;
      }
    }

    await disconnect();
  }

  /// Closes the socket and cancels a connect or reconnect in progress.
  @override
  Future<void> disconnect() async {
    _connectionId++;

    final closing = _closeSocket();

    _quickDrops = 0;
    _lastReconnectSuccessAt = null;
    _isConnecting = false;
    _setConnected(false);
    _setReconnecting(false);
    notifyListeners();

    await closing;
  }

  Future<void> _closeSocket() async {
    final subscription = _socketSubscription;
    final socket = _socket;
    _socketSubscription = null;
    _socket = null;

    await subscription?.cancel();
    socket?.destroy();
  }

  @override
  void dispose() {
    _connectionId++;
    _socketSubscription?.cancel();
    _socket?.destroy();
    _incomingController.close();
    _connectionStateController.close();
    _reconnectingStateController.close();
    super.dispose();
  }
}
