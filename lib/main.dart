// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/services/bluetooth/connection/bluetooth_obd_connection.dart';
import 'providers/obd_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'core/app_themes.dart';
import 'screens/root_screen.dart';
import 'widget/reconnection_banner.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),

        ChangeNotifierProxyProvider<BluetoothProvider, ObdProvider>(
          create: (context) => ObdProvider(
            BluetoothObdConnection(context.read<BluetoothProvider>()),
          ),
          update: (_, blueProvider, currentObdProvider) {
            currentObdProvider!.updateConnection(
              BluetoothObdConnection(blueProvider),
            );

            return currentObdProvider;
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

      /// баннер при отключении адаптера elm'ки появляется, трактуя
      /// попытку переподключения к объекту
      builder: (context, child) {
        return Stack(
          children: [
            child!,

            Consumer2<BluetoothProvider, ObdProvider>(
              builder: (context, blueProvider, obdProvider, _) {
                final isBlueReconnecting =
                    blueProvider.isReconnectingBackground;

                final isObdRecovering =
                    obdProvider.isRealMode &&
                    obdProvider.state == ObdConnectionState.initializing;

                final showBanner = isBlueReconnecting || isObdRecovering;

                String message = "";
                if (isBlueReconnecting) {
                  message = blueProvider.backgroundMessage;
                } else if (isObdRecovering) {
                  message = obdProvider.initMessage;
                }

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: showBanner
                      ? MediaQuery.of(context).padding.top + 10
                      : -100,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showBanner ? 1.0 : 0.0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ReconnectionBanner(message: message),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
