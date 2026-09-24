import 'package:flutter/material.dart';

class ConnectionButtons extends StatelessWidget {
  final VoidCallback onConnect;
  final VoidCallback onViewDemo;
  final bool isConnected;
  final bool isDemoMode;

  const ConnectionButtons({
    super.key,
    required this.onConnect,
    required this.onViewDemo,
    required this.isConnected,
    required this.isDemoMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _AnimatedConnectButton(
          isConnected: isConnected,
          onPressed: onConnect,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _AnimatedDemoButton(
          isDemoMode: isDemoMode,
          onPressed: onViewDemo,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _AnimatedConnectButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _AnimatedConnectButton({
    required this.isConnected,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: isConnected ? 72.0 : 56.0,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: isConnected
                ? _buildConnectedState(key: const ValueKey('connected'))
                : _buildDisconnectedState(key: const ValueKey('disconnected')),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedState({required Key key}) {
    return Row(
      key: key,
      children: [
        const SizedBox(width: 16),
        const Icon(Icons.track_changes_rounded, color: Colors.black, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "已连接",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                "车辆已连接",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDisconnectedState({required Key key}) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.tune_rounded, color: Colors.black, size: 24),
        SizedBox(width: 10),
        Text(
          "连接",
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _AnimatedDemoButton extends StatelessWidget {
  final bool isDemoMode;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _AnimatedDemoButton({
    required this.isDemoMode,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainer,
          side: BorderSide(color: colorScheme.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildStateRow(
            key: ValueKey(isDemoMode),
            icon: isDemoMode ? Icons.stop_rounded : Icons.play_arrow_rounded,
            text: isDemoMode ? "断开演示" : "查看演示",
          ),
        ),
      ),
    );
  }

  Widget _buildStateRow({
    required Key key,
    required IconData icon,
    required String text,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          text,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
