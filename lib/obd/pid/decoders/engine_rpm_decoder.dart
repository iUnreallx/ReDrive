import '../../elm/elm_response.dart';

double decodeEngineRpm(ElmResponse response) {
  if (response.type != ElmResponseType.data || response.lines.isEmpty) {
    throw const FormatException('RPM response does not contain OBD data');
  }

  final bytes = response.lines.first.toUpperCase().split(RegExp(r'\s+'));

  if (bytes.length < 4) {
    throw FormatException(
      'RPM response expected at least 4 bytes, got ${bytes.length}',
    );
  }

  if (bytes[0] != '41' || bytes[1] != '0C') {
    throw FormatException(
      'RPM response expected header 41 0C, got ${bytes[0]} ${bytes[1]}',
    );
  }

  final a = int.parse(bytes[2], radix: 16);
  final b = int.parse(bytes[3], radix: 16);

  return (a * 256 + b) / 4;
}
