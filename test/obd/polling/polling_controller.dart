import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/pid/pid_registry.dart';
import 'package:redrive/obd/polling/polling_controller.dart';

void main() {
  late PidRegistry registry;

  setUp(() {
    registry = PidRegistry();
  });

  test('computes union of keys requested by different sources', () {
    final controller = PollingController(
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
}
