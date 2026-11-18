import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/decoders/supported_pids_decoder.dart';

import '../elm/elm_client.dart';

enum ObdSessionState { disconnected, initializing, ready, error }

/// Initializes and manages an OBD-II communication session.
///
/// Configures the ELM327 adapter and discovers ECU capabilities
/// required before live polling can begin.
/// returns supportedEcuPids to registry.
class ObdSession {
  final ElmClient _elmClient;

  ObdSessionState _state = ObdSessionState.disconnected;
  Object? _lastError;
  int? _protocolNumber;

  ObdSession({required ElmClient elmClient}) : _elmClient = elmClient;

  ObdSessionState get state => _state;
  Object? get lastError => _lastError;
  int? get protocolNumber => _protocolNumber;

  Future<Set<int>> initialize() async {
    _state = ObdSessionState.initializing;
    _lastError = null;
    _protocolNumber = null;

    try {
      await _executeAndExpect('ATZ', ElmResponseType.adapterInfo);
      await _executeAndExpect('ATE0', ElmResponseType.ok);
      await _executeAndExpect('ATL0', ElmResponseType.ok);
      await _executeAndExpect('ATSP0', ElmResponseType.ok);
      final supportedPidsResponse = await _executeAndExpect(
        '0100',
        ElmResponseType.data,
      );
      final protocolNum = await _elmClient.execute("ATDPN");
      if (protocolNum.lines.length == 1) {
        _protocolNumber = _parseProtocolNumber(protocolNum.lines.single);
      }

      final supportedPids = decodeSupportedPids(supportedPidsResponse);

      _state = ObdSessionState.ready;
      return supportedPids;
    } catch (e) {
      _lastError = e;
      _state = ObdSessionState.error;
      rethrow;
    }
  }

  Future<ElmResponse> _executeAndExpect(
    String command,
    ElmResponseType expectedType,
  ) async {
    final response = await _elmClient.execute(command);

    if (response.type != expectedType) {
      throw StateError('$command expected $expectedType, got ${response.type}');
    }

    return response;
  }

  int? _parseProtocolNumber(String protocolLine) {
    var value = protocolLine.trim().toUpperCase();

    if (value.length == 2 && value.startsWith('A')) {
      value = value.substring(1);
    }

    if (!RegExp(r'^[1-9A-C]$').hasMatch(value)) {
      return null;
    }

    return int.parse(value, radix: 16);
  }
}
