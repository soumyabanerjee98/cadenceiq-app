import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/formatters.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/metric_card.dart';
import 'package:cadenceiq_app/models/goal_summary.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/providers/summary_provider.dart';

class SummaryDetailScreen extends StatelessWidget {
  const SummaryDetailScreen({super.key, required this.summaryId});

  final String summaryId;

  @override
  Widget build(BuildContext context) {
    final summary = context.read<SummaryProvider>().getById(summaryId);
    final padding = Responsive.horizontalPadding(context);

    if (summary == null) {
      return Scaffold(
        appBar: const CadenceAppBar(showBack: true, title: 'Summary'),
        body: const SafePage(child: Center(child: Text('Summary not found'))),
      );
    }

    return Scaffold(
      appBar: CadenceAppBar(showBack: true, title: summary.goalTitle),
      body: SafePage(
        child: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          _OverviewHeader(summary: summary),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Completion',
                  value: Formatters.percent(summary.completionPercent),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Sessions',
                  value: '${summary.completedSessions}/${summary.plannedSessions}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Training Load',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _CompareRow(
                    label: 'Planned Load',
                    value: Formatters.load(summary.plannedLoad),
                  ),
                  const Divider(height: 24),
                  _CompareRow(
                    label: 'Actual Load',
                    value: Formatters.load(summary.actualLoad),
                    highlight: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${((summary.actualLoad / summary.plannedLoad) * 100).round()}% of planned volume',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Fitness Progression',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CtlStat(label: 'Start CTL', value: summary.ctlStart),
                  const Icon(Icons.arrow_forward, color: AppColors.primary),
                  _CtlStat(label: 'End CTL', value: summary.ctlEnd),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AI Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...summary.insights.map((insight) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(insight, style: const TextStyle(height: 1.5))),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...summary.badges.map((b) => _BadgeCard(badge: b)),
          const SizedBox(height: 32),
        ],
        ),
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.summary});
  final GoalSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.goalTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    Text(
                      '${Formatters.date(summary.startDate)} – ${Formatters.date(summary.endDate)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(summary.experienceLevel),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: highlight ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}

class _CtlStat extends StatelessWidget {
  const _CtlStat({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: AppColors.primary),
        ),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final AchievementBadge badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: const Icon(Icons.emoji_events, color: AppColors.primary),
        ),
        title: Text(badge.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(badge.description),
      ),
    );
  }
}
