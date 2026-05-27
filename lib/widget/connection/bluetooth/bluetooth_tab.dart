import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/providers/bluetooth_provider.dart';
import 'package:redrive/widget/connection/bluetooth/device_tile.dart';
import 'package:redrive/widget/connection/bluetooth/scanner_status_card.dart';

class BluetoothTab extends StatefulWidget {
  const BluetoothTab({super.key});

  @override
  State<BluetoothTab> createState() => _BluetoothTabState();
}

class _BluetoothTabState extends State<BluetoothTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<BluetoothProvider>();

      if (!provider.isScanning && !provider.isConnected) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          context.read<BluetoothProvider>().startScan();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        BluetoothScanStatusCard(),
        SizedBox(height: 20),
        Expanded(child: BluetoothDevicePanel()),
      ],
    );
  }
}


/// Основная панель со списком Bluetooth-устройств.
class BluetoothDevicePanel extends StatelessWidget {
  const BluetoothDevicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131315),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          BluetoothModeSwitcher(),
          Expanded(child: BluetoothDeviceList()),
        ],
      ),
    );
  }
}

/// Переключатель Classic / BLE.
/// Пока статичный, поэтому вообще не слушает provider.
class BluetoothModeSwitcher extends StatelessWidget {
  const BluetoothModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFC4FF47),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Classic",
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: const Text(
              "BLE",
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


