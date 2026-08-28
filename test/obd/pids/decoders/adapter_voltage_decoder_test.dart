import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/decoders/adapter_voltage_decoder.dart';

void main() {
  group('decodeAdapterVoltage', () {
    test('decodes voltage from valid adapter response', () {
      const response = ElmResponse(
        type: ElmResponseType.adapterVoltage,
        raw: '12.6V\r>',
        lines: ['12.6V'],
      );

      final voltage = decodeAdapterVoltage(response);

      expect(voltage, 12.6);
    });

    test('throws FormatException for invalid voltage format', () {
      const response = ElmResponse(
        type: ElmResponseType.adapterVoltage,
        raw: 'VOLTAGE\r>',
        lines: ['VOLTAGE'],
      );

      expect(
        () => decodeAdapterVoltage(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when response has no voltage data', () {
      const response = ElmResponse(
        type: ElmResponseType.noData,
        raw: 'NO DATA\r>',
        lines: ['NO DATA'],
      );

      expect(
        () => decodeAdapterVoltage(response),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
