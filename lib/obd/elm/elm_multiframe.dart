({int index, List<int> bytes})? parseFrameLine(String line) {
  final parts = line.split(':');
  if (parts.length != 2) return null;

  final indexText = parts[0].trim();
  if (indexText.length != 1) return null;

  final index = int.tryParse(indexText, radix: 16);
  if (index == null) return null;

  final byteTexts = parts[1].trim().split(RegExp(r'\s+'));
  final bytes = <int>[];

  for (final byteText in byteTexts) {
    if (byteText.length != 2) return null;

    final value = int.tryParse(byteText, radix: 16);
    if (value == null) return null;

    bytes.add(value);
  }

  return (index: index, bytes: bytes);
}

List<int>? assembleMultiFrame(List<String> lines) {
  if (lines.length < 2) return null;
  if (lines[0].length != 3) return null;
  final bytesLength = int.tryParse(lines[0], radix: 16);
  if (bytesLength == null) return null;

  int expected = 0;
  final bytes = <int>[];

  for (String line in lines.skip(1)) {
    final response = parseFrameLine(line);
    if (response == null) return null;
    if (response.index != expected) return null;
    for (int byte in response.bytes) {
      bytes.add(byte);
    }

    expected = (expected + 1) % 16;
  }

  if (bytes.length < bytesLength) return null;
  return bytes.sublist(0, bytesLength);
}
