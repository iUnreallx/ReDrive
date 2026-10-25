import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:redrive/l10n/app_localizations.dart';
import 'package:redrive/services/wifi/connection/wifi_obd_connection.dart';
import 'package:redrive/widget/connection/wifi/wifi_tab.dart';

class _PendingWifiConnection extends WifiObdConnection {
  final List<({String? host, int? port})> connectCalls = [];
  final List<Completer<bool>> pending = [];

  bool _isConnecting = false;
  @override
  bool get isConnecting => _isConnecting;

  @override
  Future<bool> connect({String? host, int? port}) {
    connectCalls.add((host: host, port: port));
    _isConnecting = true;
    notifyListeners();

    final completer = Completer<bool>();
    pending.add(completer);
    return completer.future;
  }

  @override
  Future<void> disconnect() async {
    _isConnecting = false;
    notifyListeners();
  }
}

void main() {
  late _PendingWifiConnection connection;

  setUp(() {
    connection = _PendingWifiConnection();
  });

  tearDown(() {
    connection.dispose();
  });

  Future<void> pumpTab(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<WifiObdConnection>.value(
        value: connection,
        child: const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WifiTab()),
        ),
      ),
    );
    await tester.pump();
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets('rejects an empty or out-of-range port without connecting', (
    tester,
  ) async {
    await pumpTab(tester);

    for (final port in ['70000', '0', '']) {
      await tester.enterText(field('Port'), port);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Enter a valid IP address and port'), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(WifiTab)),
      ).removeCurrentSnackBar();
      await tester.pump();
    }

    await tester.enterText(field('IP address'), ' 192.168.0.10 ');
    await tester.enterText(field('Port'), '35000');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(connection.connectCalls, [(host: '192.168.0.10', port: 35000)]);
  });

  testWidgets('does not report a cancelled attempt as failed', (tester) async {
    await pumpTab(tester);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    await tester.enterText(field('IP address'), '192.168.0.11');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    connection.pending.first.complete(false);
    await tester.pump();
    expect(find.textContaining('No response from'), findsNothing);

    connection.pending.last.complete(false);
    await tester.pump();
    expect(find.text('No response from 192.168.0.11:35000'), findsOneWidget);
  });
}
