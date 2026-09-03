import 'package:redrive/obd/elm/elm_response.dart';
import 'package:redrive/obd/pid/decoders/supported_pids_decoder.dart';

import '../elm/elm_client.dart';

enum ObdSessionState { disconnected, initializing, ready, error }

class ObdSession {
  final ElmClient _elmClient;

  ObdSessionState _state = ObdSessionState.disconnected;
  Object? _lastError;

  ObdSession({required ElmClient elmClient}) : _elmClient = elmClient;

  ObdSessionState get state => _state;
  Object? get lastError => _lastError;

  Future<Set<int>> initialize() async {
    _state = ObdSessionState.initializing;
    _lastError = null;

    try {
      await _executeAndExpect('ATZ', ElmResponseType.adapterInfo);
      await _executeAndExpect('ATE0', ElmResponseType.ok);
      await _executeAndExpect('ATL0', ElmResponseType.ok);
      await _executeAndExpect('ATSP0', ElmResponseType.ok);
      final supportedPidsResponse = await _executeAndExpect(
        '0100',
        ElmResponseType.data,
      );

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
}
