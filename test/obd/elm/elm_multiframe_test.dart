import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_multiframe.dart';

void main() {
  group('parseFrameLine', () {
    test('reads part number and bytes', () {
      final frame = parseFrameLine('0: 49 02 01');

      expect(frame!.index, 0);
      expect(frame.bytes, [0x49, 0x02, 0x01]);
    });

    test('reads a hexadecimal part number', () {
      final frame = parseFrameLine('A: 47 50');

      expect(frame!.index, 10);
      expect(frame.bytes, [0x47, 0x50]);
    });

    test('returns null for lines that are not parts', () {
      expect(parseFrameLine('41 0D 3C'), isNull);
      expect(parseFrameLine('014'), isNull);
      expect(parseFrameLine('BUS INIT: OK'), isNull);
      expect(parseFrameLine('0:'), isNull);
    });
  });
}
