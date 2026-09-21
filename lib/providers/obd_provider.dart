import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/polling/polling_controller.dart';

import '../obd/demo/demo_data_generator.dart';
import '../obd/models/obd_data.dart';
import '../obd/connection/obd_connection.dart';
import '../obd/pid/pid_registry.dart';
import '../obd/source/live_obd_source.dart';
import '../obd/source/obd_source_state.dart';

enum ObdMode { idle, demo, real }

/// Coordinates OBD data sources and exposes vehicle data to the UI.
///
/// Manages Real/Demo modes, active watchlists, connection lifecycle,
/// and the latest decoded OBD data.
///
/// Low-level OBD communication is delegated to [LiveObdSource].
class ObdProvider extends ChangeNotifier {
  ObdConnection? _connection;
  LiveObdSource? _liveSource;
  final PidRegistry _registry;
  DemoDataGenerator? _demoGenerator;

  ObdProvider({PidRegistry? registry}) : _registry = registry ?? PidRegistry();

  StreamSubscription<({PidKey key, num value})>? _updatesSubscription;
  StreamSubscription<ObdSourceState>? _stateSubscription;
  StreamSubscription<bool>? _connectionStateSubscription;
  StreamSubscription<bool>? _reconnectingStateSubscription;

  final Map<WatchSource, Set<PidKey>> _watchlists = {};

  bool get isDeviceConnected => _connection?.isConnected ?? false;
  ObdSourceState get state => _liveSource?.state ?? ObdSourceState.disconnected;

  bool get isReconnecting => _connection?.isReconnecting ?? false;

  ObdData _data = const ObdData();
  ObdData get data => _data;

  ObdMode _mode = ObdMode.idle;
  ObdMode get mode => _mode;

  void attachConnection(ObdConnection connection) {
    _connectionStateSubscription?.cancel();
    _reconnectingStateSubscription?.cancel();

    _connection = connection;

    _connectionStateSubscription = connection.connectionState.listen((
      isConnected,
    ) {
      if (!isConnected) {
        unawaited(_handleTransportDisconnected());
      } else {
        notifyListeners();
      }
    });

    _reconnectingStateSubscription = connection.reconnectingState.listen((
      isReconnecting,
    ) {
      if (isReconnecting) {
        unawaited(_handleReconnectStarted());
      } else {
        if (_connection?.isConnected == true && _mode == ObdMode.real) {
          _startLiveSource();
        }
      }
    });

    notifyListeners();
  }

  void detachConnection() {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _reconnectingStateSubscription?.cancel();
    _reconnectingStateSubscription = null;

    _connection = null;
    notifyListeners();
  }

  Future<void> startDemoMode() async {
    if (_mode == ObdMode.real || _mode == ObdMode.demo) return;

    _data = const ObdData();

    _demoGenerator = DemoDataGenerator();
    _demoGenerator!.start((ObdData newDemoData) {
      _data = newDemoData;
      notifyListeners();
    });

    _mode = ObdMode.demo;
    notifyListeners();
  }

  Future<void> stopDemoMode() async {
    if (_mode != ObdMode.demo) return;

    _demoGenerator?.stop();
    _demoGenerator = null;

    _mode = ObdMode.idle;
    _data = const ObdData();

    notifyListeners();
  }

  Future<void> startRealMode() async {
    if (_connection == null || _mode == ObdMode.real) return;

    if (_mode == ObdMode.demo) {
      _demoGenerator?.stop();
      _demoGenerator = null;
      _data = const ObdData();
    }

    _mode = ObdMode.real;
    notifyListeners();

    try {
      await _startLiveSource();
    } catch (_) {
      await _stopLive();
      _mode = ObdMode.idle;
      notifyListeners();
    }
  }

  Future<void> stopRealMode() async {
    if (_mode != ObdMode.real) return;

    await _stopLive();

    _mode = ObdMode.idle;
    _data = const ObdData();
    notifyListeners();
  }

  Future<void> _startLiveSource() async {
    await _stopLive();

    final source = LiveObdSource(connection: _connection!, registry: _registry);

    for (final entry in _watchlists.entries) {
      source.setWatchlist(entry.key, entry.value);
    }

    _liveSource = source;

    _stateSubscription = source.stateStream.listen((_) {
      notifyListeners();
    });

    _updatesSubscription = source.updates.listen(_onUpdate);

    await source.start();
  }

  Future<void> _stopLive() async {
    await _stateSubscription?.cancel();
    _stateSubscription = null;

    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    if (_liveSource != null) {
      await _liveSource?.stop();
      await _liveSource?.dispose();
      _liveSource = null;
    }
  }

  Future<void> _handleReconnectStarted() async {
    if (_mode != ObdMode.real) {
      notifyListeners();
      return;
    }

    await _stopLive();

    notifyListeners();
  }

  Future<void> _handleTransportDisconnected() async {
    await _stopLive();

    _mode = ObdMode.idle;
    _data = const ObdData();

    notifyListeners();
  }

  void setWatchlist(WatchSource source, Set<PidKey> keys) {
    if (keys.isEmpty) {
      _watchlists.remove(source);
    } else {
      _watchlists[source] = Set.unmodifiable(keys);
    }

    _liveSource?.setWatchlist(source, keys);
  }

  void clearWatchlist(WatchSource source) {
    setWatchlist(source, const {});
  }

  void _onUpdate(({PidKey key, num value}) update) {
    switch (update.key) {
      case PidKey.engineRpm:
        _data = _data.copyWith(rpm: update.value.toInt());

      case PidKey.vehicleSpeed:
        _data = _data.copyWith(speed: update.value.toInt());

      case PidKey.coolantTemperature:
        _data = _data.copyWith(coolantTemp: update.value.toInt());

      case PidKey.adapterVoltage:
        _data = _data.copyWith(voltage: update.value.toDouble());
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _demoGenerator?.stop();
    _stateSubscription?.cancel();
    _updatesSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _reconnectingStateSubscription?.cancel();

    super.dispose();
  }
}
