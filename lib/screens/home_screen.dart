import 'package:redrive/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/obd/pid/pid_key.dart';
import 'package:redrive/obd/polling/polling_controller.dart';
import 'package:redrive/obd/source/obd_source_state.dart';
import 'package:redrive/widget/home_screen/car_display.dart';
import 'package:redrive/widget/home_screen/connections_buttons.dart';
import 'package:redrive/widget/home_screen/header_bar.dart';
import 'package:redrive/widget/home_screen/telemetry_card.dart';

import '../providers/obd_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String _connectionMessage(BuildContext context, ObdSourceState state) {
  final l = AppLocalizations.of(context);
  switch (state) {
    case ObdSourceState.disconnected:
      return l.preparing;
    case ObdSourceState.connecting:
      return l.connectingEcu;
    case ObdSourceState.initializing:
      return l.initializing;
    case ObdSourceState.polling:
      return l.connected;
    case ObdSourceState.recovering:
      return l.recovering;
    case ObdSourceState.error:
      return l.connectionError;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ObdProvider>().setWatchlist(WatchSource.visibleScreen, {
        PidKey.vehicleSpeed,
        PidKey.engineRpm,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final obdProvider = context.watch<ObdProvider>();

    final obdData = obdProvider.data;
    final bool isReal = obdProvider.mode == ObdMode.real;
    final bool isDemo = obdProvider.mode == ObdMode.demo;
    final bool isDeviceConnected = obdProvider.isDeviceConnected;
    final bool isReconnecting = obdProvider.isReconnecting;
    final bool isObdConnected = obdProvider.isEcuConnected;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderBar(),
                const SizedBox(height: 15),

                const CarDisplay(),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 190,
                        child: TelemetryCard(
                          title: l.speed,
                          value: obdData.speed.toDouble(),
                          fractionDigits: 0,
                          valueSuffix: "",
                          unit: "km/h",
                          iconPath: 'assets/images/svg/dashboard/speed.svg',
                          progress: (obdData.speed / 240).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 190,
                        child: TelemetryCard(
                          title: l.rpm,
                          value: obdData.rpm / 1000,
                          fractionDigits: 1,
                          valueSuffix: "K",
                          unit: "rpm",
                          iconPath: 'assets/images/svg/dashboard/engine.svg',
                          progress: (obdData.rpm / 8000).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ConnectionButtons(
                  isConnected: isObdConnected,
                  isDemoMode: isDemo,

                  onConnect: () async {
                    if (!isDeviceConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.connectAdapterFirst)),
                      );
                      return;
                    }
                    if (isReal) {
                      await obdProvider.stopRealMode();
                      return;
                    }
                    if (isReconnecting) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.reconnectWait)));
                      return;
                    }

                    await _connectWithDialog(obdProvider);

                    if (obdProvider.mode != ObdMode.real && context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.ecuFailed)));
                    }
                  },

                  onViewDemo: () async {
                    if (isReal) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.disconnectEcuFirst)),
                      );
                      return;
                    }

                    if (isDemo) {
                      await obdProvider.stopDemoMode();
                    } else {
                      await obdProvider.startDemoMode();
                    }
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connectWithDialog(ObdProvider obdProvider) async {
    var isCancelled = false;

    _showConnectingDialog(
      onCancel: () async {
        isCancelled = true;
        await obdProvider.stopRealMode();
      },
    );

    await obdProvider.startRealMode();

    if (!mounted || isCancelled) return;

    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showConnectingDialog({required Future<void> Function() onCancel}) {
    final l = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Selector<ObdProvider, ObdSourceState>(
                  selector: (_, obd) => obd.state,
                  builder: (context, state, _) => Text(
                    _connectionMessage(context, state),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await onCancel();

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(l.cancel),
              ),
            ],
          ),
        );
      },
    );
  }
}
