import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/formatters.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/metric_card.dart';
import 'package:cadenceiq_app/providers/activity_provider.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/providers/settings_provider.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context) {
    final activity = context.read<ActivityProvider>().getById(activityId);
    final imperial = context.watch<SettingsProvider>().useImperial;
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafePage(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.6),
                        AppColors.primary,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.terrain, size: 64, color: Colors.white54),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...activity.splits.map(
                      (s) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            "Split ${s.label}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
    );
  }
}
