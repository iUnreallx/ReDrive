import 'package:flutter/material.dart';
import 'package:redrive/l10n/app_localizations.dart';

enum ConnectionTab { bluetooth, wifi, usb }

class CustomTabBar extends StatelessWidget {
  final ConnectionTab selectedTab;
  final ValueChanged<ConnectionTab> onTabSelected;
  const CustomTabBar({super.key, required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(26)),
      child: Stack(children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 100), curve: Curves.easeInOut,
          alignment: Alignment(selectedTab == ConnectionTab.bluetooth ? -1.0 : (selectedTab == ConnectionTab.wifi ? 0.0 : 1.0), 0),
          child: FractionallySizedBox(widthFactor: 1 / 3, child: Container(decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(50)))),
        ),
        Row(children: [
          _TabItem(tab: ConnectionTab.bluetooth, icon: Icons.bluetooth, label: l.bluetooth, currentTab: selectedTab, onTap: onTabSelected),
          _TabItem(tab: ConnectionTab.wifi, icon: Icons.wifi, label: l.wifi, currentTab: selectedTab, onTap: onTabSelected),
          _TabItem(tab: ConnectionTab.usb, icon: Icons.usb, label: l.usb, currentTab: selectedTab, onTap: onTabSelected),
        ]),
      ]),
    );
  }
}

class _TabItem extends StatelessWidget {
  final ConnectionTab tab;
  final ConnectionTab currentTab;
  final IconData icon;
  final String label;
  final ValueChanged<ConnectionTab> onTap;
  const _TabItem({required this.tab, required this.currentTab, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = currentTab == tab;
    final contentColor = isActive ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.4);
    return Expanded(child: GestureDetector(
      onTap: () => onTap(tab), behavior: HitTestBehavior.opaque,
      child: Container(alignment: Alignment.center, color: Colors.transparent, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: contentColor, size: 20), const SizedBox(width: 8),
        Text(label, style: TextStyle(color: contentColor, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600, fontSize: 15)),
      ])),
    ));
  }
}
