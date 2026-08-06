import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum SnackbarStatus { general, success, error }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarStatus status = SnackbarStatus.general,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final isDark = AppColors.isDark(context);

    Color bgColor() {
      switch (status) {
        case SnackbarStatus.success:
          return isDark
              ? AppColors.success.withValues(alpha: 0.9)
              : AppColors.success;
        case SnackbarStatus.error:
          return isDark
              ? AppColors.error.withValues(alpha: 0.9)
              : AppColors.error;
        case SnackbarStatus.general:
          return isDark
              ? AppColors.darkSurfaceVariant
              : const Color(0xFF323232);
      }
    }

    Color contentColor() {
      switch (status) {
        case SnackbarStatus.success:
        case SnackbarStatus.error:
          return Colors.white;
        case SnackbarStatus.general:
          return isDark ? AppColors.darkTextPrimary : Colors.white;
      }
    }

    IconData icon() {
      switch (status) {
        case SnackbarStatus.success:
          return Icons.check_circle_outline;
        case SnackbarStatus.error:
          return Icons.cancel_outlined;
        case SnackbarStatus.general:
          return Icons.info_outline;
      }
    }

    final foreground = contentColor();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          backgroundColor: bgColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isDark
                ? BorderSide(color: AppColors.darkBorder)
                : BorderSide.none,
          ),
          content: Row(
            children: [
              Icon(icon(), color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
