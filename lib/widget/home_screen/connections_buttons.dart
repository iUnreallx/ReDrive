import 'package:flutter/material.dart';
import 'package:redrive/l10n/app_localizations.dart';

class ConnectionButtons extends StatelessWidget {
  final VoidCallback onConnect;
  final VoidCallback onViewDemo;
  final bool isConnected;
  final bool isDemoMode;
  const ConnectionButtons({super.key, required this.onConnect, required this.onViewDemo, required this.isConnected, required this.isDemoMode});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Theme.of(context).colorScheme;
    return Column(children: [
      _AnimatedConnectButton(isConnected: isConnected, onPressed: onConnect, colorScheme: c, l: l),
      const SizedBox(height: 12),
      _AnimatedDemoButton(isDemoMode: isDemoMode, onPressed: onViewDemo, colorScheme: c, l: l),
    ]);
  }
}

class _AnimatedConnectButton extends StatelessWidget {
  final bool isConnected; final VoidCallback onPressed; final ColorScheme colorScheme; final AppLocalizations l;
  const _AnimatedConnectButton({required this.isConnected, required this.onPressed, required this.colorScheme, required this.l});
  @override
  Widget build(BuildContext context) => AnimatedContainer(duration: const Duration(milliseconds: 200), width: double.infinity, height: isConnected ? 72 : 56, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(16)), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onPressed, child: AnimatedSwitcher(duration: const Duration(milliseconds: 150), child: isConnected ? _connected() : _disconnected())));
  Widget _connected() => Row(key: const ValueKey('connected'), children: [const SizedBox(width: 16), const Icon(Icons.track_changes_rounded, color: Colors.black, size: 32), const SizedBox(width: 12), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CONNECTED', style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w900, letterSpacing: 1.1)), Text(l.vehicleConnected, style: const TextStyle(color: Colors.black87, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600))])), Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: Icon(Icons.check, color: colorScheme.primary, size: 20)), const SizedBox(width: 16)]);
  Widget _disconnected() => Row(key: const ValueKey('disconnected'), mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.tune_rounded, color: Colors.black, size: 24), const SizedBox(width: 10), Text(l.connect.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w800, letterSpacing: 1.1))]);
}

class _AnimatedDemoButton extends StatelessWidget {
  final bool isDemoMode; final VoidCallback onPressed; final ColorScheme colorScheme; final AppLocalizations l;
  const _AnimatedDemoButton({required this.isDemoMode, required this.onPressed, required this.colorScheme, required this.l});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 56, child: OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(backgroundColor: colorScheme.surfaceContainer, side: BorderSide(color: colorScheme.primary, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(isDemoMode ? Icons.stop_rounded : Icons.play_arrow_rounded, color: colorScheme.primary, size: 24), const SizedBox(width: 10), Text(isDemoMode ? l.disconnectDemo : l.viewDemo, style: TextStyle(color: colorScheme.primary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w800, letterSpacing: 1.1))])));
}
