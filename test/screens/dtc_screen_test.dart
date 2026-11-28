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

    expect(find.text('Check your car'), findsOneWidget);
    await tester.tap(find.byTooltip('Read codes'));
    await tester.pumpAndSettle();
    expect(find.text('P0133'), findsOneWidget);
    expect(find.text('1 code'), findsOneWidget);

    await tester.tap(_clearButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, ['read']);

    await tester.tap(_clearButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear codes'));
    await tester.pumpAndSettle();
    expect(calls, ['read', 'clear', 'read']);
    expect(find.text('No stored codes'), findsOneWidget);
    expect(find.textContaining('Checked at'), findsOneWidget);
    expect(find.text('P0133'), findsNothing);
    expect(_clearButton, findsNothing);
  });

  testWidgets('shows connect prompt, then progress while reading', (
    tester,
  ) async {
    final obd = _TestObd();
    var opened = 0;
    await _openScreen(tester, obd, onOpenConnection: () => opened++);
    expect(find.text('Connect the adapter'), findsOneWidget);
    expect(find.text('No stored codes'), findsNothing);
    expect(find.byTooltip('Read codes'), findsNothing);
    await tester.tap(find.text('Connect'));
    expect(opened, 1);
    expect(obd.calls, isEmpty);

    obd.setConnected(true);
    await tester.pumpAndSettle();
    final pending = Completer<List<String>>();
    obd.pending = pending;
    await tester.tap(find.byTooltip('Read codes'));
    await tester.pump();
    expect(find.text('Keep the ignition on'), findsOneWidget);
    pending.complete(['P0300']);
    await tester.pumpAndSettle();
    expect(find.text('P0300'), findsOneWidget);
  });

  for (final reconnect in [false, true]) {
    testWidgets(
      'dismisses clear confirmation on ${reconnect ? 'reconnect' : 'disconnect'}',
      (tester) async {
        final obd = _TestObd()..setConnected(true);
        await _openScreen(tester, obd);
        await tester.tap(find.byTooltip('Read codes'));
        await tester.pumpAndSettle();
        await tester.tap(_clearButton);
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
      expect(_clearButton, findsNothing);
      expect(find.byTooltip('Read codes'), findsNothing);
      expect(obd.calls, isEmpty);

      obd.setConnected(true);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Read codes'));
      await tester.pumpAndSettle();
      expect(_clearButton, findsOneWidget);
      obd.setConnected(false);
      await tester.pumpAndSettle();
      expect(find.text('P0133'), findsNothing);
      expect(_clearButton, findsNothing);

      obd.setConnected(true);
      await tester.pumpAndSettle();
      final pending = Completer<List<String>>();
      obd.pending = pending;
      await tester.tap(find.byTooltip('Read codes'));
      obd.setConnected(false);
      obd.setConnected(true);
      pending.complete(['P0300']);
      await tester.pumpAndSettle();
      expect(find.text('P0300'), findsNothing);
      expect(_clearButton, findsNothing);
      expect(find.byTooltip('Read codes'), findsOneWidget);
    },
  );
}

final _clearButton = find.widgetWithText(TextButton, 'Clear codes');

Future<void> _openScreen(
  WidgetTester tester,
  _TestObd obd, {
  VoidCallback? onOpenConnection,
}) => tester.pumpWidget(
  ChangeNotifierProvider(
    create: (_) => DtcProvider(obd),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: DtcScreen(onOpenConnection: onOpenConnection)),
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
