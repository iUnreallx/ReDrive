import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/decoders/supported_pids_decoder.dart';

void main() {
  group('decodeSupportedPids', () {
    test('decodes supported PIDs from bitmap', () {
      final response = ElmResponse(
        raw: '41 00 08 18 00 00',
        type: ElmResponseType.data,
        lines: ['41 00 08 18 00 00'],
      );

      final result = decodeSupportedPids(response);

      expect(result, {5, 12, 13});
    });

    test('decodes PID 20 from last bit', () {
      final response = ElmResponse(
        raw: '41 00 00 00 00 01',
        type: ElmResponseType.data,
        lines: ['41 00 00 00 00 01'],
      );

      final result = decodeSupportedPids(response);

      expect(result, {32});
    });

    test('returns empty set when no PIDs are supported', () {
      final response = ElmResponse(
        raw: '41 00 00 00 00 00',
        type: ElmResponseType.data,
        lines: ['41 00 00 00 00 00'],
      );

      final result = decodeSupportedPids(response);

      expect(result, isEmpty);
    });

    test('throws when response contains too few bytes', () {
      final response = ElmResponse(
        raw: '41 00 08',
        type: ElmResponseType.data,
        lines: ['41 00 08'],
      );

      expect(
        () => decodeSupportedPids(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when response is not for PID 00', () {
      final response = ElmResponse(
        raw: '41 0C 08 18 00 00',
        type: ElmResponseType.data,
        lines: ['41 0C 08 18 00 00'],
      );

      expect(
        () => decodeSupportedPids(response),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
