import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/providers/bluetooth_provider.dart';

/// Карточка статуса сканирования.
/// Слушает только isScanning и количество найденных устройств.
class BluetoothScanStatusCard extends StatelessWidget {
  const BluetoothScanStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isScanning = context.select<BluetoothProvider, bool>(
      (provider) => provider.isScanning,
    );

    final devicesCount = context.select<BluetoothProvider, int>(
      (provider) => provider.discoveredDevices.length,
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF131315),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (!isScanning) {
              Future.delayed(const Duration(milliseconds: 150), () {
                if (!context.mounted) return;
                context.read<BluetoothProvider>().startScan();
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4FF47).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isScanning
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFFC4FF47),
                          ),
                        )
                      : const Icon(Icons.bluetooth, color: Color(0xFFC4FF47)),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isScanning ? "Scanning..." : "Scanning complete",
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isScanning
                            ? "Searching for your adapter..."
                            : "Found $devicesCount devices",
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isScanning)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4FF47).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Color(0xFFC4FF47),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
