import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/diagnostics/dtc_decoder.dart';

void main() {
  group('decodeCanDtcResponse', () {
    test('returns an empty list when no codes are stored', () {
      final codes = decodeCanDtcResponse([0x43, 0x00]);

      expect(codes, isEmpty);
    });

    test('decodes two codes in response order', () {
      final codes = decodeCanDtcResponse([0x43, 0x02, 0x01, 0x33, 0x5A, 0x07]);

      expect(codes, ['P0133', 'C1A07']);
    });

    test('throws FormatException when a code is truncated', () {
      expect(
        () => decodeCanDtcResponse([0x43, 0x01, 0x01]),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
