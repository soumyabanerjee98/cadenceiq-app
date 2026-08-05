import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography rules:
/// - Unbounded: display, headlines, titles (via [Theme.of(context).textTheme])
/// - Inter: dense body copy, form labels, buttons, chips
abstract final class AppTextStyles {
  static TextStyle denseBody(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color ?? AppColors.textSecondary,
    );
  }

  static TextStyle formLabel(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.textSecondary,
    );
  }

  static TextStyle button(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }
}
