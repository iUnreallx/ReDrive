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

  group('assembleMultiFrame', () {
    test('assembles a VIN response', () {
      final bytes = assembleMultiFrame([
        '014',
        '0: 49 02 01 31 44 34',
        '1: 47 50 30 30 52 35 35',
        '2: 42 31 32 33 34 35 36',
      ]);

      expect(bytes, [
        0x49,
        0x02,
        0x01,
        0x31,
        0x44,
        0x34,
        0x47,
        0x50,
        0x30,
        0x30,
        0x52,
        0x35,
        0x35,
        0x42,
        0x31,
        0x32,
        0x33,
        0x34,
        0x35,
        0x36,
      ]);
    });

    test('trims extra bytes to the declared length', () {
      final bytes = assembleMultiFrame([
        '006',
        '0: 01 02 03 04 05 06',
        '1: 07 AA',
      ]);

      expect(bytes, [1, 2, 3, 4, 5, 6]);
    });

    test('accepts numbering that wraps from F to 0', () {
      final lines = <String>['011'];
      for (var i = 0; i < 17; i++) {
        lines.add('${(i % 16).toRadixString(16).toUpperCase()}: 01');
      }

      expect(assembleMultiFrame(lines), hasLength(17));
    });

    test('returns null when a part is missing', () {
      expect(assembleMultiFrame(['014', '0: 01 02', '2: 03 04']), isNull);
    });

    test('returns null when parts from two ECUs are mixed', () {
      expect(assembleMultiFrame(['014', '0: 01 02', '0: 03 04']), isNull);
    });

    test('returns null when there are fewer bytes than declared', () {
      expect(assembleMultiFrame(['014', '0: 01 02']), isNull);
    });

    test('returns null for an invalid length line', () {
      expect(assembleMultiFrame(['0G4', '0: 01 02']), isNull);
    });

    test('returns null when there are no parts', () {
      expect(assembleMultiFrame(['014']), isNull);
    });
  });
}
