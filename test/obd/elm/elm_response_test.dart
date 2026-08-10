import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/elm/elm_response_parser.dart';

void main() {
  test('stores successful OBD response', () {
    const response = ElmResponse(
      type: ElmResponseType.data,
      raw: 'SEARCHING...\r41 00 BE 3E B8 13\r>',
      lines: ['41 00 BE 3E B8 13'],
      wasSearching: true,
    );

    expect(response.type, ElmResponseType.data);
    expect(response.raw, contains('SEARCHING'));
    expect(response.lines, ['41 00 BE 3E B8 13']);
    expect(response.wasSearching, isTrue);
  });

  test('parses OBD data response', () {
    const parser = ElmResponseParser();

    final response = parser.parse('41 0D 2A\r>');

    expect(response.type, ElmResponseType.data);
    expect(response.lines, ['41 0D 2A']);
    expect(response.wasSearching, isFalse);
  });

  test('parses OK response', () {
    const parser = ElmResponseParser();

    final response = parser.parse('OK\r>');

    expect(response.type, ElmResponseType.ok);
    expect(response.raw, 'OK\r>');
    expect(response.lines, ['OK']);
  });

  test('parses NO DATA response', () {
    const parser = ElmResponseParser();

    final response = parser.parse('NO DATA\r>');

    expect(response.type, ElmResponseType.noData);
    expect(response.lines, ['NO DATA']);
  });

  test('parses exact ELM responses', () {
    const parser = ElmResponseParser();

    const Map<String, ElmResponseType> cases = {
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

    for (final entries in cases.entries) {
      final response = parser.parse(entries.key);

      expect(response.type, entries.value);
    }
  });

  test('parses ELM adapter error codes', () {
    const parser = ElmResponseParser();

    const errorCodes = ['ERR94\r>', 'ERR56\r>', 'ERR0F\r>'];

    for (final errorCode in errorCodes) {
      final response = parser.parse(errorCode);

      expect(response.type, ElmResponseType.adapterError);
    }
  });

  test('parses ELM adapter info', () {
    const parser = ElmResponseParser();

    final response = parser.parse('ATZ\rELM327 v1.5\r>');

    expect(response.type, ElmResponseType.adapterInfo);
    expect(response.lines, ['ATZ', 'ELM327 v1.5']);
  });

  test('parses OBD data response after searching', () {
    const parser = ElmResponseParser();

    final response = parser.parse('SEARCHING...\r41 0D 2A\r>');

    expect(response.type, ElmResponseType.data);
    expect(response.lines, ['41 0D 2A']);
    expect(response.wasSearching, isTrue);
  });

  test('returns malformed for unknown response', () {
    const parser = ElmResponseParser();

    final response = parser.parse('SOMETHING STRANGE\r>');

    expect(response.type, ElmResponseType.malformed);
    expect(response.lines, ['SOMETHING STRANGE']);
  });

  test('returns malformed for empty response', () {
    const parser = ElmResponseParser();

    final response = parser.parse('\r>');

    expect(response.type, ElmResponseType.malformed);
    expect(response.lines, isEmpty);
  });
}
