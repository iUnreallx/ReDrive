import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:redrive/obd/pid/pid_key.dart';

import '../models/obd_data.dart';
import '../services/obd_connection.dart';
import '../obd/pid/pid_registry.dart';
import '../obd/source/live_obd_source.dart';
import '../obd/source/obd_source_state.dart';

class ObdProviderV2 extends ChangeNotifier {
  final ObdConnection _connection;
  final LiveObdSource _liveSource;

  ObdProviderV2(ObdConnection connection)
    : _connection = connection,
      _liveSource = LiveObdSource(
        connection: connection,
        registry: PidRegistry(),
      ) {
    _stateSubscription = _liveSource.stateStream.listen((_) {
      notifyListeners();
    });
    _updatesSubscription = _liveSource.updates.listen(_onUpdate);
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

  StreamSubscription<({PidKey key, num value})>? _updatesSubscription;

  bool get isDeviceConnected => _connection.isConnected;

  ObdData _data = const ObdData();
  ObdData get data => _data;

  bool _isRealMode = false;
  bool get isRealMode => _isRealMode;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  ObdSourceState get state => _liveSource.state;

  StreamSubscription<ObdSourceState>? _stateSubscription;

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _updatesSubscription?.cancel();

    super.dispose();
  }
}
