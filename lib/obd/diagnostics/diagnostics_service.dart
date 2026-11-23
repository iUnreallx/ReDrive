import 'package:redrive/obd/diagnostics/dtc_decoder.dart';
import 'package:redrive/obd/elm/elm_client.dart';
import 'package:redrive/obd/elm/elm_response.dart';

class DiagnosticsService {
  final ElmClient _elmClient;
  final int? _protocolNumber;

  DiagnosticsService({
    required ElmClient elmClient,
    required int? protocolNumber,
  }) : _elmClient = elmClient,
       _protocolNumber = protocolNumber;

  Future<List<String>> readStoredCodes() async {
    final protocol = _protocolNumber;
    if (protocol == null || protocol < 6 || protocol > 9) {
      throw UnsupportedError('Unsupported OBD protocol: $protocol');
    }

    final response = await _elmClient.execute('03');

    if (response.type == ElmResponseType.multiFrame) {
      return decodeCanDtcResponse(response.assembledBytes!);
    }

    if (response.type != ElmResponseType.data || response.lines.length != 1) {
      throw const FormatException('Expected one OBD data line');
    }

    final line = response.lines.single;
    final parts = line.split(RegExp(r'\s+'));
    final bytes = parts.map((part) => int.parse(part, radix: 16)).toList();

    return decodeCanDtcResponse(bytes);
  }
}
