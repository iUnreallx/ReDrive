import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/polling/polling_controller.dart';
import 'package:redrive/obd/source/obd_source_state.dart';
import 'package:redrive/providers/obd_provider.dart';

import '../obd/fakes/fake_obd_connection.dart';

void main() {
  group('ObdProvider modes', () {
    test('starts and stops demo mode', () async {
      final provider = ObdProvider();

      expect(provider.mode, ObdMode.idle);

      await provider.startDemoMode();
      expect(provider.mode, ObdMode.demo);

      await provider.stopDemoMode();
      expect(provider.mode, ObdMode.idle);

      provider.dispose();
    });

    test('starts and stops real mode', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();

      await connection.connect();
      provider.attachConnection(connection);

      final startFuture = provider.startRealMode();
      await _completeHandshake(connection);
      await startFuture;

      expect(provider.mode, ObdMode.real);
      expect(provider.state, ObdSourceState.polling);

      await provider.stopRealMode();
      expect(provider.mode, ObdMode.idle);

      provider.dispose();
      await connection.dispose();
    });

    test('switches from demo mode to real mode', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();

      await connection.connect();
      provider.attachConnection(connection);

      await provider.startDemoMode();
      expect(provider.mode, ObdMode.demo);

      final startFuture = provider.startRealMode();
      await _completeHandshake(connection);
      await startFuture;

      expect(provider.mode, ObdMode.real);
      expect(provider.state, ObdSourceState.polling);

      await provider.stopRealMode();
      provider.dispose();
      await connection.dispose();
    });

    test('cancels real mode while ELM is waiting for ATZ response', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();

      await connection.connect();
      provider.attachConnection(connection);

      final startFuture = provider.startRealMode();
      await _waitForCommand(connection, 'ATZ\r');

      final stopFuture = provider.stopRealMode();
      await Future.wait([startFuture, stopFuture]);
      await pumpEventQueue();

      expect(provider.mode, ObdMode.idle);
      expect(provider.state, ObdSourceState.disconnected);
      expect(connection.sentCommands, ['ATZ\r']);

      provider.dispose();
      await connection.dispose();
    });
  });

  group('ObdProvider Bluetooth reconnect', () {
    test('preserves data and watchlist and restarts ELM', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();

      await connection.connect();
      provider.attachConnection(connection);
      provider.setWatchlist(WatchSource.visibleScreen, {PidKey.vehicleSpeed});

      final startFuture = provider.startRealMode();
      await _completeHandshake(connection);
      await startFuture;

      await _waitForCommand(connection, '010D\r');
      connection.emit('41 0D 2A\r>');
      await _waitUntil(() => provider.data.speed == 42, 'initial speed update');

      final sourceStopped = _nextProviderNotification(
        provider,
        () => provider.state == ObdSourceState.disconnected,
      );
      connection.setReconnecting(true);
      await sourceStopped;

      expect(provider.mode, ObdMode.real);
      expect(provider.data.speed, 42);
      expect(provider.isReconnecting, isTrue);

      connection.setReconnecting(false);
      await _completeHandshake(connection, occurrence: 2);
      await _waitUntil(
        () => provider.state == ObdSourceState.polling,
        'polling after reconnect',
      );
      await _waitForCommand(connection, '010D\r', occurrence: 2);

      expect(provider.mode, ObdMode.real);
      expect(provider.data.speed, 42);
      expect(provider.isReconnecting, isFalse);
      expect(_commandCount(connection, 'ATZ\r'), 2);

      await provider.stopRealMode();
      provider.dispose();
      await connection.dispose();
    });

    test('moves to idle and clears data when reconnect fails', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();

      await connection.connect();
      provider.attachConnection(connection);
      provider.setWatchlist(WatchSource.visibleScreen, {PidKey.vehicleSpeed});

      final startFuture = provider.startRealMode();
      await _completeHandshake(connection);
      await startFuture;

      await _waitForCommand(connection, '010D\r');
      connection.emit('41 0D 2A\r>');
      await _waitUntil(() => provider.data.speed == 42, 'initial speed update');

      final sourceStopped = _nextProviderNotification(
        provider,
        () => provider.state == ObdSourceState.disconnected,
      );
      connection.setReconnecting(true);
      await sourceStopped;

      expect(provider.mode, ObdMode.real);
      expect(provider.data.speed, 42);

      await connection.disconnect();
      await _waitUntil(
        () => provider.mode == ObdMode.idle,
        'idle after disconnect',
      );

      expect(provider.state, ObdSourceState.disconnected);
      expect(provider.data.speed, 0);

      provider.dispose();
      await connection.dispose();
    });
  });
}

Future<void> _completeHandshake(
  FakeObdConnection connection, {
  int occurrence = 1,
}) async {
  await _waitForCommand(connection, 'ATZ\r', occurrence: occurrence);
  connection.emit('ELM327 v1.5\r>');

  await _waitForCommand(connection, 'ATE0\r', occurrence: occurrence);
  connection.emit('OK\r>');

  await _waitForCommand(connection, 'ATL0\r', occurrence: occurrence);
  connection.emit('OK\r>');

  await _waitForCommand(connection, 'ATSP0\r', occurrence: occurrence);
  connection.emit('OK\r>');

  await _waitForCommand(connection, '0100\r', occurrence: occurrence);
  connection.emit('41 00 08 18 00 00\r>');
}

Future<void> _waitForCommand(
  FakeObdConnection connection,
  String command, {
  int occurrence = 1,
}) => _waitUntil(
  () => _commandCount(connection, command) >= occurrence,
  '$command occurrence $occurrence',
);

int _commandCount(FakeObdConnection connection, String command) =>
    connection.sentCommands.where((sent) => sent == command).length;

Future<void> _nextProviderNotification(
  ObdProvider provider,
  bool Function() condition,
) async {
  final completer = Completer<void>();

  void listener() {
    if (condition() && !completer.isCompleted) {
      completer.complete();
    }
  }

  provider.addListener(listener);
  try {
    await completer.future.timeout(const Duration(seconds: 3));
  } finally {
    provider.removeListener(listener);
  }
}

Future<void> _waitUntil(bool Function() condition, String description) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Timed out waiting for $description');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
