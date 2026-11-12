enum ElmResponseType {
  ok,
  data,
  multiFrame,
  adapterInfo,
  adapterVoltage,
  noData,
  stopped,
  unableToConnect,
  busError,
  adapterError,
  unknownCommand,
  malformed,
}

class ElmResponse {
  final ElmResponseType type;
  final String raw;
  final List<String> lines;
  final bool wasSearching;
  final List<int>? assembledBytes;

  const ElmResponse({
    required this.type,
    required this.raw,
    this.lines = const [],
    this.wasSearching = false,
    this.assembledBytes,
  });
}
