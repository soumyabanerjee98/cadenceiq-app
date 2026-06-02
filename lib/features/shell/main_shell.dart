import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cadenceiq_app/core/widgets/cadence_bottom_nav.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return CadenceScaffold(
      navigationShell: navigationShell,
      child: navigationShell,
    );
  }
}
