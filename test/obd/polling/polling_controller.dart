import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_client.dart';
import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/pid/pid_registry.dart';
import 'package:redrive/obd/polling/polling_controller.dart';
import '../fakes/fake_obd_connection.dart';

void main() {
  late PidRegistry registry;
  late FakeObdConnection connection;
  late ElmClient elmClient;

  setUp(() {
    registry = PidRegistry();
    connection = FakeObdConnection();
    elmClient = ElmClient(connection: connection);
  });

  tearDown(() async {
    await elmClient.dispose();
    await connection.dispose();
  });

  test('computes union of keys requested by different sources', () {
    final controller = PollingController(
      elmClient: elmClient,
      registry: registry,
      supportedEcuKeys: {
        PidKey.vehicleSpeed,
        PidKey.engineRpm,
        PidKey.coolantTemperature,
      },
    );

    controller.updateDemand(PollingDemandSource.visibleScreen, {
      PidKey.vehicleSpeed,
      PidKey.engineRpm,
    });
    controller.updateDemand(PollingDemandSource.backgroundMonitoring, {
      PidKey.vehicleSpeed,
      PidKey.coolantTemperature,
    });
    controller.updateDemand(PollingDemandSource.session, {
      PidKey.adapterVoltage,
    });

    final effective = controller.computeEffectiveKeys();

    expect(effective, {
      PidKey.vehicleSpeed,
      PidKey.engineRpm,
      PidKey.coolantTemperature,
      PidKey.adapterVoltage,
    });
  });

  test('removes keys when source demand is cleared or empty', () {
    final controller = PollingController(
      elmClient: elmClient,
      registry: registry,
      supportedEcuKeys: {PidKey.vehicleSpeed, PidKey.engineRpm},
    );

    controller.updateDemand(PollingDemandSource.visibleScreen, {
      PidKey.engineRpm,
    });
    controller.updateDemand(PollingDemandSource.backgroundMonitoring, {
      PidKey.vehicleSpeed,
    });

    controller.updateDemand(PollingDemandSource.visibleScreen, {});

    final effective = controller.computeEffectiveKeys();

    expect(effective, {PidKey.vehicleSpeed});
  });

  test('filters out unsupported ECU PIDs', () {
    final controller = PollingController(
      elmClient: elmClient,
      registry: registry,
      supportedEcuKeys: {PidKey.engineRpm},
    );

    controller.updateDemand(PollingDemandSource.visibleScreen, {
      PidKey.vehicleSpeed,
      PidKey.engineRpm,
    });

    final effective = controller.computeEffectiveKeys();

    expect(effective, {PidKey.engineRpm});
    expect(effective.contains(PidKey.vehicleSpeed), isFalse);
  });

  test('always allows adapter parameters without checking ECU support', () {
    final controller = PollingController(
      elmClient: elmClient,
      registry: registry,
      supportedEcuKeys: {},
    );

    controller.updateDemand(PollingDemandSource.visibleScreen, {
      PidKey.adapterVoltage,
      PidKey.vehicleSpeed,
    });

    final effective = controller.computeEffectiveKeys();

    expect(effective, {PidKey.adapterVoltage});
  });

  test(
    'polls requested PID and emits value through stream and latestValues',
    () async {
      final controller = PollingController(
        elmClient: elmClient,
        registry: registry,
        supportedEcuKeys: {PidKey.vehicleSpeed},
      );

      addTearDown(controller.dispose);

      controller.updateDemand(PollingDemandSource.visibleScreen, {
        PidKey.vehicleSpeed,
      });

      final emittedValues = <({PidKey key, num value})>[];
      final subscription = controller.updates.listen(emittedValues.add);
      addTearDown(subscription.cancel);

      controller.start();

      await pumpEventQueue();
      expect(connection.sentCommands, ['010D\r']);

      connection.emit('41 0D 2A\r>');
      await pumpEventQueue();

      expect(controller.latestValues[PidKey.vehicleSpeed], 42);
      expect(emittedValues.length, 1);
      expect(emittedValues.first.key, PidKey.vehicleSpeed);
      expect(emittedValues.first.value, 42);

      controller.stop();
    },
  );

  test('stops polling loop when stop is called', () async {
    final controller = PollingController(
      elmClient: elmClient,
      registry: registry,
      supportedEcuKeys: {PidKey.vehicleSpeed},
    );

    addTearDown(controller.dispose);

    controller.updateDemand(PollingDemandSource.visibleScreen, {
      PidKey.vehicleSpeed,
    });

    controller.start();
    await pumpEventQueue();
    expect(connection.sentCommands, ['010D\r']);

    controller.stop();

    connection.emit('41 0D 2A\r>');
    await pumpEventQueue();

    connection.sentCommands.clear();
    await pumpEventQueue();

    expect(connection.sentCommands, isEmpty);
    expect(controller.isPolling, isFalse);
  });
}
