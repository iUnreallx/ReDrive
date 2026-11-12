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

  test('parses ELM adapter voltage', () {
    const parser = ElmResponseParser();

    final response = parser.parse('ATRV\r12.6V\r>');

    expect(response.type, ElmResponseType.adapterVoltage);
    expect(response.lines, ['ATRV', '12.6V']);
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

  test('parses multi-frame response', () {
    const parser = ElmResponseParser();

    final response = parser.parse(
      '014\r'
      '0: 49 02 01 31 44 34\r'
      '1: 47 50 30 30 52 35 35\r'
      '2: 42 31 32 33 34 35 36\r'
      '\r>',
    );

    expect(response.type, ElmResponseType.multiFrame);
    expect(response.assembledBytes, hasLength(20));
    expect(response.assembledBytes!.take(3), [0x49, 0x02, 0x01]);
  });

  test('parses multi-frame response after SEARCHING', () {
    const parser = ElmResponseParser();

    final response = parser.parse(
      'SEARCHING...\r'
      '006\r'
      '0: 01 02 03 04 05 06\r'
      '\r>',
    );

    expect(response.type, ElmResponseType.multiFrame);
    expect(response.assembledBytes, [1, 2, 3, 4, 5, 6]);
    expect(response.wasSearching, isTrue);
  });

  test('returns malformed for multi-frame response with a missing part', () {
    const parser = ElmResponseParser();

    final response = parser.parse(
      '014\r'
      '0: 49 02 01 31 44 34\r'
      '2: 42 31 32 33 34 35 36\r'
      '\r>',
    );

    expect(response.type, ElmResponseType.malformed);
    expect(response.assembledBytes, isNull);
  });

  test('keeps single-frame data response without assembled bytes', () {
    const parser = ElmResponseParser();

    final response = parser.parse('41 0D 2A\r>');

    expect(response.type, ElmResponseType.data);
    expect(response.assembledBytes, isNull);
  });
}
