import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:redrive/l10n/app_localizations.dart';
import 'package:redrive/obd/session/obd_session.dart';
import 'package:redrive/providers/dtc_provider.dart';
import 'package:redrive/providers/obd_provider.dart';
import 'package:redrive/screens/dtc_screen.dart';

void main() {
  testWidgets('clears only after confirmation and refreshes the codes', (
    tester,
  ) async {
    final obd = _TestObd()..setConnected(true);
    final calls = obd.calls;
    await _openScreen(tester, obd);

    await tester.tap(find.byTooltip('Read codes'));
    await tester.pumpAndSettle();
    expect(find.text('P0133'), findsOneWidget);

    await tester.tap(find.text('CLEAR CODES'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, ['read']);

    await tester.tap(find.text('CLEAR CODES'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear codes'));
    await tester.pumpAndSettle();
    expect(calls, ['read', 'clear', 'read']);
    expect(find.text('No stored codes'), findsOneWidget);
    expect(find.text('P0133'), findsNothing);
  });

  for (final reconnect in [false, true]) {
    testWidgets(
      'dismisses clear confirmation on ${reconnect ? 'reconnect' : 'disconnect'}',
      (tester) async {
        final obd = _TestObd()..setConnected(true);
        await _openScreen(tester, obd);
        await tester.tap(find.byTooltip('Read codes'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('CLEAR CODES'));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);

        obd.setConnected(false);
        if (reconnect) obd.setConnected(true);
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsNothing);
        expect(find.byType(DtcScreen), findsOneWidget);
        expect(obd.calls, ['read']);
      },
    );
  }

  testWidgets(
    'scan follows the session and expired reads cannot restore codes',
    (tester) async {
      final obd = _TestObd();
      await _openScreen(tester, obd);
      OutlinedButton clearButton() =>
          tester.widget(find.widgetWithText(OutlinedButton, 'CLEAR CODES'));
      expect(clearButton().onPressed, isNull);
      await tester.tap(find.byTooltip('Not connected'));
      expect(obd.calls, isEmpty);

      obd.setConnected(true);
      await tester.pump();
      await tester.tap(find.byTooltip('Read codes'));
      await tester.pumpAndSettle();
      expect(clearButton().onPressed, isNotNull);
      obd.setConnected(false);
      await tester.pump();
      expect(find.text('P0133'), findsNothing);
      expect(clearButton().onPressed, isNull);

      obd.setConnected(true);
      await tester.pump();
      final pending = Completer<List<String>>();
      obd.pending = pending;
      await tester.tap(find.byTooltip('Read codes'));
      obd.setConnected(false);
      obd.setConnected(true);
      pending.complete(['P0300']);
      await tester.pumpAndSettle();
      expect(find.text('P0300'), findsNothing);
      expect(clearButton().onPressed, isNull);
      expect(find.byTooltip('Read codes'), findsOneWidget);
    },
  );
}

Future<void> _openScreen(WidgetTester tester, _TestObd obd) =>
    tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DtcProvider(obd),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DtcScreen()),
        ),
      ),
    );

class _Session extends Fake implements ObdSession {}

class _TestObd extends ObdProvider {
  final calls = <String>[];
  Completer<List<String>>? pending;
  @override
  ObdSession? diagnosticsSession;

  void setConnected(bool connected) {
    diagnosticsSession = connected ? _Session() : null;
    notifyListeners();
  }

  @override
  Future<List<String>> readStoredCodes() async {
    calls.add('read');
    if (pending != null) return pending!.future;
    return calls.contains('clear') ? [] : ['P0133'];
  }

  @override
  Future<void> clearStoredCodes() async {
    calls.add('clear');
  }
}
