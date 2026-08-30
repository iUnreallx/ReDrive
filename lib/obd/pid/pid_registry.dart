import 'definitions/adapter_voltage_definition.dart';
import 'definitions/coolant_temperature_definition.dart';
import 'definitions/engine_rpm_definition.dart';
import 'definitions/vehicle_speed_definition.dart';
import 'pid_definition.dart';
import 'pid_key.dart';

class PidRegistry {
  final Map<PidKey, PidDefinition<num>> _definitions = {
    PidKey.engineRpm: engineRpmDefinition,
    PidKey.vehicleSpeed: vehicleSpeedDefinition,
    PidKey.coolantTemperature: coolantTemperatureDefinition,
    PidKey.adapterVoltage: adapterVoltageDefinition,
  };

  PidDefinition<num>? find(PidKey key) {
    return _definitions[key];
  }

  Set<PidKey> findSupportedEcuKeys(Set<int> supportedPids) {
    final supportedPidKeySet = <PidKey>{};

    for (final definition in _definitions.values) {
      if (definition.source == PidSource.ecu &&
          definition.pid != null &&
          supportedPids.contains(definition.pid)) {
        supportedPidKeySet.add(definition.key);
      }
    }

    return supportedPidKeySet;
  }
}
