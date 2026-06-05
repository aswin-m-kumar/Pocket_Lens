import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../core/theme/app_colors.dart';
import '../features/add_transaction/add_transaction_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _index = 0;

  final List<Widget> _screens = const <Widget>[
    DashboardScreen(),
    AddTransactionScreen(),
    HistoryScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        height: 64 + bottomPadding,
        decoration: const BoxDecoration(
          color: kBgCard,
          border: Border(
            top: BorderSide(color: kBorderSubtle, width: 1),
          ),
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              0,
              PhosphorIconsFill.squaresFour,
              PhosphorIconsRegular.squaresFour,
            ),
            _buildNavItem(
              1,
              PhosphorIconsFill.plus,
              PhosphorIconsRegular.plus,
            ),
            _buildNavItem(
              2,
              PhosphorIconsFill.clockCounterClockwise,
              PhosphorIconsRegular.clockCounterClockwise,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final bool isActive = _index == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? kAccent : kTextMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? kAccent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

