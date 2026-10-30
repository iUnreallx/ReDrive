import 'dart:async';

import 'package:redrive/obd/connection/obd_connection.dart';
import 'package:redrive/providers/obd_provider.dart';

/// Keeps [ObdProvider] attached to the transport that connected last.
///
/// Only one adapter is used at a time, so the previous transport is
/// disconnected after the switch.
class ObdConnectionSwitcher {
  final ObdProvider _provider;
  final List<StreamSubscription<bool>> _subscriptions = [];

  ObdConnection _active;
  ObdConnection get active => _active;

  /// The first of [connections] is attached right away.
  ObdConnectionSwitcher({
    required ObdProvider provider,
    required List<ObdConnection> connections,
  }) : _provider = provider,
       _active = connections.first {
    _provider.attachConnection(_active);

    for (final connection in connections) {
      _subscriptions.add(
        connection.connectionState.listen((isConnected) {
          if (isConnected) unawaited(_switchTo(connection));
        }),
      );
    }
  }

  Future<void> _switchTo(ObdConnection connection) async {
    if (identical(connection, _active)) return;

    final previous = _active;
    _active = connection;

    await _provider.detachConnection();
    if (!identical(connection, _active)) return;

    _provider.attachConnection(connection);

    if (previous.isConnected || previous.isReconnecting) {
      await previous.disconnect();
    }
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
