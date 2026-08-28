import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/decoders/engine_rpm_decoder.dart';

void main() {
  group('decodeEngineRpm', () {
    test('decodes RPM from valid response', () {
      const response = ElmResponse(
        type: ElmResponseType.data,
        raw: '41 0C 1A F8\r>',
        lines: ['41 0C 1A F8'],
      );

      final rpm = decodeEngineRpm(response);

      expect(rpm, 1726.0);
    });

    test('throws FormatException for wrong PID header', () {
      const response = ElmResponse(
        type: ElmResponseType.data,
        raw: '41 0D 1A F8\r>',
        lines: ['41 0D 1A F8'],
      );

      expect(() => decodeEngineRpm(response), throwsA(isA<FormatException>()));
    });

    test('throws FormatException when response has no data', () {
      const response = ElmResponse(
        type: ElmResponseType.noData,
        raw: 'NO DATA\r>',
        lines: ['NO DATA'],
      );

      expect(() => decodeEngineRpm(response), throwsA(isA<FormatException>()));
    });
  });
}
