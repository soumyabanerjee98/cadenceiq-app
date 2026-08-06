import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFFFC4C02);
  static const Color primaryDark = Color(0xFFE04400);
  static const Color primaryLight = Color(0xFFFF6B35);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F8F8);
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);

  static const Color border = Color(0xFFE8E8E8);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color ai = Color(0xFF6366F1);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  static const Color zone1 = Color(0xFF95A5A6);
  static const Color zone2 = Color(0xFF3498DB);
  static const Color zone3 = Color(0xFF2ECC71);
  static const Color zone4 = Color(0xFFF39C12);
  static const Color zone5 = Color(0xFFE74C3C);

  // Dark theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF2A2A2A);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color surfaceVariantOf(BuildContext context) =>
      isDark(context) ? darkSurfaceVariant : surfaceVariant;

  static Color cardOf(BuildContext context) =>
      isDark(context) ? darkSurface : background;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color textTertiaryOf(BuildContext context) =>
      isDark(context) ? darkTextTertiary : textTertiary;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color dividerOf(BuildContext context) =>
      isDark(context) ? darkDivider : divider;
}
