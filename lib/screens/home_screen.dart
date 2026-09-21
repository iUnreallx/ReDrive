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

String _connectionMessage(ObdSourceState state) {
  switch (state) {
    case ObdSourceState.disconnected:
      return 'Подготовка подключения...';
    case ObdSourceState.connecting:
      return 'Подключение к ЭБУ...';
    case ObdSourceState.initializing:
      return 'Инициализация ELM327...';
    case ObdSourceState.polling:
      return 'Подключено';
    case ObdSourceState.recovering:
      return 'Восстановление соединения...';
    case ObdSourceState.error:
      return 'Ошибка подключения';
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
    final obdProvider = context.watch<ObdProvider>();

    final obdData = obdProvider.data;
    final bool isReal = obdProvider.mode == ObdMode.real;
    final bool isDemo = obdProvider.mode == ObdMode.demo;
    final bool isDeviceConnected = obdProvider.isDeviceConnected;
    final bool isObdConnected =
        isReal &&
        (obdProvider.state == ObdSourceState.polling ||
            obdProvider.state == ObdSourceState.recovering ||
            obdProvider.isReconnecting);

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
                HeaderBar(), // шапка ( название + настройки )
                const SizedBox(height: 15),

                const CarDisplay(), // отображение карусели машин
                const SizedBox(height: 10),

                /// отображение телеметрии
                /// ( две карточки связующие с obd модулем )
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 190,
                        child: TelemetryCard(
                          title: "Speed",
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
                          title: "RPM",
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

                /// кнопки для подключения к эбу
                /// либо для подключения демо режима
                ConnectionButtons(
                  isConnected: isObdConnected,
                  isDemoMode: isDemo,

                  onConnect: () async {
                    if (!isDeviceConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Сначала подключитесь к Ble/Wifi/USB"),
                        ),
                      );
                      return;
                    }

                    if (isReal) {
                      await obdProvider.stopRealMode();
                      return;
                    }

                    await _connectWithDialog(obdProvider);

                    if (obdProvider.mode != ObdMode.real && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Не удалось связаться с ЭБУ"),
                        ),
                      );
                    }
                  },

                  onViewDemo: () async {
                    if (isReal) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Сначала отключитесь от ЭБУ"),
                        ),
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
    bool isCancelled = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Consumer<ObdProvider>(
            builder: (context, obd, child) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      _connectionMessage(obd.state),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      isCancelled = true;
                      await obd.stopRealMode();

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Отмена'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    await obdProvider.startRealMode();

    if (!mounted || isCancelled) return;

    Navigator.of(context, rootNavigator: true).pop();
  }
}
