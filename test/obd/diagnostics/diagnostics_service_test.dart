import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/diagnostics/diagnostics_service.dart';
import 'package:redrive/obd/elm/elm_client.dart';

import '../fakes/fake_obd_connection.dart';

void main() {
  group('DiagnosticsService.readStoredCodes', () {
    late FakeObdConnection connection;
    late ElmClient client;

    DiagnosticsService serviceFor(int protocolNumber) =>
        DiagnosticsService(elmClient: client, protocolNumber: protocolNumber);

    setUp(() {
      connection = FakeObdConnection();
      client = ElmClient(connection: connection);
    });

    tearDown(() async {
      await client.dispose();
      await connection.dispose();
    });

    test('sends Mode 03 and returns the decoded code', () async {
      final result = serviceFor(6).readStoredCodes();
      expect(connection.sentCommands, ['03\r']);

      connection.emit('43 01 01 33\r>');
      expect(await result, ['P0133']);
    });

    test('returns an empty list when the ECU reports zero codes', () async {
      final result = serviceFor(7).readStoredCodes();

      connection.emit('43 00\r>');
      expect(await result, isEmpty);
    });

    test('reports a read failure when the adapter returns NO DATA', () async {
      final result = serviceFor(8).readStoredCodes();

      connection.emit('NO DATA\r>');
      await expectLater(result, throwsFormatException);
    });

    test('reads stored codes from a multi-frame response', () async {
      final result = serviceFor(9).readStoredCodes();

      connection.emit('008\r0: 43 03 01 33 03 00\r1: 04 20\r>');

      expect(await result, ['P0133', 'P0300', 'P0420']);
    });

    test('rejects protocol 5 before sending Mode 03', () async {
      await expectLater(
        serviceFor(5).readStoredCodes(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(connection.sentCommands, isEmpty);
    });
  });
}
