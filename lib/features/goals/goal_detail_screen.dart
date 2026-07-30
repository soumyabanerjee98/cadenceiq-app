import 'package:cadenceiq_app/core/utils/date.dart';
import 'package:cadenceiq_app/core/widgets/activity_card.dart';
import 'package:cadenceiq_app/core/widgets/ai_insight_card.dart';
import 'package:cadenceiq_app/models/activity.dart';
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

class GoalDetails extends StatefulWidget {
  final Goal goal;
  const GoalDetails({super.key, required this.goal});

  @override
  State<GoalDetails> createState() => _GoalDetailsState();
}

class _GoalDetailsState extends State<GoalDetails> {
  late GoalProvider goal;

  @override
  void initState() {
    goal = context.read<GoalProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    goal = context.watch<GoalProvider>();
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: goal.getCurrentGoal,
      child: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          _InfoCard(goal: widget.goal),
          const SizedBox(height: 20),
          Text(
            'Training Plan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _Timeline(goal: widget.goal),
          const SizedBox(height: 20),
          Text(
            'Planned Sessions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...widget.goal.plans.map(
            (s) => _SessionTile(
              plan: s,
              activities: widget.goal.activities
                  .where((e) => DateHelper.isSameDate(s.date, e.date))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      GoalStatus.ontrack => ('On Track', AppColors.success),
      GoalStatus.overtrained => ('Completed', AppColors.warning),
      GoalStatus.undertrained => ('Upcoming', AppColors.info),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.title, style: Theme.of(context).textTheme.titleLarge),
                _StatusChip(status: goal.status),
              ],
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: "Description: ",
                children: [
                  TextSpan(
                    text: "\"${goal.customGoalRequest}\"",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
              '${Formatters.percent(double.parse(goal.completion.toString()))} complete · ${goal.daysRemaining > 0 ? '${goal.daysRemaining} days left' : 'Ends today'}',
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

class _SessionTile extends StatefulWidget {
  const _SessionTile({required this.plan, required this.activities});

  final Plan plan;
  final List<Activity> activities;

  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile>
    with SingleTickerProviderStateMixin {
  late GoalProvider goal;
  bool expanded = false;

  IconData get _statusIcon {
    if (widget.plan.completed) return Icons.check;

    if (widget.plan.type == PlanType.rest &&
        DateHelper.isPastToday(widget.plan.date)) {
      return Icons.check;
    }

    if (DateHelper.isPastToday(widget.plan.date)) {
      return Icons.close;
    }

    return Icons.schedule;
  }

  bool get _isFuture => widget.plan.date.isAfter(
    DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
  );

  Color get _statusColor {
    if (widget.plan.completed) {
      return AppColors.success;
    }

    if (widget.plan.type == PlanType.rest &&
        DateHelper.isPastToday(widget.plan.date)) {
      return AppColors.success;
    }

    if (_isFuture) {
      return AppColors.textTertiary;
    }

    if (DateHelper.isPastToday(widget.plan.date)) {
      return AppColors.error;
    }

    return AppColors.textTertiary;
  }

  @override
  void initState() {
    goal = context.read<GoalProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    goal = context.watch<GoalProvider>();
    final actualLoad = widget.activities.fold<num>(
      0,
      (sum, e) => sum + e.trainingLoad,
    );

    final completion = (actualLoad / widget.plan.targetLoad)
        .clamp(0.0, 1.0)
        .toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          maintainState: true,

          initiallyExpanded: false,

          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,

          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),

          leading: CircleAvatar(
            backgroundColor: _statusColor.withValues(alpha: .12),
            child: Icon(_statusIcon, color: _statusColor),
          ),
          collapsedIconColor: AppColors.primary,
          title: Row(
            spacing: 12,
            children: [
              Text(
                widget.plan.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (DateHelper.isToday(widget.plan.date))
                Text(
                  "Active",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              if (widget.plan.type != PlanType.rest)
                Text(
                  "${Formatters.shortDate(widget.plan.date)} • "
                  "${Formatters.duration(widget.plan.targetDuration)} • "
                  "${widget.plan.targetDistance} km",
                )
              else
                Text(Formatters.shortDate(widget.plan.date)),
              if (widget.plan.type != PlanType.rest) ...[
                const SizedBox(height: 10),

                LinearProgressIndicator(
                  value: completion,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.info,
                  backgroundColor: AppColors.divider,
                ),

                const SizedBox(height: 6),

                Text(
                  "${actualLoad.toStringAsFixed(0)} / ${widget.plan.targetLoad} TSS",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),

          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  const SizedBox(height: 8),

                  Text(widget.plan.description),

                  if ((widget.plan.instructions ?? "").isNotEmpty) ...[
                    const SizedBox(height: 20),

                    Text(
                      "Instructions",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),

                    const SizedBox(height: 8),

                    Text(widget.plan.instructions!),
                  ],
                  if (widget.plan.type != PlanType.rest) ...[
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.route,
                            title: "Distance",
                            value: "${widget.plan.targetDistance} km",
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.schedule,
                            title: "Duration",
                            value: Formatters.duration(
                              widget.plan.targetDuration,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.bolt,
                            title: "Target",
                            value: "${widget.plan.targetLoad}",
                          ),
                        ),
                      ],
                    ),
                    if (DateHelper.isToday(widget.plan.date) ||
                        DateHelper.isPastToday(widget.plan.date)) ...[
                      const SizedBox(height: 24),

                      Text(
                        "Activities",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),

                      const SizedBox(height: 12),

                      if (widget.activities.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "No activity recorded.",
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...widget.activities.map(
                          (activity) => ActivityCard(activity: activity),
                        ),
                      if (widget.plan.insight != null)
                        AiInsightCard(
                          title: "Daily Insight",
                          child: Text(
                            widget.plan.insight!.commentary,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Icon(icon),

            const SizedBox(height: 8),

            Text(value, style: Theme.of(context).textTheme.titleSmall),

            const SizedBox(height: 4),

            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
