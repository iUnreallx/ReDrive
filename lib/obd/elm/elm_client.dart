import '../../services/obd_connection.dart';
import 'elm_response.dart';
import 'elm_response_parser.dart';
import 'dart:async';

class ElmClient {
  final ObdConnection _connection;
  late final StreamSubscription<String> _subscription;
  String _receiveBuffer = "";
  Completer<ElmResponse>? _completer;
  final ElmResponseParser _parser = const ElmResponseParser();

  ElmClient({required ObdConnection connection}) : _connection = connection {
    _subscription = _connection.incoming.listen(
      _handleIncomingData,
      onError: (error) {
        print('Stream error: $error');
      },
    );
  }

  void _handleIncomingData(String chunk) {
    if (_completer == null) return;

    _receiveBuffer += chunk;

    if (!_receiveBuffer.contains(">")) return;

    ElmResponse response = _parser.parse(_receiveBuffer);
    Completer<ElmResponse>? completer = _completer;
    _completer = null;

    completer?.complete(response);

    _receiveBuffer = "";
  }

  Future<ElmResponse> execute(String command) async {
    if (_completer != null) {
      throw StateError('Предыдущая команда ещё выполняется');
    }

    _receiveBuffer = "";

    final completer = Completer<ElmResponse>();
    _completer = completer;

    await _connection.send("$command\r");

    return completer.future;
  }

  Future<void> dispose() async {
    await _subscription.cancel();
  }
}
