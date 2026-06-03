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
      indicatorColor: Colors.transparent,
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
          selectedIcon: const Icon(Icons.dashboard, color: AppColors.primary),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_bike_outlined,
              color: AppColors.textTertiary),
          selectedIcon:
              const Icon(Icons.directions_bike, color: AppColors.primary),
          label: 'Activities',
        ),
        NavigationDestination(
          icon: Icon(Icons.flag_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.flag, color: AppColors.primary),
          label: 'Goals',
        ),
        NavigationDestination(
          icon: Icon(Icons.summarize_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.summarize, color: AppColors.primary),
          label: 'Summaries',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined, color: AppColors.textTertiary),
          selectedIcon: const Icon(Icons.settings, color: AppColors.primary),
          label: 'Settings',
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
