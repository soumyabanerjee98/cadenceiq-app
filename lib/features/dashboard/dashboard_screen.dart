import 'dart:math';

import 'package:cadenceiq_app/core/assets/assets.dart';
import 'package:cadenceiq_app/core/components/loading.dart';
import 'package:cadenceiq_app/core/constants/app_strings.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/services/mock/mock_data.dart';
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
  late final AnimationController _controller;
  late final String tagline;
  final _random = Random();

  String getRandomGoalTagline() {
    return AppStrings.goalTaglines[_random.nextInt(
      AppStrings.goalTaglines.length,
    )];
  }

  @override
  void initState() {
    final dashboard = context.read<DashboardProvider>();
    _controller = AnimationController(vsync: this);
    tagline = getRandomGoalTagline();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboard.refresh();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final settings = context.watch<SettingsProvider>();
    final padding = Responsive.horizontalPadding(context);
    final user = dashboard.user;
    final metrics = MockData.metrics;
    final goal = MockData.activeGoal;
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
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (dashboard.user?.goal != null) ...[
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
                    title: goal.title,
                    progress: goal.progress,
                    daysRemaining: goal.daysRemaining,
                    onTap: () => context.push('/goals/${goal.id}'),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: AppStrings.trainingMetrics),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Current Load',
                          value: Formatters.load(metrics.currentLoad),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: 'Target Load',
                          value: Formatters.load(metrics.targetLoad),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: 'Adjusted',
                          value: Formatters.load(metrics.adjustedLoad),
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
                      child: WeeklyLoadChart(data: metrics.weeklyLoads),
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
                        // Configure the AnimationController with the duration of the
                        // Lottie file and start the animation.
                        _controller
                          ..duration = composition.duration
                          ..repeat();
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
                    onPressed: () => context.push(RoutePaths.createGoal),
                    shine: true,
                  ),
                ],
                const SizedBox(height: 20),
                _SectionTitle(title: AppStrings.quickActions),
                const SizedBox(height: 12),
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
