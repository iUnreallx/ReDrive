import '../decoders/adapter_voltage_decoder.dart';
import '../pid_definition.dart';
import '../pid_key.dart';

final adapterVoltageDefinition = PidDefinition<double>(
  key: PidKey.adapterVoltage,
  command: 'ATRV',
  decoder: decodeAdapterVoltage,
  source: PidSource.adapter,
);
