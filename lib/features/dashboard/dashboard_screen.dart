import 'dart:math';
import 'package:cadenceiq/core/widgets/ai_action_button.dart';
import 'package:cadenceiq/core/widgets/ai_insight_card.dart';
import 'package:cadenceiq/core/widgets/warning_card.dart';
import 'package:cadenceiq/models/activity.dart';
import 'package:collection/collection.dart';

import 'package:cadenceiq/core/utils/date.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/core/widgets/loading.dart';
import 'package:cadenceiq/core/constants/app_strings.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/features/goals/create_goal_screen.dart';
import 'package:cadenceiq/models/goal.dart';
import 'package:cadenceiq/providers/activity_provider.dart';
import 'package:cadenceiq/providers/goal_provider.dart';
import 'package:cadenceiq/services/repo/activity_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/formatters.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/widgets/chart_widgets.dart';
import 'package:cadenceiq/core/widgets/metric_card.dart';
import 'package:cadenceiq/core/widgets/progress_card.dart';
import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:cadenceiq/providers/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardProvider dashboard;
  late GoalProvider goal;
  late ActivityProvider activity;
  late final String tagline;
  final _random = Random();
  bool loading = false;
  final ActivityRepository _repository = ActivityRepository();

  String getRandomGoalTagline() {
    return AppStrings.goalTaglines[_random.nextInt(
      AppStrings.goalTaglines.length,
    )];
  }

  Future<void> _navigateToGoal() async {
    setState(() {
      loading = true;
    });
    final res = await _repository.fetchExperienceLevel();
    setState(() {
      loading = false;
    });
    if (res.response != null) {
      final Map<String, ExperienceLevel> record = {
        'beginner': ExperienceLevel.beginner,
        'intermediate': ExperienceLevel.intermediate,
        'advanced': ExperienceLevel.advanced,
        'elite': ExperienceLevel.elite,
      };
      final ExperienceLevel? level = record[res.response['level']];
      if (level != null) {
        if (!mounted) return;
        context.push(
          RoutePaths.createGoal,
          extra: CreateGoalScreenArgs(experienceLevel: level),
        );
      }
      return;
    }
    if (!mounted) return;
    AppSnackbar.show(
      context,
      message: res.error?.errorMessage ?? "Something went wrong! Try again",
      status: SnackbarStatus.error,
    );
  }

  @override
  void initState() {
    dashboard = context.read<DashboardProvider>();
    goal = context.read<GoalProvider>();
    activity = context.read<ActivityProvider>();
    tagline = getRandomGoalTagline();
    super.initState();
    dashboard.refresh(hardRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    dashboard = context.watch<DashboardProvider>();
    goal = context.watch<GoalProvider>();
    final settings = context.watch<SettingsProvider>();
    final padding = Responsive.horizontalPadding(context);
    final user = dashboard.user;
    final Plan? session = goal.activeGoal?.plans.firstWhereOrNull(
      (e) => DateHelper.isToday(e.date),
    );

    final List<Activity> todayActivities =
        goal.activeGoal?.activities
            .where((e) => DateHelper.isToday(e.date))
            .toList() ??
        [];

    if (user == null || dashboard.isLoading) return AppLoading();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: dashboard.refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 16, padding, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dashboard.greeting,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          (user.name ?? "").split(' ').first,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.profile),
                    child: Hero(
                      tag: 'profile-avatar',
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: ClipOval(
                          child: (user.avatarUrl?.isNotEmpty ?? false)
                              ? Image.network(
                                  user.avatarUrl!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return Text(
                                          user.initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        );
                                      },
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      user.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    user.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!user.stravaConnected)
                  WarningCard(
                    message: "Strava not connected!",
                    action: () => context.push(RoutePaths.connectStrava),
                    actionText: "Connect",
                  ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    final metricsRow = [
                      MetricCard(
                        label: AppStrings.currentFitness,
                        value: (dashboard.user?.ctl ?? 0).toStringAsFixed(1),
                        // trend: '+3.2 this week',
                        color: AppColors.success,
                        icon: Icons.trending_up,
                      ),
                      MetricCard(
                        label: AppStrings.fatigue,
                        value: (dashboard.user?.atl ?? 0).toStringAsFixed(1),
                        color: AppColors.warning,
                        icon: Icons.battery_alert,
                      ),
                      MetricCard(
                        label: AppStrings.readiness,
                        value: (dashboard.user?.tsb ?? 0).toStringAsFixed(1),
                        // trend: 'Fresh',
                        color: AppColors.info,
                        icon: Icons.bolt,
                      ),
                    ];
                    if (isWide) {
                      return Row(
                        children: metricsRow
                            .map(
                              (m) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: m,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }
                    return Column(
                      children: metricsRow
                          .map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: m,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: AppStrings.weeklyLoad),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: WeeklyLoadChart(data: user.weeklyLoad),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: AppStrings.zoneDistribution),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ZoneDistributionChart(zones: user.zoneDistribution),
                  ),
                ),
                if (goal.activeGoal != null) ...[
                  ProgressCard(
                    title: goal.activeGoal?.title ?? "",
                    progress: double.parse(
                      (goal.activeGoal?.completion).toString(),
                    ),
                    status: goal.activeGoal!.status,
                    daysRemaining: goal.activeGoal?.daysRemaining,
                    onTap: () => context.push('/goals/${goal.activeGoal?.id}'),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: AppStrings.trainingMetrics),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Current Load',
                          value: Formatters.load(goal.activeGoal!.currentLoad),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: 'Target Load',
                          value: Formatters.load(goal.activeGoal!.targetLoad),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: 'Adjusted',
                          value: Formatters.load(goal.activeGoal!.adjustedLoad),
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                  if (session != null) ...[
                    const SizedBox(height: 20),
                    _SectionTitle(title: AppStrings.todaysSession),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: planColor(
                                            session.type,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          planIcon(session.type),
                                          color: planColor(session.type),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: constraints.maxWidth * 0.7,
                                            child: Text(
                                              session.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: planColor(session.type),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (session.type != PlanType.rest)
                                            Text(
                                              '${Formatters.distanceKm(session.targetDistance.toDouble(), imperial: settings.useImperial)} · ${Formatters.duration(session.targetDuration)} · TSS ${Formatters.load(session.targetLoad)}',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  CircleAvatar(
                                    backgroundColor: session.completed
                                        ? AppColors.success.withOpacity(0.15)
                                        : !DateHelper.isPastToday(session.date)
                                        ? AppColors.surfaceVariant
                                        : AppColors.error.withOpacity(0.15),
                                    child: Icon(
                                      session.completed
                                          ? Icons.check
                                          : !DateHelper.isPastToday(
                                              session.date,
                                            )
                                          ? Icons.schedule
                                          : Icons.close,
                                      color: session.completed
                                          ? AppColors.success
                                          : !DateHelper.isPastToday(
                                              session.date,
                                            )
                                          ? AppColors.textTertiary
                                          : AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final actualLoad = todayActivities.fold<num>(
                                    0,
                                    (sum, e) => sum + e.trainingLoad,
                                  );
                                  final completion =
                                      (actualLoad / session.targetLoad)
                                          .clamp(0.0, 1.0)
                                          .toDouble();
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      LinearProgressIndicator(
                                        value: completion,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(20),
                                        color: AppColors.info,
                                        backgroundColor: AppColors.divider,
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        "${(session.actualLoad ?? 0).toStringAsFixed(0)} / ${session.targetLoad} TSS",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (session.insight != null)
                      AiInsightCard(
                        title: "Daily Insight",
                        child: Text(
                          session.insight!.commentary,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    if (todayActivities.isNotEmpty &&
                        session.type != PlanType.rest)
                      Row(
                        children: [
                          AiActionButton(
                            loading: goal.isDailyInsightLoading,
                            onPressed: () =>
                                goal.generateDailyInsight(session.date),
                            label: session.insight != null
                                ? "Re-generate Daily Insight"
                                : "Generate Daily Insight",
                          ),
                        ],
                      ),
                  ],
                ] else ...[
                  const SizedBox(height: 24),
                  Icon(Icons.flag_outlined, size: 48, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'No active goal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: PrimaryButton(
                      label: 'Create Goal',
                      expand: false,
                      onPressed: dashboard.user?.stravaConnected == true
                          ? _navigateToGoal
                          : null,
                      shine: dashboard.user?.stravaConnected == true,
                      isLoading: loading,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (dashboard.user?.stravaConnected != true) ...[
                  WarningCard(
                    message:
                        'Connect Strava to create goals and sync activities!',
                    actionText: 'Connect',
                    action: () => context.push(RoutePaths.connectStrava),
                    type: WarningCardType.warning,
                    icon: Icons.warning_amber_outlined,
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
