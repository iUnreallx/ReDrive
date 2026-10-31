import 'l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/services/bluetooth/connection/bluetooth_obd_connection.dart';
import 'package:redrive/services/connection/obd_connection_switcher.dart';
import 'package:redrive/services/wifi/connection/wifi_obd_connection.dart';

import 'providers/obd_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'core/app_themes.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => WifiObdConnection()),

        ChangeNotifierProvider(
          create: (context) {
            final obdProvider = ObdProvider();

            ObdConnectionSwitcher(
              provider: obdProvider,
              connections: [
                BluetoothObdConnection(context.read<BluetoothProvider>()),
                context.read<WifiObdConnection>(),
              ],
            );

            return obdProvider;
          },
        ),
      ],
      child: const RedriveApp(),
    ),
  );
}

class RedriveApp extends StatelessWidget {
  const RedriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redrive OBD2',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppThemes.darkTheme,
      home: const RootScreen(),
    );
  }
}
