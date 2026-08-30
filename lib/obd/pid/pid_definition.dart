import '../elm/elm_response.dart';
import 'pid_key.dart';

typedef PidDecoder<T> = T Function(ElmResponse response);

enum PidSource { ecu, adapter }

class PidDefinition<T> {
  final PidKey key;
  final String command;
  final PidDecoder<T> decoder;
  final PidSource source;
  final int? pid;

  const PidDefinition({
    required this.key,
    required this.command,
    required this.decoder,
    this.source = PidSource.ecu,
    this.pid,
  });
}
