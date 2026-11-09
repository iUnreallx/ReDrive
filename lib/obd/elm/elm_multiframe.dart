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
