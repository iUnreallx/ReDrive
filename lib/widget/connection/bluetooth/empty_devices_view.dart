import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/providers/bluetooth_provider.dart';

class EmptyDevicesView extends StatelessWidget {
  const EmptyDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () =>
                  context.read<BluetoothProvider>().startScan(),
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
}
