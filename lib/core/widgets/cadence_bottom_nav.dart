import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'safe_page.dart';

class CadenceBottomNav extends StatelessWidget {
  const CadenceBottomNav({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      indicatorColor: AppColors.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      onDestinationSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.dashboard, color: Colors.white),
          // label: 'Dashboard',
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_bike_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.directions_bike, color: Colors.white),
          // label: 'Activities',
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.flag_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.flag, color: Colors.white),
          // label: 'Goals',
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.summarize_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.summarize, color: Colors.white),
          // label: 'Summaries',
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.settings, color: Colors.white),
          // label: 'Settings',
          label: '',
        ),
      ],
    );
  }
}

class CadenceScaffold extends StatelessWidget {
  const CadenceScaffold({
    super.key,
    required this.navigationShell,
    required this.child,
  });

  final StatefulNavigationShell navigationShell;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafePage(child: child),
      bottomNavigationBar: CadenceBottomNav(navigationShell: navigationShell),
    );
  }
}
