import 'package:cadenceiq_app/core/constants/app_strings.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:flutter/material.dart';

class PlanInsightCard extends StatelessWidget {
  const PlanInsightCard({super.key, required this.insight});

  final PlanInsight insight;

  Color _riskColor(BuildContext context) {
    switch (insight.risk.toLowerCase()) {
      case 'low':
        return Colors.green;

      case 'medium':
        return Colors.orange;

      case 'high':
        return Theme.of(context).colorScheme.error;

      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _riskIcon() {
    switch (insight.risk.toLowerCase()) {
      case 'low':
        return Icons.check_circle_rounded;

      case 'medium':
        return Icons.warning_amber_rounded;

      case 'high':
        return Icons.error_rounded;

      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _riskColor(context);
    final padding = Responsive.horizontalPadding(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.ai.withOpacity(.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.ai,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    AppStrings.aiInsight,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(_riskIcon(), size: 18, color: riskColor),

                      const SizedBox(width: 6),

                      Text(
                        "${insight.risk[0].toUpperCase()}${insight.risk.substring(1)} Risk",
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              insight.summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),

            if (insight.recommendations.isNotEmpty) ...[
              const SizedBox(height: 24),

              Text(
                "Recommendations",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...insight.recommendations.map(
                (recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.auto_awesome_outlined,
                          size: 18,
                          color: AppColors.ai,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          recommendation,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
