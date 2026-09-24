import 'package:flutter/material.dart';
import 'package:redrive/widget/connection/bluetooth/bluetooth_tab.dart';
import 'package:redrive/widget/connection/bluetooth/bluetooth_waiting_widget.dart';
import 'package:redrive/widget/connection/connection_screen/custom_tab_bar.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  ConnectionTab _selectedTab = ConnectionTab.bluetooth;
  bool _isBluetoothActivated = false;

  void _activateBluetooth() {
    setState(() {
      _isBluetoothActivated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("连接",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.8,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 14),

              CustomTabBar(
                selectedTab: _selectedTab,
                onTabSelected: (tab) {
                  setState(() => _selectedTab = tab);
                },
              ),

              const SizedBox(height: 14),

              Expanded(child: _buildTabContent(colorScheme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colorScheme) {
    return IndexedStack(
      index: _selectedTab.index,
      children: [
        _isBluetoothActivated
            ? const BluetoothTab()
            : BluetoothWaitingWidget(onActivate: _activateBluetooth),

        const Center(
          child: Text(
            "Wi‑Fi 连接功能正在开发中",
            style: TextStyle(color: Colors.white54),
          ),
        ),

        const Center(
          child: Text(
            "USB 连接功能正在开发中",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }
}
