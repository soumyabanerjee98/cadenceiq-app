import 'package:flutter/material.dart';

import 'package:cadenceiq/models/goal.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});

  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusChip(completed: goal.isCompleted),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${Formatters.shortDate(goal.startDate)} – ${Formatters.shortDate(goal.endDate)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                goal.experienceLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _LoadMetric(label: 'Current', value: goal.currentLoad),
                  const SizedBox(width: 16),
                  _LoadMetric(label: 'Target', value: goal.targetLoad),
                  const SizedBox(width: 16),
                  _LoadMetric(label: 'Adjusted', value: goal.adjustedLoad),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: double.parse(goal.completion.toString()).clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${Formatters.percent(double.parse(goal.completion.toString()))} complete',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.push('/summaries/${goal.id}'),
                    child: Text("View Summary"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.completed});
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (completed) {
      true => ('Complete', AppColors.success),
      false => ('Incomplete', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadMetric extends StatelessWidget {
  const _LoadMetric({required this.label, required this.value});
  final String label;
  final num value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            Formatters.load(value),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
