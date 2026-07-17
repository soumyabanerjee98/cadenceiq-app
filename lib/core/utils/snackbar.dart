import 'package:flutter/material.dart';

enum SnackbarStatus { general, success, error }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarStatus status = SnackbarStatus.general,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    Color? bgColor() {
      switch (status) {
        case SnackbarStatus.success:
          return Colors.green;
        case SnackbarStatus.error:
          return Colors.red;
        default:
          return null;
      }
    }

    IconData icon() {
      switch (status) {
        case SnackbarStatus.success:
          return Icons.check_circle_outline;
        case SnackbarStatus.error:
          return Icons.cancel_outlined;
        default:
          return Icons.info_outline;
      }
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          backgroundColor: bgColor(),
          content: Row(
            children: [
              Icon(icon(), color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
