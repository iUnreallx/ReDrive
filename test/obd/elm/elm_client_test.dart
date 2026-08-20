import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_client.dart';
import 'package:redrive/obd/elm/elm_response.dart';
import '../fakes/fake_obd_connection.dart';

void main() {
  test("joins chunks and parses adapter info response", () async {
    final FakeObdConnection fakeConnection = FakeObdConnection();
    final ElmClient client = ElmClient(connection: fakeConnection);

    Future<ElmResponse> future = client.execute("ATZ");

    fakeConnection.emit("ATZ\rELM");
    fakeConnection.emit("327 v1.5\r>");

    final response = await future;

    expect(response.type, ElmResponseType.adapterInfo);
    expect(fakeConnection.sentCommands, ["ATZ\r"]);

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });
  });

  test('queues commands and executes them in order', () async {
    final fakeConnection = FakeObdConnection();
    final client = ElmClient(connection: fakeConnection);

    final firstFuture = client.execute('010D');
    final secondFuture = client.execute('010C');

    fakeConnection.emit('41 0D 2A\r>');

    await firstFuture;

    fakeConnection.emit('41 0C 1A F8\r>');

    await secondFuture;
  });
}
