import 'package:flutter/material.dart';
import 'package:redrive/l10n/app_localizations.dart';
import 'package:redrive/widget/bottom_bar/bottom_bar_config.dart';
import 'package:redrive/widget/bottom_bar/bottom_bar_item.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key, required this.currentIndex, required this.onItemSelected});
  static const double _height = 100.0;
  final int currentIndex;
  final void Function(int index) onItemSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      BottomBarItemData(iconPath: 'assets/images/svg/bottomBar/home.svg', label: l.home),
      BottomBarItemData(iconPath: 'assets/images/svg/bottomBar/dashboard.svg', label: l.dashboard),
      BottomBarItemData(iconPath: 'assets/images/svg/bottomBar/connection.svg', label: l.connection),
      BottomBarItemData(iconPath: 'assets/images/svg/bottomBar/garage.svg', label: l.garage),
      BottomBarItemData(iconPath: 'assets/images/svg/bottomBar/dtc.svg', label: l.dtc),
    ];
    return SizedBox(
      height: _height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) => BottomBarItem(
          data: items[index], isActive: currentIndex == index,
          onTap: () => onItemSelected(index),
        )),
      ),
    );
  }
}
