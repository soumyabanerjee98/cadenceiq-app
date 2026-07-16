import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AppDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String description,
    required String actionText,
    Future<void> Function()? onAction,
    String cancelText = "Cancel",
    bool barrierDismissible = false,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        bool loading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Text(description),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: cancelText,
                        onPressed: loading
                            ? null
                            : () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: actionText,
                        danger: isDanger,
                        isLoading: loading,
                        onPressed: () async {
                          if (onAction == null) {
                            Navigator.pop(context, true);
                            return;
                          }

                          setState(() => loading = true);

                          try {
                            await onAction();

                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
                          } catch (_) {
                            if (context.mounted) {
                              setState(() => loading = false);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
