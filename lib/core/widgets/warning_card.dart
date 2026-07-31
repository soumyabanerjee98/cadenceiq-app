import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum WarningCardType { danger, warning }

class WarningCard extends StatelessWidget {
  final String message;
  final VoidCallback? action;
  final String? actionText;
  final WarningCardType type;
  final IconData icon;
  const WarningCard({
    super.key,
    required this.message,
    this.action,
    this.actionText,
    this.type = WarningCardType.danger,
    this.icon = Icons.warning_rounded,
  });

  Color get _color {
    switch (type) {
      case WarningCardType.danger:
        return AppColors.error;
      case WarningCardType.warning:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: _color, size: 20),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(color: _color),
                    ),
                  ),
                ],
              ),
            ),

            if (action != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: action,
                child: Text(
                  actionText ?? "Take Action",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
