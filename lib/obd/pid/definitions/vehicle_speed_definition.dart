import '../decoders/vehicle_speed_decoder.dart';
import '../pid_definition.dart';
import '../pid_key.dart';

final vehicleSpeedDefinition = PidDefinition<int>(
  key: PidKey.vehicleSpeed,
  command: '010D',
  decoder: decodeVehicleSpeed,
);
