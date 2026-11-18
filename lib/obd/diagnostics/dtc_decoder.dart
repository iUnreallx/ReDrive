List<String> decodeCanDtcResponse(List<int> bytes) {
  if (bytes.length < 2 || bytes[0] != 0x43) {
    throw const FormatException('Invalid Mode 03 response');
  }

  final codeCount = bytes[1];

  if (codeCount == 0) {
    return [];
  }

  final requiredLength = 2 + codeCount * 2;
  if (bytes.length < requiredLength) {
    throw const FormatException('Incomplete Mode 03 response');
  }

  final codes = <String>[];
  for (int codeIndex = 0; codeIndex < codeCount; codeIndex++) {
    final int parts = 2;
    int byteA = bytes[parts * (codeIndex + 1)];
    int byteB = bytes[parts * (codeIndex + 1) + 1];

    codes.add(decodeDtcPair(byteA, byteB));
  }

  return codes;
}

String decodeDtcPair(int byteA, int byteB) {
  final indexLetter = byteA >> 6;

  final Map<int, String> pidLetter = {0: "P", 1: "C", 2: "B", 3: "U"};

  final String? chosseLeter = pidLetter[indexLetter];

  if (chosseLeter != null) {
    final firstDigit = (byteA >> 4) & 0x03;
    final secondDigitValue = byteA & ((1 << 4) - 1);
    final secondDigit = secondDigitValue.toRadixString(16).toUpperCase();
    final lastTwoDigits = byteB.toRadixString(16).padLeft(2, '0').toUpperCase();

    return '$chosseLeter$firstDigit$secondDigit$lastTwoDigits';
  } else {
    return "";
  }
}
