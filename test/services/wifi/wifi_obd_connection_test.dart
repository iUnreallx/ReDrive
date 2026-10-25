import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_client.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/polling/polling_controller.dart';
import 'package:redrive/obd/session/obd_session.dart';
import 'package:redrive/obd/source/obd_source_state.dart';
import 'package:redrive/providers/obd_provider.dart';
import 'package:redrive/services/wifi/connection/wifi_obd_connection.dart';

import '../../obd/fakes/fake_elm327_server.dart';

void main() {
  late FakeElm327Server server;
  late WifiObdConnection connection;

  setUp(() async {
    server = await FakeElm327Server.start();
    connection = WifiObdConnection(
      connectTimeout: const Duration(seconds: 1),
      reconnectDelay: const Duration(milliseconds: 10),
    );
  });

  tearDown(() async {
    connection.dispose();
    await server.close();
  });

  test('uses the usual Wi-Fi adapter address by default', () {
    expect(WifiObdConnection.defaultHost, '192.168.0.10');
    expect(WifiObdConnection.defaultPort, 35000);
    expect(connection.host, WifiObdConnection.defaultHost);
    expect(connection.port, WifiObdConnection.defaultPort);
  });

  test('connects to the adapter and reports the connection', () async {
    final states = <bool>[];
    connection.connectionState.listen(states.add);

    final success = await connection.connect(
      host: server.host,
      port: server.port,
    );
    await pumpEventQueue();

    expect(success, isTrue);
    expect(connection.isConnected, isTrue);
    expect(connection.isConnecting, isFalse);
    expect(connection.host, server.host);
    expect(connection.port, server.port);
    expect(states, [true]);
    expect(server.connections, 1);
  });

  test('writes commands unchanged and forwards adapter replies', () async {
    await connection.connect(host: server.host, port: server.port);

    final reply = StringBuffer();
    final prompt = Completer<void>();
    connection.incoming.listen((chunk) {
      reply.write(chunk);
      if (reply.toString().contains('>') && !prompt.isCompleted) {
        prompt.complete();
      }
    });

    await connection.send('ATZ\r');
    await prompt.future.timeout(const Duration(seconds: 2));

    expect(server.received, ['ATZ']);
    expect(reply.toString(), contains('ELM327 v1.5'));
    expect(reply.toString(), endsWith('>'));
  });

  test('send fails when the adapter is not connected', () async {
    expect(() => connection.send('ATZ\r'), throwsStateError);
  });

  test('returns false when nothing listens on the port', () async {
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = closed.port;
    await closed.close();

    final success = await connection.connect(host: '127.0.0.1', port: port);

    expect(success, isFalse);
    expect(connection.isConnected, isFalse);
    expect(connection.isConnecting, isFalse);
  });

  test('disconnect closes the socket and reports it', () async {
    await connection.connect(host: server.host, port: server.port);
    await _waitUntil(() => server.clients.length == 1);

    final states = <bool>[];
    connection.connectionState.listen(states.add);

    await connection.disconnect();
    await _waitUntil(() => server.clients.isEmpty);

    expect(connection.isConnected, isFalse);
    expect(states, [false]);
  });

  test('reconnects to the same adapter when it drops the socket', () async {
    await connection.connect(host: server.host, port: server.port);
    await _waitUntil(() => server.clients.length == 1);

    final connectionStates = <bool>[];
    final reconnectingStates = <bool>[];
    connection.connectionState.listen(connectionStates.add);
    connection.reconnectingState.listen(reconnectingStates.add);

    await server.dropClients();
    await _waitUntil(() => reconnectingStates.length == 2);

    expect(reconnectingStates, [true, false]);
    expect(connectionStates, isEmpty);
    expect(connection.isConnected, isTrue);
    expect(server.connections, 2);

    await connection.send('ATZ\r');
    await _waitUntil(() => server.received.contains('ATZ'));
  });

  test('gives up and disconnects when the adapter is gone', () async {
    await connection.connect(host: server.host, port: server.port);
    await _waitUntil(() => server.clients.length == 1);

    final connectionStates = <bool>[];
    final reconnectingStates = <bool>[];
    connection.connectionState.listen(connectionStates.add);
    connection.reconnectingState.listen(reconnectingStates.add);

    await server.close();
    await _waitUntil(() => reconnectingStates.length == 2);

    expect(connectionStates, [false]);
    expect(reconnectingStates, [true, false]);
    expect(connection.isConnected, isFalse);
    expect(connection.isReconnecting, isFalse);
  });

  test(
    'can be disposed while disconnect is still closing the socket',
    () async {
      final other = WifiObdConnection();

      await other.connect(host: server.host, port: server.port);

      final disconnecting = other.disconnect();
      other.dispose();
      await disconnecting;

      expect(other.isConnected, isFalse);
    },
  );

  test('disconnect stops a reconnect that is in progress', () async {
    final slow = WifiObdConnection(
      reconnectDelay: const Duration(milliseconds: 200),
    );
    addTearDown(slow.dispose);

    await slow.connect(host: server.host, port: server.port);
    await _waitUntil(() => server.clients.length == 1);

    await server.dropClients();
    await _waitUntil(() => slow.isReconnecting);

    await slow.disconnect();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(slow.isConnected, isFalse);
    expect(slow.isReconnecting, isFalse);
    expect(server.connections, 1);
  });

  test('stops reconnecting when the adapter keeps dropping', () async {
    await connection.connect(host: server.host, port: server.port);

    var drops = 0;
    while (connection.isConnected && drops < 10) {
      await _waitUntil(
        () => server.clients.length == 1 && !connection.isReconnecting,
      );
      await server.dropClients();
      drops++;
      await _waitUntil(
        () => connection.isReconnecting || !connection.isConnected,
      );
    }

    expect(drops, 4);
    expect(server.connections, 4);
    expect(connection.isReconnecting, isFalse);
  });

  test('initializes an ELM327 session and reads a PID over TCP', () async {
    await connection.connect(host: server.host, port: server.port);

    final client = ElmClient(connection: connection);
    final session = ObdSession(elmClient: client);
    addTearDown(client.dispose);

    final supportedPids = await session.initialize();
    final response = await client.execute('010C');

    expect(session.state, ObdSessionState.ready);
    expect(supportedPids, isNotEmpty);
    expect(server.received, ['ATZ', 'ATE0', 'ATL0', 'ATSP0', '0100', '010C']);
    expect(response.type, ElmResponseType.data);
    expect(response.lines.last, '41 0C 1A F8');
  });

  test('feeds ObdProvider with live data', () async {
    final provider = ObdProvider();
    addTearDown(provider.dispose);

    await connection.connect(host: server.host, port: server.port);
    provider.attachConnection(connection);
    provider.setWatchlist(WatchSource.visibleScreen, {PidKey.vehicleSpeed});

    await provider.startRealMode();
    await _waitUntil(() => provider.data.speed == 42);

    expect(provider.mode, ObdMode.real);
    expect(provider.state, ObdSourceState.polling);

    await provider.stopRealMode();
  });

  test(
    'resumes polling after the adapter drops the socket mid-command',
    () async {
      final provider = ObdProvider();
      addTearDown(provider.dispose);

      final errors = <Object>[];
      final stages = <ObdRecoveryStage>{};
      provider.errors.listen(errors.add);
      provider.addListener(() => stages.add(provider.recoveryStage));

      await connection.connect(host: server.host, port: server.port);
      provider.attachConnection(connection);
      provider.setWatchlist(WatchSource.visibleScreen, {PidKey.vehicleSpeed});

      await provider.startRealMode();
      await _waitUntil(() => provider.data.speed == 42);

      server.dropOnCommand = '010D';
      await _waitUntil(
        () => server.received.where((command) => command == 'ATZ').length == 2,
      );
      await _waitUntil(
        () =>
            provider.state == ObdSourceState.polling &&
            server.received.lastIndexOf('010D') >
                server.received.lastIndexOf('ATZ'),
      );

      expect(server.connections, 2);
      expect(stages, contains(ObdRecoveryStage.transport));
      expect(provider.mode, ObdMode.real);
      expect(provider.recoveryStage, ObdRecoveryStage.none);
      expect(provider.isDeviceConnected, isTrue);
      expect(errors, isEmpty);

      await provider.stopRealMode();
    },
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));

  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met in time');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
