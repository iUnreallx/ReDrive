import '../../elm/elm_response.dart';

int decodeVehicleSpeed(ElmResponse response) {
  if (response.type != ElmResponseType.data || response.lines.isEmpty) {
    throw const FormatException('Speed response does not contain OBD data');
  }

  final bytes = response.lines.first.toUpperCase().split(RegExp(r'\s+'));

  if (bytes.length < 3) {
    throw FormatException(
      'Speed response expected at least 3 bytes, got ${bytes.length}',
    );
  }

  if (bytes[0] != '41' || bytes[1] != '0D') {
    throw FormatException(
      'Speed response expected header 41 0D, got ${bytes[0]} ${bytes[1]}',
    );
  }

  return int.parse(bytes[2], radix: 16);
}
