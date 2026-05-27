import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:redrive/models/bluetooth_enums.dart';
import 'package:redrive/models/obd_device.dart';
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
          _handleScan(context);
        });
      }
    });
  }

  Future<void> _handleScan(BuildContext context) async {
    final result = await context.read<BluetoothProvider>().startScan();
    if (!mounted) return;

    if (result == BluetoothScanResult.permanentlyDenied) {
      _showPermissionDialog(context);
    }
    // started aur notStarted ke liye kuch nahi karna
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131315),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Bluetooth access required',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bluetooth permission was permanently denied. '
          'Please enable it from app settings.',
          style: TextStyle(color: Colors.white54),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings(); // permission_handler se aata hai
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC4FF47),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text(
              'Open settings',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BluetoothScanStatusCard(onRefresh: () => _handleScan(context)),
        SizedBox(height: 20),
        Expanded(child: BluetoothDevicePanel(onScan: () => _handleScan(context))),
      ],
    );
  }
}

/// Карточка статуса сканирования.
/// Слушает только isScanning и количество найденных устройств.
class BluetoothScanStatusCard extends StatelessWidget {
  final VoidCallback onRefresh;
  const BluetoothScanStatusCard({super.key, required this.onRefresh});

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
          onTap: isScanning
              ? null
              : () => Future.delayed(
                  const Duration(milliseconds: 150),
                  onRefresh, // _handleScan pass hoga
                ),
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

/// Основная панель со списком Bluetooth-устройств.
class BluetoothDevicePanel extends StatelessWidget {
   final VoidCallback onScan;
  const BluetoothDevicePanel({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131315),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          BluetoothModeSwitcher(),
          Expanded(child: BluetoothDeviceList(onScan: onScan)),
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

/// Список устройств.
/// Перестраивается только когда изменились:
/// - isScanning;
/// - количество устройств;
/// - имя или адрес устройства.
class BluetoothDeviceList extends StatelessWidget {
  final VoidCallback onScan;
  const BluetoothDeviceList({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Selector<BluetoothProvider, _BluetoothDeviceListState>(
      selector: (_, provider) {
        return _BluetoothDeviceListState(
          isScanning: provider.isScanning,
          devices: List<ObdDevice>.of(provider.discoveredDevices),
        );
      },
      shouldRebuild: (previous, next) {
        if (previous.isScanning != next.isScanning) return true;
        if (previous.devices.length != next.devices.length) return true;

        for (int i = 0; i < previous.devices.length; i++) {
          final oldDevice = previous.devices[i];
          final newDevice = next.devices[i];

          if (oldDevice.address != newDevice.address) return true;
          if (oldDevice.name != newDevice.name) return true;
        }

        return false;
      },
      builder: (context, state, child) {
        if (state.devices.isEmpty && !state.isScanning) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 80,
                  color: const Color(0xFFC4FF47).withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                const Text(
                  "No devices found",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Make sure the scanner is plugged in and the\nignition is turned on",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4FF47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Start Scanning",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.devices.length,
          separatorBuilder: (context, index) {
            return Divider(color: Colors.white.withAlpha(10), height: 1);
          },
          itemBuilder: (context, index) {
            final device = state.devices[index];

            return BluetoothDeviceTile(
              key: ValueKey(device.address),
              device: device,
            );
          },
        );
      },
    );
  }
}

class BluetoothDeviceTile extends StatelessWidget {
  final ObdDevice device;

