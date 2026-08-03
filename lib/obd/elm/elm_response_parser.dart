import 'elm_response.dart';

class ElmResponseParser {
  const ElmResponseParser();

  static const Map<String, ElmResponseType> _exactTypes = {
    'OK': ElmResponseType.ok,
    'NO DATA': ElmResponseType.noData,
    'STOPPED': ElmResponseType.stopped,
    'UNABLE TO CONNECT': ElmResponseType.unableToConnect,
    'BUS INIT: ERROR': ElmResponseType.busError,
    'CAN ERROR': ElmResponseType.busError,
    '?': ElmResponseType.unknownCommand,
  };

  ElmResponse parse(String raw) {
    final lines = raw
        .replaceAll('>', '')
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.isNotEmpty) {
      final lastLine = lines.last.toUpperCase();
      final ElmResponseType? type = _exactTypes[lastLine];

      if (type != null) {
        return ElmResponse(type: type, raw: raw, lines: lines);
      }
    }

    return ElmResponse(type: ElmResponseType.malformed, raw: raw, lines: lines);
  }
}
