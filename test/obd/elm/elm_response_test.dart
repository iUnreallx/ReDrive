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
      'OK\r>': ElmResponseType.ok,
      'NO DATA\r>': ElmResponseType.noData,
      'STOPPED\r>': ElmResponseType.stopped,
      'UNABLE TO CONNECT\r>': ElmResponseType.unableToConnect,
      'BUS INIT: ERROR\r>': ElmResponseType.busError,
      'CAN ERROR\r>': ElmResponseType.busError,
      '?\r>': ElmResponseType.unknownCommand,
    };

    for (final values in cases.entries) {
      final response = parser.parse(values.key);

      expect(response.type, values.value);
    }
  });
}
