import 'package:flutter/material.dart';
import 'package:redrive/widget/bottom_bar/bottom_bar_config.dart';
import 'package:redrive/widget/bottom_bar/bottom_bar_item.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  static const double _height = 100.0;
  final int currentIndex;
  final void Function(int index) onItemSelected;

  static const List<BottomBarItemData> _navItems = [
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/home.svg',
      label: '主页',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/dashboard.svg',
      label: '仪表盘',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/connection.svg',
      label: '连接',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/garage.svg',
      label: '车库',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/dtc.svg',
      label: '故障码',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_navItems.length, (index) {
          return BottomBarItem(
            data: _navItems[index],
            isActive: currentIndex == index,
            onTap: () {
              onItemSelected(index);
            },
          );
        }),
      ),
    );
  }
}
