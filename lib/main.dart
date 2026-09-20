import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/services/bluetooth/connection/bluetooth_obd_connection.dart';

import 'providers/obd_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'core/app_themes.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),

        ChangeNotifierProvider(
          create: (context) {
            final obdProvider = ObdProvider();

            obdProvider.attachConnection(
              BluetoothObdConnection(context.read<BluetoothProvider>()),
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
      theme: AppThemes.darkTheme,
      home: const RootScreen(),
    );
  }
}
