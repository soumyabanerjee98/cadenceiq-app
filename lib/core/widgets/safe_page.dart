import 'package:flutter/material.dart';

/// Wraps screen content with [SafeArea] insets (status bar, notch, home indicator).
class SafePage extends StatelessWidget {
  const SafePage({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}
