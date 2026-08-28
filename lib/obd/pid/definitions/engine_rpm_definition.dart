import '../decoders/engine_rpm_decoder.dart';
import '../pid_definition.dart';
import '../pid_key.dart';

final PidDefinition<double> engineRpmDefinition = PidDefinition<double>(
  key: PidKey.engineRpm,
  command: "010C",
  decoder: decodeEngineRpm,
);
