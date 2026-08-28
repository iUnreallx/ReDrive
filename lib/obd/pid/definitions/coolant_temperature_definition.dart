import '../decoders/coolant_temperature_decoder.dart';
import '../pid_definition.dart';
import '../pid_key.dart';

final coolantTemperatureDefinition = PidDefinition<int>(
  key: PidKey.coolantTemperature,
  command: '0105',
  decoder: decodeCoolantTemperature,
);
