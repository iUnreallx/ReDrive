import 'package:flutter_test/flutter_test.dart';

import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/pid/pid_registry.dart';
import 'package:redrive/obd/source/live_obd_source.dart';
import 'package:redrive/obd/source/obd_source_state.dart';

import '../fakes/fake_obd_connection.dart';

void main() {
  test('starts disconnected with empty data', () async {
    final connection = FakeObdConnection();

    final source = LiveObdSource(
      connection: connection,
      registry: PidRegistry(),
    );

    expect(source.state, ObdSourceState.disconnected);
    expect(source.supportedKeys, isEmpty);
    expect(source.latestValues, isEmpty);

    await source.dispose();
  });

  test('successful start initializes session and enters polling', () async {
    final connection = FakeObdConnection();

    final source = LiveObdSource(
      connection: connection,
      registry: PidRegistry(),
    );

    final statesFuture = expectLater(
      source.stateStream,
      emitsInOrder([
        ObdSourceState.connecting,
        ObdSourceState.initializing,
        ObdSourceState.polling,
      ]),
    );

    final startFuture = source.start();

    while (!connection.sentCommands.contains('ATZ\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    expect(connection.sentCommands, ['ATZ\r']);

    connection.emit('ATZ\rELM327 v1.5\r>');

    while (!connection.sentCommands.contains('ATE0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATL0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATSP0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('0100\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('41 00 08 18 00 00\r>');

    await startFuture;
    await statesFuture;

    expect(source.state, ObdSourceState.polling);

    expect(source.supportedKeys, {
      PidKey.coolantTemperature,
      PidKey.engineRpm,
      PidKey.vehicleSpeed,
    });

    expect(connection.sentCommands, [
      'ATZ\r',
      'ATE0\r',
      'ATL0\r',
      'ATSP0\r',
      '0100\r',
    ]);

    await source.dispose();
    await connection.dispose();
  });

  test('screen demand starts polling requested PID', () async {
    final connection = FakeObdConnection();

    final source = LiveObdSource(
      connection: connection,
      registry: PidRegistry(),
    );

    source.setScreenDemand({PidKey.engineRpm});

    final startFuture = source.start();

    while (!connection.sentCommands.contains('ATZ\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('ATZ\rELM327 v1.5\r>');

    while (!connection.sentCommands.contains('ATE0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATL0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATSP0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('0100\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('41 00 08 18 00 00\r>');

    await startFuture;

    while (!connection.sentCommands.contains('010C\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    expect(connection.sentCommands, contains('010C\r'));

    final updateFuture = source.updates.first;

    connection.emit('41 0C 1A F8\r>');

    final update = await updateFuture;

    expect(update.key, PidKey.engineRpm);

    expect(update.value, 1726.0);

    expect(source.latestValues[PidKey.engineRpm], 1726.0);

    await source.dispose();
    await connection.dispose();
  });

  test('unsupported ECU PID is not polled', () async {
    final connection = FakeObdConnection();

    final source = LiveObdSource(
      connection: connection,
      registry: PidRegistry(),
    );

    source.setScreenDemand({PidKey.vehicleSpeed});

    final startFuture = source.start();

    while (!connection.sentCommands.contains('ATZ\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('ATZ\rELM327 v1.5\r>');

    while (!connection.sentCommands.contains('ATE0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATL0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATSP0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('0100\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('41 00 00 10 00 00\r>');

    await startFuture;

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(connection.sentCommands, isNot(contains('010D\r')));

    expect(source.supportedKeys.contains(PidKey.vehicleSpeed), isFalse);

    await source.dispose();
    await connection.dispose();
  });

  test('initialization failure moves source to error', () async {
    final connection = FakeObdConnection();

    final source = LiveObdSource(
      connection: connection,
      registry: PidRegistry(),
    );

    final startFuture = source.start();

    while (!connection.sentCommands.contains('ATZ\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('NO DATA\r>');

    await startFuture;

    expect(source.state, ObdSourceState.error);

    expect(source.latestValues, isEmpty);

    await source.dispose();
    await connection.dispose();
  });

  test('stop returns source to disconnected', () async {
    final connection = FakeObdConnection();

    final source = LiveObdSource(
      connection: connection,
      registry: PidRegistry(),
    );

    final startFuture = source.start();

    while (!connection.sentCommands.contains('ATZ\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('ATZ\rELM327 v1.5\r>');

    while (!connection.sentCommands.contains('ATE0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATL0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATSP0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('0100\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('41 00 08 18 00 00\r>');

    await startFuture;

    expect(source.state, ObdSourceState.polling);

    expect(source.supportedKeys, isNotEmpty);

    await source.stop();

    expect(source.state, ObdSourceState.disconnected);

    expect(source.supportedKeys, isEmpty);

    expect(source.latestValues, isEmpty);

    await source.dispose();
    await connection.dispose();
  });

  test('polling error moves source to error and forwards error', () async {
    final connection = FakeObdConnection();

    final source = LiveObdSource(
      connection: connection,
      registry: PidRegistry(),
    );

    final startFuture = source.start();

    while (!connection.sentCommands.contains('ATZ\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('ATZ\rELM327 v1.5\r>');

    while (!connection.sentCommands.contains('ATE0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATL0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('ATSP0\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('OK\r>');

    while (!connection.sentCommands.contains('0100\r')) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    connection.emit('41 00 08 18 00 00\r>');

    await startFuture;

    expect(source.state, ObdSourceState.polling);

    final pollingError = Exception('polling failed');

    connection.sendError = pollingError;

    final errorExpectation = expectLater(
      source.updates,
      emitsError(same(pollingError)),
    );

    final stateExpectation = expectLater(
      source.stateStream,
      emits(ObdSourceState.error),
    );

    source.setScreenDemand({PidKey.vehicleSpeed});

    await errorExpectation;
    await stateExpectation;

    expect(connection.sentCommands, contains('010D\r'));

    expect(source.state, ObdSourceState.error);

    await pumpEventQueue();

    await source.dispose();
    await connection.dispose();
  });
}
