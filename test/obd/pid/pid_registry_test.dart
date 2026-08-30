import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/pid/pid_definition.dart';
import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/pid/pid_registry.dart';

void main() {
  test('finds engine RPM definition', () {
    final registry = PidRegistry();
    final definition = registry.find(PidKey.engineRpm);

    expect(definition?.command, '010C');
  });

  test('finds vehicle speed definition', () {
    final registry = PidRegistry();
    final definition = registry.find(PidKey.vehicleSpeed);

    expect(definition?.command, '010D');
  });

  test('finds coolant temperature definition', () {
    final registry = PidRegistry();
    final definition = registry.find(PidKey.coolantTemperature);

    expect(definition?.command, '0105');
  });

  test('finds adapter voltage definition', () {
    final registry = PidRegistry();
    final definition = registry.find(PidKey.adapterVoltage);

    expect(definition?.command, 'ATRV');
    expect(definition?.source, PidSource.adapter);
  });

  group('PidRegistry.findSupportedEcuKeys', () {
    test('returns matching ECU PID keys', () {
      final registry = PidRegistry();

      final result = registry.findSupportedEcuKeys({0x05, 0x0C, 0x0D});

      expect(result, {
        PidKey.coolantTemperature,
        PidKey.engineRpm,
        PidKey.vehicleSpeed,
      });
    });

    test('returns only supported ECU PID keys', () {
      final registry = PidRegistry();

      final result = registry.findSupportedEcuKeys({0x0C});

      expect(result, {PidKey.engineRpm});
    });

    test('does not include adapter parameters', () {
      final registry = PidRegistry();

      final result = registry.findSupportedEcuKeys({0x05, 0x0C, 0x0D});

      expect(result.contains(PidKey.adapterVoltage), isFalse);
    });

    test('returns empty set when supported PID set is empty', () {
      final registry = PidRegistry();

      final result = registry.findSupportedEcuKeys({});

      expect(result, isEmpty);
    });

    test('ignores supported PIDs that are not registered', () {
      final registry = PidRegistry();

      final result = registry.findSupportedEcuKeys({0x01, 0x02, 0x03});

      expect(result, isEmpty);
    });
  });
}
