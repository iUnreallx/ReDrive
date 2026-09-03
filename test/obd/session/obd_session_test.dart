import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_client.dart';
import 'package:redrive/obd/session/obd_session.dart';

import '../fakes/fake_obd_connection.dart';

void main() {
  test('initializes session through sequential handshake', () async {
    final connection = FakeObdConnection();
    final client = ElmClient(connection: connection);
    final session = ObdSession(elmClient: client);

    addTearDown(() async {
      await client.dispose();
      await connection.dispose();
    });

    final initialization = session.initialize();

    expect(session.state, ObdSessionState.initializing);
    expect(connection.sentCommands, ['ATZ\r']);

    connection.emit('ELM327 v1.5\r>');
    await pumpEventQueue();
    expect(connection.sentCommands, ['ATZ\r', 'ATE0\r']);

    connection.emit('OK\r>');
    await pumpEventQueue();
    expect(connection.sentCommands, ['ATZ\r', 'ATE0\r', 'ATL0\r']);

    connection.emit('OK\r>');
    await pumpEventQueue();
    expect(connection.sentCommands, ['ATZ\r', 'ATE0\r', 'ATL0\r', 'ATSP0\r']);

    connection.emit('OK\r>');
    await pumpEventQueue();
    expect(connection.sentCommands, [
      'ATZ\r',
      'ATE0\r',
      'ATL0\r',
      'ATSP0\r',
      '0100\r',
    ]);

    connection.emit('41 00 08 18 00 00\r>');
    final supportedPids = await initialization;

    expect(supportedPids, {5, 12, 13});
    expect(session.state, ObdSessionState.ready);
    expect(session.lastError, isNull);
  });

  test('moves to error when supported PID response is malformed', () async {
    final connection = FakeObdConnection();
    final client = ElmClient(connection: connection);
    final session = ObdSession(elmClient: client);

    addTearDown(() async {
      await client.dispose();
      await connection.dispose();
    });

    final initialization = session.initialize();

    connection.emit('ELM327 v1.5\r>');
    await pumpEventQueue();
    connection.emit('OK\r>');
    await pumpEventQueue();
    connection.emit('OK\r>');
    await pumpEventQueue();
    connection.emit('OK\r>');
    await pumpEventQueue();
    connection.emit('41 0C 08 18 00 00\r>');

    await expectLater(initialization, throwsA(isA<FormatException>()));

    expect(session.state, ObdSessionState.error);
    expect(session.lastError, isA<FormatException>());
  });

  test('stops handshake when command returns unexpected response', () async {
    final connection = FakeObdConnection();
    final client = ElmClient(connection: connection);
    final session = ObdSession(elmClient: client);

    addTearDown(() async {
      await client.dispose();
      await connection.dispose();
    });

    final initialization = session.initialize();

    connection.emit('ELM327 v1.5\r>');
    await pumpEventQueue();

    expect(connection.sentCommands, ['ATZ\r', 'ATE0\r']);

    connection.emit('?\r>');

    await expectLater(initialization, throwsA(isA<StateError>()));

    expect(session.state, ObdSessionState.error);
    expect(session.lastError, isA<StateError>());

    expect(connection.sentCommands, ['ATZ\r', 'ATE0\r']);
  });

  test('moves to error when ElmClient fails', () async {
    final connection = FakeObdConnection();
    final client = ElmClient(connection: connection);
    final session = ObdSession(elmClient: client);

    addTearDown(() async {
      await client.dispose();
      await connection.dispose();
    });

    final failure = StateError('send failed');
    connection.sendError = failure;

    await expectLater(session.initialize(), throwsA(same(failure)));

    expect(session.state, ObdSessionState.error);
    expect(session.lastError, same(failure));
    expect(connection.sentCommands, ['ATZ\r']);
  });
}
