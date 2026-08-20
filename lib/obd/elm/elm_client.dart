import 'package:redrive/obd/elm/elm_command.dart';
import 'package:redrive/obd/elm/elm_command_queue.dart';

import '../../services/obd_connection.dart';
import 'elm_response.dart';
import 'elm_response_parser.dart';
import 'dart:async';

class ElmClient {
  final ObdConnection _connection;
  late final StreamSubscription<String> _subscription;
  String _receiveBuffer = "";
  final ElmResponseParser _parser = const ElmResponseParser();
  final ElmCommandQueue _queue = ElmCommandQueue();

  ElmClient({required ObdConnection connection}) : _connection = connection {
    _subscription = _connection.incoming.listen(
      _handleIncomingData,
      onError: (error) {
        print('Stream error: $error');
      },
    );
  }

  void _handleIncomingData(String chunk) {
    final current = _queue.currentElmCommand;
    if (current == null) return;

    _receiveBuffer += chunk;

    if (!_receiveBuffer.contains(">")) return;

    ElmResponse response = _parser.parse(_receiveBuffer);

    current.completer.complete(response);

    _receiveBuffer = "";

    final nextCommand = _queue.completeCurrent();
    if (nextCommand != null) {
      _startCommand(nextCommand);
    }
  }

  Future<ElmResponse> execute(String command) {
    final elmCommand = _queue.incomingQueue(
      command,
      const Duration(seconds: 2),
    );

    if (elmCommand == _queue.currentElmCommand) {
      _startCommand(elmCommand);
    }

    return elmCommand.completer.future;
  }

  void _startCommand(ElmCommand command) {
    _receiveBuffer = "";
    _connection.send("${command.command}\r");
  }

  Future<void> dispose() async {
    await _subscription.cancel();
  }
}
