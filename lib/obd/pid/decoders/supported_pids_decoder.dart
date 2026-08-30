import '../../elm/elm_response.dart';

Set<int> decodeSupportedPids(ElmResponse response) {
  if (response.type != ElmResponseType.data || response.lines.isEmpty) {
    throw const FormatException(
      'Supported PID response does not contain OBD data',
    );
  }

  final bytes = response.lines.first.trim().split(RegExp(r'\s+'));

  if (bytes.length < 6) {
    throw const FormatException(
      'Supported PID response contains too few bytes',
    );
  }

  if (bytes[0] != '41' || bytes[1] != '00') {
    throw FormatException(
      'Invalid supported PID response: ${response.lines.first}',
    );
  }

  final bitmap = [
    int.parse(bytes[2], radix: 16),
    int.parse(bytes[3], radix: 16),
    int.parse(bytes[4], radix: 16),
    int.parse(bytes[5], radix: 16),
  ];

  final supported = <int>{};

  for (int position = 0; position < 32; position++) {
    final byteIndex = position ~/ 8;
    final positionInByte = position % 8;
    final bitIndex = 7 - positionInByte;

    final isSupported = ((bitmap[byteIndex] >> bitIndex) & 1) == 1;

    if (isSupported) {
      final pid = position + 1;
      supported.add(pid);
    }
  }

  return supported;
}
