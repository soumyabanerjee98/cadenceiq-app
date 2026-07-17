import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/formatters.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/providers/goal_provider.dart';

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    final goal = context.read<GoalProvider>().getById(goalId);

    if (goal == null) {
      return Scaffold(
        appBar: const CadenceAppBar(showBack: true, title: 'Goal'),
        body: const SafePage(child: Center(child: Text('Goal not found'))),
      );
    }

    return Scaffold(
      appBar: CadenceAppBar(showBack: true, title: goal.title),
      body: SafePage(child: GoalDetails(goal: goal)),
    );
  }
}

class GoalDetails extends StatelessWidget {
  final Goal goal;
  const GoalDetails({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        _InfoCard(goal: goal),
        const SizedBox(height: 20),
        Text(
          'Training Plan',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _Timeline(goal: goal),
        const SizedBox(height: 20),
        Text(
          'Planned Sessions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...goal.plans.map((s) => _SessionTile(session: s)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.goal});
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.customGoalRequest != null) ...[
              Text(
                goal.customGoalRequest!,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today,
                  label:
                      '${Formatters.shortDate(goal.startDate)} – ${Formatters.shortDate(goal.endDate)}',
                ),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.school, label: goal.experienceLabel),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: double.parse(goal.completion.toString()).clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${Formatters.percent(double.parse(goal.completion.toString()))} complete · ${goal.daysRemaining} days remaining',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Metric(
                  label: 'Current',
                  value: Formatters.load(goal.currentLoad),
                ),
                _Metric(
                  label: 'Target',
                  value: Formatters.load(goal.targetLoad),
                ),
                _Metric(
                  label: 'Adjusted',
                  value: Formatters.load(goal.adjustedLoad),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.goal});
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final totalDays = goal.endDate.difference(goal.startDate).inDays;
    final elapsed = DateTime.now()
        .difference(goal.startDate)
        .inDays
        .clamp(0, totalDays);
    final progress = totalDays > 0 ? elapsed / totalDays : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Formatters.shortDate(goal.startDate)),
                Text(Formatters.shortDate(goal.endDate)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.info),
              ),
            ),
            const SizedBox(height: 8),
            Text('Week ${(elapsed / 7).ceil()} of ${(totalDays / 7).ceil()}'),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final Plan session;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: session.completed
              ? AppColors.success.withOpacity(0.15)
              : AppColors.surfaceVariant,
          child: Icon(
            session.completed ? Icons.check : Icons.schedule,
            color: session.completed
                ? AppColors.success
                : AppColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          session.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${Formatters.shortDate(session.date)} · ${Formatters.duration(session.targetDuration)} · TSS ${Formatters.load(session.targetLoad)}',
        ),
      ),
    );
  }
}
