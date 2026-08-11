import 'elm_response.dart';

class ElmResponseParser {
  const ElmResponseParser();

  static const Map<String, ElmResponseType> _exactTypes = {
    'OK': ElmResponseType.ok,
    'NO DATA': ElmResponseType.noData,
    'STOPPED': ElmResponseType.stopped,
    'UNABLE TO CONNECT': ElmResponseType.unableToConnect,

    'BUS INIT: ERROR': ElmResponseType.busError,
    'BUS ERROR': ElmResponseType.busError,
    'BUS BUSY': ElmResponseType.busError,
    'CAN ERROR': ElmResponseType.busError,

    'BUFFER FULL': ElmResponseType.adapterError,
    'DATA ERROR': ElmResponseType.adapterError,
    '<DATA ERROR': ElmResponseType.adapterError,
    'RX ERROR': ElmResponseType.adapterError,
    'FB ERROR': ElmResponseType.adapterError,
    'LV RESET': ElmResponseType.adapterError,

    '?': ElmResponseType.unknownCommand,
  };

  static final RegExp _adapterErrorCodePattern = RegExp(r'^ERR[0-9A-F]{2}$');

  static bool _isObdDataLine(String line) {
    final bytes = line.split(RegExp(r'\s+'));

    if (bytes.length < 3) {
      return false;
    }

    return bytes.every(
      (byte) => byte.length == 2 && int.tryParse(byte, radix: 16) != null,
    );
  }

  static bool _isSearchingLine(String line) {
    return line.toUpperCase().startsWith('SEARCHING');
  }

  static bool _isAdapterInfoLine(String line) {
    return line.toUpperCase().startsWith("ELM327");
  }

  ElmResponse parse(String raw) {
    final lines = raw
        .replaceAll('>', '')
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final wasSearching = lines.any(_isSearchingLine);

    final responseLines = lines
        .where((line) => !_isSearchingLine(line))
        .toList(growable: false);

    if (responseLines.isNotEmpty) {
      final lastLine = responseLines.last.toUpperCase();
      final ElmResponseType? type = _exactTypes[lastLine];

      if (type != null) {
        return ElmResponse(
          type: type,
          raw: raw,
          lines: responseLines,
          wasSearching: wasSearching,
        );
      }

      if (_adapterErrorCodePattern.hasMatch(lastLine)) {
        return ElmResponse(
          type: ElmResponseType.adapterError,
          raw: raw,
          lines: responseLines,
          wasSearching: wasSearching,
        );
      }

      if (_isAdapterInfoLine(responseLines.last)) {
        return ElmResponse(
          type: ElmResponseType.adapterInfo,
          raw: raw,
          lines: responseLines,
          wasSearching: wasSearching,
        );
      }

      if (responseLines.every(_isObdDataLine)) {
        return ElmResponse(
          type: ElmResponseType.data,
          raw: raw,
          lines: responseLines,
          wasSearching: wasSearching,
        );
      }
    }

    return ElmResponse(
      type: ElmResponseType.malformed,
      raw: raw,
      lines: responseLines,
      wasSearching: wasSearching,
    );
  }
}
