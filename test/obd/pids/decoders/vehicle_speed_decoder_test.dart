import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/decoders/vehicle_speed_decoder.dart';

void main() {
  group('decodeVehicleSpeed', () {
    test('decodes vehicle speed from valid response', () {
      const response = ElmResponse(
        type: ElmResponseType.data,
        raw: '41 0D 2A\r>',
        lines: ['41 0D 2A'],
      );

      final speed = decodeVehicleSpeed(response);

      expect(speed, 42);
    });

    test('throws FormatException for wrong PID header', () {
      const response = ElmResponse(
        type: ElmResponseType.data,
        raw: '41 0C 2A\r>',
        lines: ['41 0C 2A'],
      );

      expect(
        () => decodeVehicleSpeed(response),
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
        () => decodeVehicleSpeed(response),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
