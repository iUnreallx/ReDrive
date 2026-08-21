import 'package:redrive/obd/elm/elm_command.dart';
import 'package:redrive/obd/elm/elm_command_queue.dart';

import '../../services/obd_connection.dart';
import 'elm_response.dart';
import 'elm_response_parser.dart';
import 'dart:async';

class ElmClient {
  final ObdConnection _connection;
  late final StreamSubscription<String> _subscription;
  Timer? _commandWatchdogTimer;

  String _receiveBuffer = "";
  bool _isDesynchronized = false;

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

    _commandWatchdogTimer?.cancel();
    current.completer.complete(response);

    _receiveBuffer = "";

    final nextCommand = _queue.completeCurrent();
    if (nextCommand != null) {
      _startCommand(nextCommand);
    }
  }

  Future<ElmResponse> execute(
    String command, {
    Duration timeout = const Duration(seconds: 2),
  }) {
    if (_isDesynchronized) {
      throw StateError('ELM session requires recovery');
    }

    final elmCommand = _queue.incomingQueue(command, timeout);

    if (elmCommand == _queue.currentElmCommand) {
      _startCommand(elmCommand);
    }

    return elmCommand.completer.future;
  }

  void _startCommand(ElmCommand command) {
    _receiveBuffer = "";

    _commandWatchdogTimer?.cancel();

    _commandWatchdogTimer = Timer(command.timeout, () {
      if (command != _queue.currentElmCommand) return;

      final error = TimeoutException(
        'ELM command ${command.command} timed out',
        command.timeout,
      );

      _failExchange(error);
    });

    _connection.send("${command.command}\r");
  }

  void _failExchange(Object error) {
    _commandWatchdogTimer?.cancel();
    _isDesynchronized = true;
    _receiveBuffer = "";
    final abortedCommands = _queue.abortAll();

    for (final abortedCommand in abortedCommands) {
      if (!abortedCommand.completer.isCompleted) {
        abortedCommand.completer.completeError(error);
      }
    }
  }

  Future<void> dispose() async {
    _commandWatchdogTimer?.cancel();
    await _subscription.cancel();
  }
}
