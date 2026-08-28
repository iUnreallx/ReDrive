import '../../elm/elm_response.dart';

int decodeCoolantTemperature(ElmResponse response) {
  if (response.type != ElmResponseType.data || response.lines.isEmpty) {
    throw const FormatException(
      'Coolant response does not contain OBD data',
    );
  }

  final bytes = response.lines.first.toUpperCase().split(RegExp(r'\s+'));

  if (bytes.length < 3) {
    throw FormatException(
      'Coolant response expected at least 3 bytes, got ${bytes.length}',
    );
  }

  if (bytes[0] != '41' || bytes[1] != '05') {
    throw FormatException(
      'Coolant response expected header 41 05, '
      'got ${bytes[0]} ${bytes[1]}',
    );
  }

  final a = int.parse(bytes[2], radix: 16);

  return a - 40;
}
