import 'package:flutter/material.dart';

import 'package:cadenceiq/models/activity.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, this.onTap});

  final Activity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _ZoneIndicator(zone: activity.zone),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.date(activity.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                          icon: Icons.straighten,
                          label: Formatters.distanceKm(activity.distanceKm),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          icon: Icons.timer_outlined,
                          label: Formatters.duration(activity.duration),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          icon: Icons.bolt,
                          label:
                              'TSS ${Formatters.load(activity.trainingLoad)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneIndicator extends StatelessWidget {
  const _ZoneIndicator({required this.zone});
  final TrainingZone zone;

  Color get _color => switch (zone) {
    TrainingZone.z1 => AppColors.zone1,
    TrainingZone.z2 => AppColors.zone2,
    TrainingZone.z3 => AppColors.zone3,
    TrainingZone.z4 => AppColors.zone4,
    TrainingZone.z5 => AppColors.zone5,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          zone.name.toUpperCase(),
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
