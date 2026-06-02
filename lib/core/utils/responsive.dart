import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

abstract final class Responsive {
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 900;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return ScreenSize.desktop;
    if (width >= tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) => of(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) => of(context) == ScreenSize.tablet;

  static double horizontalPadding(BuildContext context) {
    return switch (of(context)) {
      ScreenSize.mobile => 16,
      ScreenSize.tablet => 24,
      ScreenSize.desktop => 32,
    };
  }

  static int gridColumns(BuildContext context) {
    return switch (of(context)) {
      ScreenSize.mobile => 1,
      ScreenSize.tablet => 2,
      ScreenSize.desktop => 3,
    };
  }

  static double maxContentWidth(BuildContext context) {
    return switch (of(context)) {
      ScreenSize.mobile => double.infinity,
      ScreenSize.tablet => 720,
      ScreenSize.desktop => 960,
    };
  }

  static Widget centeredContent({
    required BuildContext context,
    required Widget child,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth(context)),
        child: child,
      ),
    );
  }
}
