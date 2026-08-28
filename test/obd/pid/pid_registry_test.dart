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
}
