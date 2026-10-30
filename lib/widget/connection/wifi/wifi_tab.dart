import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:redrive/l10n/app_localizations.dart';
import 'package:redrive/services/wifi/connection/wifi_obd_connection.dart';

class WifiTab extends StatefulWidget {
  const WifiTab({super.key});

  @override
  State<WifiTab> createState() => _WifiTabState();
}

class _WifiTabState extends State<WifiTab> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();

    final connection = context.read<WifiObdConnection>();
    _hostController = TextEditingController(text: connection.host);
    _portController = TextEditingController(text: connection.port.toString());
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final connection = context.read<WifiObdConnection>();

    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim());

    if (InternetAddress.tryParse(host) == null ||
        port == null ||
        port < 1 ||
        port > 65535) {
      messenger.showSnackBar(SnackBar(content: Text(l.invalidAddress)));
      return;
    }

    FocusScope.of(context).unfocus();
    final attempt = ++_attempt;

    final success = await connection.connect(host: host, port: port);

    if (!success && attempt == _attempt && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.adapterNotResponding('$host:$port')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _disconnect() {
    _attempt++;
    context.read<WifiObdConnection>().disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final connection = context.watch<WifiObdConnection>();

    final isBusy =
        connection.isConnected ||
        connection.isConnecting ||
        connection.isReconnecting;

    return SingleChildScrollView(
      child: Column(
        children: [
          WifiStatusCard(connection: connection),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF131315),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.wifiDescription,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 20),
                _WifiTextField(
                  controller: _hostController,
                  label: l.ipAddress,
                  enabled: !isBusy,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                _WifiTextField(
                  controller: _portController,
                  label: l.port,
                  enabled: !isBusy,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isBusy ? _disconnect : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4FF47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isBusy
                          ? (connection.isConnected ? l.disconnect : l.cancel)
                          : l.connect,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WifiStatusCard extends StatelessWidget {
  final WifiObdConnection connection;

  const WifiStatusCard({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final target = '${connection.host}:${connection.port}';
    final isWorking = connection.isConnecting || connection.isReconnecting;

    final String title;
    if (connection.isReconnecting) {
      title = l.bannerReconnecting;
    } else if (connection.isConnecting) {
      title = l.connectingTo(target);
    } else if (connection.isConnected) {
      title = l.connectedTo(target);
    } else {
      title = l.notConnected;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131315),
        borderRadius: BorderRadius.circular(20),
      ),
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
            child: isWorking
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFC4FF47),
                    ),
                  )
                : Icon(
                    connection.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: const Color(0xFFC4FF47),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.wifiConnection,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WifiTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _WifiTextField({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xFFC4FF47),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        floatingLabelStyle: const TextStyle(color: Color(0xFFC4FF47)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
