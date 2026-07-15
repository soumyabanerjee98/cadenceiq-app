import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/formatters.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/metric_card.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/providers/dashboard_provider.dart';
import 'package:cadenceiq_app/providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<DashboardProvider>().user;
    final imperial = context.watch<SettingsProvider>().useImperial;
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: CadenceAppBar(
        showBack: true,
        title: 'Profile',
        actions: [
          TextButton(
            onPressed: () => context.push(RoutePaths.updateProfile),
            child: const Text("Edit"),
          ),
        ],
      ),
      body: SafePage(
        child: ListView(
          padding: EdgeInsets.all(padding),
          children: [
            Center(
              child: Hero(
                tag: 'profile-avatar',
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: ClipOval(
                    child: (user?.avatarUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            user!.avatarUrl!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return Text(
                                user.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              user?.initials ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.name ?? "",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Center(
              child: Text(
                user?.email ?? "",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'User Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _InfoRow(label: 'Age', value: '${user?.age ?? "-"} years'),
                  const Divider(height: 1),
                  _InfoRow(label: 'Max HR', value: Formatters.bpm(user?.maxHr)),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Resting HR',
                    value: Formatters.bpm(user?.restingHr),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Performance Stats',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                MetricCard(
                  label: 'Total Activities',
                  value: '${user?.totalActivities}',
                  icon: Icons.directions_bike,
                ),
                MetricCard(
                  label: 'Total Distance',
                  value: Formatters.distanceKm(
                    (user?.totalDistance ?? 0) / 1000,
                    imperial: imperial,
                  ),
                  icon: Icons.straighten,
                ),
                MetricCard(
                  label: 'Total Hours',
                  value: (user?.totalHours ?? 0).toStringAsFixed(0),
                  unit: 'hrs',
                  icon: Icons.timer,
                ),
                MetricCard(
                  label: 'Goals Completed',
                  value: '${user?.goalsCompleted}',
                  icon: Icons.emoji_events,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
