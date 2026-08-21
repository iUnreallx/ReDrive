import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_client.dart';
import 'package:redrive/obd/elm/elm_command_queue.dart';
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

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });

    final firstFuture = client.execute('010D');
    final secondFuture = client.execute('010C');

    expect(fakeConnection.sentCommands, ['010D\r']);

    fakeConnection.emit('41 0D 2A\r>');

    final firstResponse = await firstFuture;

    expect(fakeConnection.sentCommands, ['010D\r', '010C\r']);
    expect(firstResponse.type, ElmResponseType.data);

    fakeConnection.emit('41 0C 1A F8\r>');

    final secondResponse = await secondFuture;

    expect(secondResponse.type, ElmResponseType.data);
  });

  test('commandTimeoutException when response does not arrive', () async {
    final fakeConnection = FakeObdConnection();
    final client = ElmClient(connection: fakeConnection);

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });

    final future = client.execute(
      '010D',
      timeout: const Duration(milliseconds: 20),
    );

    await expectLater(future, throwsA(isA<TimeoutException>()));
  });

  test('watchdog aborts queue and blocks new commands', () async {
    final fakeConnection = FakeObdConnection();
    final client = ElmClient(connection: fakeConnection);

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });

    final firstFuture = client.execute(
      '010D',
      timeout: const Duration(milliseconds: 20),
    );

    final secondFuture = client.execute(
      '010C',
      timeout: const Duration(seconds: 1),
    );

    expect(fakeConnection.sentCommands, ['010D\r']);

    final firstExpectation = expectLater(
      firstFuture,
      throwsA(isA<TimeoutException>()),
    );

    final secondExpectation = expectLater(
      secondFuture,
      throwsA(isA<TimeoutException>()),
    );

    await Future.wait([firstExpectation, secondExpectation]);

    expect(fakeConnection.sentCommands, ['010D\r']);

    expect(() => client.execute('0105'), throwsA(isA<StateError>()));
  });

  test('send error aborts queue and blocks new commands', () async {
    final fakeConnection = FakeObdConnection();
    final client = ElmClient(connection: fakeConnection);
    final sendError = Exception('send failed');

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });

    fakeConnection.sendError = sendError;

    final firstFuture = client.execute('010D');
    final secondFuture = client.execute('010C');

    final firstExpectation = expectLater(firstFuture, throwsA(same(sendError)));
    final secondExpectation = expectLater(
      secondFuture,
      throwsA(same(sendError)),
    );

    await Future.wait([firstExpectation, secondExpectation]);

    expect(fakeConnection.sentCommands, ['010D\r']);
    expect(() => client.execute('0105'), throwsA(isA<StateError>()));
  });

  test('stream error aborts queue and blocks new commands', () async {
    final fakeConnection = FakeObdConnection();
    final client = ElmClient(connection: fakeConnection);
    final streamError = Exception('stream failed');

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });

    final firstFuture = client.execute('010D');
    final secondFuture = client.execute('010C');

    final firstExpectation = expectLater(
      firstFuture,
      throwsA(same(streamError)),
    );
    final secondExpectation = expectLater(
      secondFuture,
      throwsA(same(streamError)),
    );

    fakeConnection.emitError(streamError);

    await Future.wait([firstExpectation, secondExpectation]);

    expect(fakeConnection.sentCommands, ['010D\r']);
    expect(() => client.execute('0105'), throwsA(isA<StateError>()));
  });

  test('closed stream fails current command and blocks new commands', () async {
    final fakeConnection = FakeObdConnection();
    final client = ElmClient(connection: fakeConnection);

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });

    final future = client.execute('010D');
    final expectation = expectLater(
      future,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'ELM incoming stream closed',
        ),
      ),
    );

    await fakeConnection.closeIncoming();
    await expectation;

    expect(() => client.execute('0105'), throwsA(isA<StateError>()));
  });

  test('abortAll returns all commands and clears queue', () {
    final queue = ElmCommandQueue();

    final first = queue.incomingQueue('010D', Duration(microseconds: 20));
    final second = queue.incomingQueue('010C', Duration(microseconds: 20));

    final aborted = queue.abortAll();

    expect(aborted, [first, second]);
    expect(queue.currentElmCommand, isNull);
    expect(queue.waitingCommands, isEmpty);
  });

  test('dispose fails pending commands and blocks new commands', () async {
    final fakeConnection = FakeObdConnection();
    final client = ElmClient(connection: fakeConnection);

    addTearDown(() async {
      await client.dispose();
      await fakeConnection.dispose();
    });

    final firstFuture = client.execute('010D');
    final secondFuture = client.execute('010C');

    final disposedError = isA<StateError>().having(
      (error) => error.message,
      'message',
      'ElmClient is disposed',
    );

    final firstExpectation = expectLater(firstFuture, throwsA(disposedError));
    final secondExpectation = expectLater(secondFuture, throwsA(disposedError));

    await client.dispose();
    await Future.wait([firstExpectation, secondExpectation]);

    expect(fakeConnection.sentCommands, ['010D\r']);
    expect(() => client.execute('0105'), throwsA(disposedError));

    await client.dispose();
  });
}
