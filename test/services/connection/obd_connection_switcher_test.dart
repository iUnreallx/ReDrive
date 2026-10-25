import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/source/obd_source_state.dart';
import 'package:redrive/providers/obd_provider.dart';
import 'package:redrive/services/connection/obd_connection_switcher.dart';

import '../../obd/fakes/fake_obd_connection.dart';

void main() {
  late ObdProvider provider;
  late FakeObdConnection bluetooth;
  late FakeObdConnection wifi;
  late ObdConnectionSwitcher switcher;

  setUp(() {
    provider = ObdProvider();
    bluetooth = FakeObdConnection();
    wifi = FakeObdConnection();
    switcher = ObdConnectionSwitcher(
      provider: provider,
      connections: [bluetooth, wifi],
    );
  });

  tearDown(() async {
    switcher.dispose();
    provider.dispose();
    await bluetooth.dispose();
    await wifi.dispose();
  });

  test('attaches the first connection right away', () async {
    expect(switcher.active, same(bluetooth));

    await bluetooth.connect();
    await pumpEventQueue();

    expect(provider.isDeviceConnected, isTrue);
  });

  test('follows the transport that connected last', () async {
    await wifi.connect();
    await pumpEventQueue();

    expect(switcher.active, same(wifi));
    expect(provider.isDeviceConnected, isTrue);

    await wifi.disconnect();
    await pumpEventQueue();
    expect(provider.isDeviceConnected, isFalse);

    await bluetooth.connect();
    await pumpEventQueue();

    expect(switcher.active, same(bluetooth));
    expect(provider.isDeviceConnected, isTrue);
  });

  test('disconnects the previous transport when another connects', () async {
    await bluetooth.connect();
    await pumpEventQueue();

    await wifi.connect();
    await pumpEventQueue();

    expect(bluetooth.isConnected, isFalse);
    expect(wifi.isConnected, isTrue);
    expect(provider.isDeviceConnected, isTrue);
  });

  test('leaves no source running on the previous transport', () async {
    await bluetooth.connect();
    await pumpEventQueue();

    final startFuture = provider.startRealMode();
    await _waitUntil(() => bluetooth.sentCommands.contains('ATZ\r'));
    expect(provider.mode, ObdMode.real);

    await wifi.connect();
    await _waitUntil(() => identical(switcher.active, wifi));
    await startFuture;
    bluetooth.emit('ELM327 v1.5\r>');
    await pumpEventQueue();

    expect(provider.mode, ObdMode.idle);
    expect(provider.state, ObdSourceState.disconnected);
    expect(bluetooth.sentCommands, ['ATZ\r']);
    expect(wifi.sentCommands, isEmpty);
  });

  test(
    'keeps the transport that connected last when both connect at once',
    () async {
      wifi.connect();
      bluetooth.connect();
      await pumpEventQueue();

      expect(switcher.active, same(bluetooth));
      expect(bluetooth.isConnected, isTrue);
      expect(wifi.isConnected, isFalse);
      expect(provider.isDeviceConnected, isTrue);
    },
  );

  test('ignores a transport that reconnects while already active', () async {
    await bluetooth.connect();
    await pumpEventQueue();

    await bluetooth.disconnect();
    await bluetooth.connect();
    await pumpEventQueue();

    expect(switcher.active, same(bluetooth));
    expect(provider.isDeviceConnected, isTrue);
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));

  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met in time');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
