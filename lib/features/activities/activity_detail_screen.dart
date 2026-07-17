import 'package:cadenceiq_app/core/widgets/activity_map.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/models/activity.dart';
import 'package:cadenceiq_app/services/repo/activity_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/formatters.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/metric_card.dart';
import 'package:cadenceiq_app/providers/activity_provider.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/providers/settings_provider.dart';

class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final ActivityRepository _repo = ActivityRepository();
  bool syncing = false;
  bool reload = false;
  late Activity activity;
  late ActivityProvider provider;

  Future<void> _resync() async {
    setState(() {
      syncing = true;
    });
    final res = await _repo.syncStravaActivities(
      activityIds: [int.parse(widget.activityId)],
    );
    if (res.response != null) {
      if (mounted) {
        setState(() {
          reload = true;
        });
      }
      final data = await _repo.fetchSingle(activityId: widget.activityId);
      if (data.response != null) {
        if (mounted) {
          setState(() {
            activity = Activity.fromJson(data.response);
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        syncing = false;
      });
    }
  }

  @override
  void initState() {
    provider = context.read<ActivityProvider>();
    setState(() {
      activity = provider.getById(widget.activityId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imperial = context.watch<SettingsProvider>().useImperial;
    provider = context.watch<ActivityProvider>();
    final padding = Responsive.horizontalPadding(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.pop(reload);
      },
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: PrimaryButton(
            label: "Re-sync activity",
            // isLoading: auth.state == AuthState.loading,
            onPressed: _resync,
            isLoading: syncing,
          ),
        ),
        body: SafePage(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => context.pop(reload),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    activity.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  background: activity.map != null
                      ? ActivityMap(polyline: activity.map!)
                      : Center(
                          child: Text(
                            "No Map Data!",
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: AppColors.darkTextSecondary),
                          ),
                        ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      '${activity.zoneLabel} · ${Formatters.date(activity.date)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        MetricCard(
                          label: 'Distance',
                          value: Formatters.distanceKm(
                            activity.distanceKm,
                            imperial: imperial,
                          ),
                          icon: Icons.straighten,
                        ),
                        MetricCard(
                          label: 'Duration',
                          value: Formatters.duration(activity.duration),
                          icon: Icons.timer,
                        ),
                        MetricCard(
                          label: 'Elevation',
                          value: Formatters.elevationM(
                            activity.elevationM,
                            imperial: imperial,
                          ),
                          icon: Icons.terrain,
                        ),
                        MetricCard(
                          label: 'Avg Speed',
                          value: Formatters.speedKmh(
                            activity.avgSpeedKmh,
                            imperial: imperial,
                          ),
                          icon: Icons.speed,
                        ),
                        MetricCard(
                          label: 'Avg HR',
                          value: '${activity.avgHr ?? "-"}',
                          unit: 'bpm',
                          icon: Icons.favorite,
                          color: AppColors.error,
                        ),
                        MetricCard(
                          label: 'Max HR',
                          value: '${activity.maxHr ?? "-"}',
                          unit: 'bpm',
                          icon: Icons.favorite_border,
                          color: AppColors.error,
                        ),
                        MetricCard(
                          label: 'Calories',
                          value: '${activity.calories}',
                          unit: 'kcal',
                          icon: Icons.local_fire_department,
                        ),
                        MetricCard(
                          label: 'Avg Power',
                          value: Formatters.watts(activity.avgPower),
                          icon: Icons.bolt,
                        ),
                        MetricCard(
                          label: 'Training Load',
                          value: Formatters.load(activity.trainingLoad),
                          unit: 'TSS',
                          icon: Icons.show_chart,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    if (activity.splits.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Splits',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      ...activity.splits.map(
                        (s) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              "Split ${s.label}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${Formatters.distanceKm(s.distanceKm, imperial: imperial)} · ${Formatters.duration(s.duration)} · ${Formatters.speedKmh(s.avgSpeedKmh, imperial: imperial)} · ${s.avgHr != null ? (s.avgHr)?.toStringAsPrecision(3) : "-"} bpm',
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
