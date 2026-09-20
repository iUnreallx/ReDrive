import 'package:flutter_test/flutter_test.dart';
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
  });
}

Future<void> _completeHandshake(FakeObdConnection connection) async {
  await _waitForCommand(connection, 'ATZ\r');
  connection.emit('ELM327 v1.5\r>');

  await _waitForCommand(connection, 'ATE0\r');
  connection.emit('OK\r>');

  await _waitForCommand(connection, 'ATL0\r');
  connection.emit('OK\r>');

  await _waitForCommand(connection, 'ATSP0\r');
  connection.emit('OK\r>');

  await _waitForCommand(connection, '0100\r');
  connection.emit('41 00 08 18 00 00\r>');
}

Future<void> _waitForCommand(
  FakeObdConnection connection,
  String command,
) async {
  while (!connection.sentCommands.contains(command)) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
