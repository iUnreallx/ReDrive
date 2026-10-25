import 'dart:async';
import 'dart:io';

/// A local TCP server that answers like a Wi-Fi ELM327 adapter.
///
/// Commands end with `\r`, every reply ends with the `>` prompt.
/// Echo is on after power up and after ATZ, like on a real adapter.
class FakeElm327Server {
  final ServerSocket _server;
  final List<Socket> clients = [];
  final List<String> received = [];

  int connections = 0;

  /// The next time this command arrives, the client is dropped instead of
  /// getting an answer.
  String? dropOnCommand;

  bool _echo = true;
  final Map<Socket, String> _buffers = {};

  FakeElm327Server._(this._server) {
    _server.listen(_handleClient);
  }

  static Future<FakeElm327Server> start() async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    return FakeElm327Server._(server);
  }

  String get host => _server.address.address;
  int get port => _server.port;

  void _handleClient(Socket client) {
    connections++;
    clients.add(client);
    _buffers[client] = '';

    client.listen(
      (data) {
        _buffers[client] = _buffers[client]! + String.fromCharCodes(data);

        while (_buffers[client]!.contains('\r')) {
          final buffer = _buffers[client]!;
          final end = buffer.indexOf('\r');
          final command = buffer.substring(0, end);
          _buffers[client] = buffer.substring(end + 1);

          received.add(command);

          if (command == dropOnCommand) {
            dropOnCommand = null;
            client.destroy();
            return;
          }

          _reply(client, command);
        }
      },
      onError: (_) {},
      onDone: () => clients.remove(client),
    );
  }

  void _reply(Socket client, String command) {
    final normalized = command.replaceAll(' ', '').toUpperCase();
    final echo = _echo ? '$command\r' : '';

    final String answer;
    switch (normalized) {
      case 'ATZ':
        _echo = true;
        answer = '\r\rELM327 v1.5';
      case 'ATE0':
        _echo = false;
        answer = 'OK';
      case 'ATL0':
      case 'ATSP0':
        answer = 'OK';
      case '0100':
        answer = 'SEARCHING...\r41 00 BE 3F A8 13';
      case '010C':
        answer = '41 0C 1A F8';
      case '010D':
        answer = '41 0D 2A';
      default:
        answer = '?';
    }

    client.add('$echo$answer\r\r>'.codeUnits);
  }

  /// Closes all client sockets, as an adapter does when it drops a client.
  Future<void> dropClients() async {
    for (final client in List.of(clients)) {
      client.destroy();
    }
    clients.clear();
  }

  Future<void> close() async {
    await dropClients();
    await _server.close();
  }
}
