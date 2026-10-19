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

  group('ObdProvider recovery stage', () {
    test('is none when idle and nothing is reconnecting', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();

      await connection.connect();
      provider.attachConnection(connection);

      expect(provider.recoveryStage, ObdRecoveryStage.none);
      expect(provider.isEcuConnected, isFalse);

      provider.dispose();
      await connection.dispose();
    });

    test('shows transport while reconnecting even in idle and notifies when '
        'reconnect ends', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();

      await connection.connect();
      provider.attachConnection(connection);

      connection.setReconnecting(true);
      await pumpEventQueue();

      expect(provider.mode, ObdMode.idle);
      expect(provider.recoveryStage, ObdRecoveryStage.transport);

      final stageCleared = _nextProviderNotification(
        provider,
        () => provider.recoveryStage == ObdRecoveryStage.none,
      );
      connection.setReconnecting(false);
      await stageCleared;

      expect(provider.recoveryStage, ObdRecoveryStage.none);

      provider.dispose();
      await connection.dispose();
    });

    test(
      'does not start real mode while the transport is reconnecting',
      () async {
        final provider = ObdProvider();
        final connection = FakeObdConnection();

        await connection.connect();
        provider.attachConnection(connection);

        connection.setReconnecting(true);
        await pumpEventQueue();

        await provider.startRealMode();

        expect(provider.mode, ObdMode.idle);
        expect(connection.sentCommands, isEmpty);

        provider.dispose();
        await connection.dispose();
      },
    );

    test(
      'is not connected when the link drops during first initialization',
      () async {
        final provider = ObdProvider();
        final connection = FakeObdConnection();

        await connection.connect();
        provider.attachConnection(connection);

        final startFuture = provider.startRealMode();
        await _waitForCommand(connection, 'ATZ\r');

        expect(provider.state, ObdSourceState.initializing);
        expect(provider.isEcuConnected, isFalse);

        connection.setReconnecting(true);
        await startFuture;
        await pumpEventQueue();

        expect(provider.recoveryStage, ObdRecoveryStage.transport);
        expect(provider.isEcuConnected, isFalse);

        await provider.stopRealMode();
        provider.dispose();
        await connection.dispose();
      },
    );

    test('keeps session stage while ELM re-initializes and clears it on first '
        'data', () async {
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

      expect(provider.recoveryStage, ObdRecoveryStage.none);
      expect(provider.isEcuConnected, isTrue);

      final sourceStopped = _nextProviderNotification(
        provider,
        () => provider.state == ObdSourceState.disconnected,
      );
      connection.setReconnecting(true);
      await sourceStopped;

      expect(provider.recoveryStage, ObdRecoveryStage.transport);
      expect(provider.isEcuConnected, isTrue);

      connection.setReconnecting(false);
      await _waitForCommand(connection, 'ATZ\r', occurrence: 2);

      expect(provider.state, ObdSourceState.initializing);
      expect(provider.recoveryStage, ObdRecoveryStage.session);
      expect(provider.isEcuConnected, isTrue);

      await _completeHandshake(connection, occurrence: 2);
      await _waitUntil(
        () => provider.state == ObdSourceState.polling,
        'polling after reconnect',
      );
      await _waitForCommand(connection, '010D\r', occurrence: 2);
      connection.emit('41 0D 2B\r>');
      await _waitUntil(() => provider.data.speed == 43, 'speed after resume');

      expect(provider.recoveryStage, ObdRecoveryStage.none);

      await provider.stopRealMode();
      provider.dispose();
      await connection.dispose();
    });
  });

  group('ObdProvider source failure escalation', () {
    test('asks the transport to reconnect once and recovers', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();
      final errors = <Object>[];
      provider.errors.listen(errors.add);

      await connection.connect();
      provider.attachConnection(connection);
      provider.setWatchlist(WatchSource.visibleScreen, {PidKey.vehicleSpeed});

      connection.onReconnect = () async => connection.setReconnecting(true);

      final startFuture = provider.startRealMode();
      await _completeHandshake(connection);
      await startFuture;

      await _waitForCommand(connection, '010D\r');
      connection.emit('41 0D 2A\r>');
      await _waitUntil(() => provider.data.speed == 42, 'initial speed update');

      connection.sendError = StateError('adapter stuck');
      await _waitUntil(
        () => connection.reconnectCalls == 1,
        'transport reconnect request',
      );

      expect(provider.isReconnecting, isTrue);
      expect(provider.recoveryStage, ObdRecoveryStage.transport);
      expect(provider.mode, ObdMode.real);

      connection.sendError = null;
      final speedBefore = _commandCount(connection, '010D\r');
      final handshake = _completeNextHandshake(connection);
      connection.setReconnecting(false);
      await handshake;
      await _waitUntil(
        () => provider.state == ObdSourceState.polling,
        'polling after transport reconnect',
      );

      await _waitForCommand(connection, '010D\r', occurrence: speedBefore + 1);
      connection.emit('41 0D 2C\r>');
      await _waitUntil(() => provider.data.speed == 44, 'speed after recovery');

      expect(provider.mode, ObdMode.real);
      expect(provider.recoveryStage, ObdRecoveryStage.none);
      expect(connection.reconnectCalls, 1);
      expect(errors, isEmpty);

      await provider.stopRealMode();
      provider.dispose();
      await connection.dispose();
    });

    test('gives up with one error when the second attempt fails too', () async {
      final provider = ObdProvider();
      final connection = FakeObdConnection();
      final errors = <Object>[];
      provider.errors.listen(errors.add);

      await connection.connect();
      provider.attachConnection(connection);
      provider.setWatchlist(WatchSource.visibleScreen, {PidKey.vehicleSpeed});

      connection.onReconnect = () async => connection.setReconnecting(true);

      final startFuture = provider.startRealMode();
      await _completeHandshake(connection);
      await startFuture;

      await _waitForCommand(connection, '010D\r');
      connection.emit('41 0D 2A\r>');
      await _waitUntil(() => provider.data.speed == 42, 'initial speed update');

      connection.sendError = StateError('adapter stuck');
      await _waitUntil(
        () => connection.reconnectCalls == 1,
        'transport reconnect request',
      );

      connection.setReconnecting(false);
      await _waitUntil(
        () => provider.mode == ObdMode.idle,
        'idle after the second failure',
      );
      await pumpEventQueue();

      expect(provider.recoveryStage, ObdRecoveryStage.none);
      expect(provider.data.speed, 0);
      expect(connection.reconnectCalls, 1);
      expect(errors, hasLength(1));

      provider.dispose();
      await connection.dispose();
    });

    test(
      'reports connection loss only if it happened during recovery',
      () async {
        final lostProvider = ObdProvider();
        final lostConnection = FakeObdConnection();
        final lostErrors = <Object>[];
        lostProvider.errors.listen(lostErrors.add);

        await lostConnection.connect();
        lostProvider.attachConnection(lostConnection);

        var startFuture = lostProvider.startRealMode();
        await _completeHandshake(lostConnection);
        await startFuture;

        lostConnection.setReconnecting(true);
        await pumpEventQueue();
        await lostConnection.disconnect();
        await _waitUntil(
          () => lostProvider.mode == ObdMode.idle,
          'idle after failed reconnect',
        );

        expect(lostErrors, hasLength(1));

        lostProvider.dispose();
        await lostConnection.dispose();

        final userProvider = ObdProvider();
        final userConnection = FakeObdConnection();
        final userErrors = <Object>[];
        userProvider.errors.listen(userErrors.add);

        await userConnection.connect();
        userProvider.attachConnection(userConnection);

        startFuture = userProvider.startRealMode();
        await _completeHandshake(userConnection);
        await startFuture;

        await userConnection.disconnect();
        await _waitUntil(
          () => userProvider.mode == ObdMode.idle,
          'idle after user disconnect',
        );
        await pumpEventQueue();

        expect(userErrors, isEmpty);

        userProvider.dispose();
        await userConnection.dispose();
      },
    );
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

/// Completes the next handshake, however many failed attempts came before it.
///
/// A failed ATZ never reaches ATE0, so the commands are counted separately,
/// starting from the moment this helper is called.
Future<void> _completeNextHandshake(FakeObdConnection connection) async {
  const steps = {
    'ATZ\r': 'ELM327 v1.5\r>',
    'ATE0\r': 'OK\r>',
    'ATL0\r': 'OK\r>',
    'ATSP0\r': 'OK\r>',
    '0100\r': '41 00 08 18 00 00\r>',
  };
  final before = {
    for (final command in steps.keys)
      command: _commandCount(connection, command),
  };

  for (final step in steps.entries) {
    await _waitForCommand(
      connection,
      step.key,
      occurrence: before[step.key]! + 1,
    );
    connection.emit(step.value);
  }
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
