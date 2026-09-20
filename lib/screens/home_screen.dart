import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  // @override
  // void initState() {
  //   super.initState();

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final provider = context.read<ObdProviderOld>();
  //     _errorSubscription = provider.errorEvents.listen((errorMessage) {
  //       if (!mounted) return;

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(errorMessage),
  //           backgroundColor: Theme.of(context).colorScheme.error,
  //           duration: const Duration(seconds: 3),
  //         ),
  //       );
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final obdProvider = context.watch<ObdProvider>();

    final obdData = obdProvider.data;
    final bool isReal = obdProvider.mode == ObdMode.real;
    final bool isDemo = obdProvider.mode == ObdMode.demo;
    final bool isConnected = obdProvider.isDeviceConnected;

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
                  isConnected: isReal,
                  isDemoMode: isDemo,

                  onConnect: () async {
                    if (!isConnected) {
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

                    await obdProvider.startRealMode();

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
}
