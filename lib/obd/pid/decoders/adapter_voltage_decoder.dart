import '../../elm/elm_response.dart';

final RegExp _adapterVoltagePattern = RegExp(
  r'^(\d+(?:\.\d+)?)\s*V$',
  caseSensitive: false,
);

double decodeAdapterVoltage(ElmResponse response) {
  if (response.type != ElmResponseType.adapterVoltage ||
      response.lines.isEmpty) {
    throw const FormatException(
      'Adapter voltage response does not contain voltage data',
    );
  }

  final match = _adapterVoltagePattern.firstMatch(response.lines.last.trim());

  if (match == null) {
    throw FormatException(
      'Invalid adapter voltage response: ${response.lines.last}',
    );
  }

  return double.parse(match.group(1)!);
}
