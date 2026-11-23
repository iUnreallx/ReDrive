import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:redrive/l10n/app_localizations.dart';
import 'package:redrive/providers/dtc_provider.dart';
import 'package:redrive/screens/dtc_screen.dart';

void main() {
  testWidgets('clears only after confirmation and refreshes the codes', (
    tester,
  ) async {
    final calls = <String>[];
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DtcProvider(
          readStoredCodes: () async {
            calls.add('read');
            return calls.contains('clear') ? [] : ['P0133'];
          },
          clearStoredCodes: () async {
            calls.add('clear');
          },
        ),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DtcScreen()),
        ),
      ),
    );

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
}
