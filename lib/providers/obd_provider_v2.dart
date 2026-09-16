import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:redrive/obd/pid/pid_key.dart';

import '../obd/models/obd_data.dart';
import '../obd/connection/obd_connection.dart';
import '../obd/pid/pid_registry.dart';
import '../obd/source/live_obd_source.dart';
import '../obd/source/obd_source_state.dart';

enum ObdMode { idle, demo, real }

class ObdProviderV2 extends ChangeNotifier {
  ObdConnection? _connection;
  LiveObdSource? _liveSource;
  final PidRegistry _registry;

  ObdProviderV2({PidRegistry? registry})
    : _registry = registry ?? PidRegistry();

  void attachConnection(ObdConnection connection) {
    _connection = connection;
    notifyListeners();
  }

  void detachConnection() {
    _connection = null;
    notifyListeners();
  }

  StreamSubscription<({PidKey key, num value})>? _updatesSubscription;
  StreamSubscription<ObdSourceState>? _stateSubscription;

  bool get isDeviceConnected => _connection?.isConnected ?? false;
  ObdSourceState get state => _liveSource?.state ?? ObdSourceState.disconnected;

  ObdData _data = const ObdData();
  ObdData get data => _data;

  ObdMode _mode = ObdMode.idle;
  ObdMode get mode => _mode;

  Future<void> startRealMode() async {
    if (_connection == null || _mode == ObdMode.real) return;

    await _stopLive();

    final source = LiveObdSource(connection: _connection!, registry: _registry);
    _liveSource = source;

    _stateSubscription = source.stateStream.listen((_) {
      notifyListeners();
    });

    _updatesSubscription = source.updates.listen(_onUpdate);

    _mode = ObdMode.real;
    notifyListeners();

    try {
      await source.start();
    } catch (_) {
      await _stopLive();
      _mode = ObdMode.idle;
      notifyListeners();
    }
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

  Future<void> stop() async {
    await _stopLive();

    _mode = ObdMode.idle;
    _data = const ObdData();
    notifyListeners();
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
    _stateSubscription?.cancel();
    _updatesSubscription?.cancel();

    super.dispose();
  }
}
