enum ElmResponseType {
  ok,
  data,
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

  const ElmResponse({
    required this.type,
    required this.raw,
    this.lines = const [],
    this.wasSearching = false,
  });
}
