import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/decoders/coolant_temperature_decoder.dart';

void main() {
  group('decodeCoolantTemperature', () {
    test('decodes coolant temperature from valid response', () {
      const response = ElmResponse(
        type: ElmResponseType.data,
        raw: '41 05 7B\r>',
        lines: ['41 05 7B'],
      );

      final temperature = decodeCoolantTemperature(response);

      expect(temperature, 83);
    });

    test('throws FormatException for wrong PID header', () {
      const response = ElmResponse(
        type: ElmResponseType.data,
        raw: '41 0D 7B\r>',
        lines: ['41 0D 7B'],
      );

      expect(
        () => decodeCoolantTemperature(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when response has no data', () {
      const response = ElmResponse(
        type: ElmResponseType.noData,
        raw: 'NO DATA\r>',
        lines: ['NO DATA'],
      );

      expect(
        () => decodeCoolantTemperature(response),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
