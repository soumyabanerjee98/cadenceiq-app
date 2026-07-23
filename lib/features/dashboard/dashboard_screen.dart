import 'dart:math';

import 'package:cadenceiq_app/core/assets/assets.dart';
import 'package:cadenceiq_app/core/utils/snackbar.dart';
import 'package:cadenceiq_app/core/widgets/loading.dart';
import 'package:cadenceiq_app/core/constants/app_strings.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/features/goals/create_goal_screen.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/providers/activity_provider.dart';
import 'package:cadenceiq_app/providers/goal_provider.dart';
import 'package:cadenceiq_app/services/mock/mock_data.dart';
import 'package:cadenceiq_app/services/repo/activity_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/formatters.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/chart_widgets.dart';
import 'package:cadenceiq_app/core/widgets/metric_card.dart';
import 'package:cadenceiq_app/core/widgets/progress_card.dart';
import 'package:cadenceiq_app/providers/dashboard_provider.dart';
import 'package:cadenceiq_app/providers/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late DashboardProvider dashboard;
  late GoalProvider goal;
  late ActivityProvider activity;
  late final AnimationController _controller;
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
    _controller = AnimationController(vsync: this);
    tagline = getRandomGoalTagline();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await dashboard.refresh();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dashboard = context.watch<DashboardProvider>();
    goal = context.watch<GoalProvider>();
    final settings = context.watch<SettingsProvider>();
    final padding = Responsive.horizontalPadding(context);
    final user = dashboard.user;
    final metrics = MockData.metrics;

    final session = MockData.todaySession;

    if (user == null) return AppLoading();

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
                if (goal.activeGoal != null) ...[
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
                  const SizedBox(height: 8),
                  ProgressCard(
                    title: goal.activeGoal?.title ?? "",
                    progress: double.parse(
                      (goal.activeGoal?.completion).toString(),
                    ),
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
                  const SizedBox(height: 20),
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
                      child: ZoneDistributionChart(
                        zones: metrics.zoneDistribution,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: AppStrings.todaysSession),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${Formatters.duration(session.duration)} · ${Formatters.distanceKm(session.distanceKm, imperial: settings.useImperial)} · TSS ${Formatters.load(session.targetLoad)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  session.zone,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Lottie.asset(
                      AppLotties.noGoal,
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller.duration = composition.duration;

                        _controller.addStatusListener((status) async {
                          if (status == AnimationStatus.completed && mounted) {
                            await Future.delayed(const Duration(seconds: 2));
                            if (mounted) _controller.forward(from: 0);
                          }
                        });

                        if (mounted) _controller.forward();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "No",
                        style: TextStyle(color: AppColors.primary),
                        children: [
                          TextSpan(
                            text: " Goal... ",
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                          TextSpan(
                            text: " No",
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(
                            text: " Progress...",
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tagline,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: "Create Goal",
                    expand: false,
                    onPressed: dashboard.user?.stravaConnected == true
                        ? _navigateToGoal
                        : null,
                    shine: dashboard.user?.stravaConnected == true,
                    isLoading: loading,
                  ),
                ],
                const SizedBox(height: 20),
                _SectionTitle(title: AppStrings.quickActions),
                const SizedBox(height: 12),
                if (dashboard.user?.stravaConnected != true) ...[
                  Row(
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.warning,
                      ),
                      Text(
                        "Strava not connected!",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Connect Strava to create goal and sync activities!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  PrimaryButton(
                    label: "Connect Strava",
                    expand: false,
                    onPressed: () => context.push(RoutePaths.connectStrava),
                    shine: true,
                  ),
                ],
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickAction(
                      icon: Icons.directions_bike,
                      label: AppStrings.navActivities,
                      onTap: () => context.go(RoutePaths.activities),
                    ),
                    _QuickAction(
                      icon: Icons.flag,
                      label: AppStrings.navGoals,
                      onTap: () => context.go(RoutePaths.goals),
                    ),
                    _QuickAction(
                      icon: Icons.summarize,
                      label: AppStrings.navSummaries,
                      onTap: () => context.go(RoutePaths.summaries),
                    ),
                    _QuickAction(
                      icon: Icons.settings,
                      label: AppStrings.navSettings,
                      onTap: () => context.go(RoutePaths.settings),
                    ),
                  ],
                ),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.sizeOf(context).width - 52) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
