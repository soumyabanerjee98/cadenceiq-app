import 'package:flutter/material.dart';

class AppFAB extends StatelessWidget {
  const AppFAB.extended({
    super.key,
    this.isLoading = false,
    this.onPressed,
    this.icon,
    required this.label,
  });

  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: isLoading
            ? const SizedBox(
                key: ValueKey('loader'),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, key: const ValueKey('icon')),
      ),
      label: Text(isLoading ? "Loading..." : label),
    );
  }
}
