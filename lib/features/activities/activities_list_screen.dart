import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/activity_card.dart';
import 'package:cadenceiq_app/core/widgets/state_widgets.dart';
import 'package:cadenceiq_app/models/activity.dart';
import 'package:cadenceiq_app/providers/activity_provider.dart';

class ActivitiesListScreen extends StatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  State<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends State<ActivitiesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ActivitiesHeaderDelegate(),
          ),
          if (provider.state == LoadState.loading)
            const SliverFillRemaining(child: SkeletonList())
          else if (provider.state == LoadState.error)
            SliverFillRemaining(
              child: ErrorStateWidget(
                message: provider.errorMessage ?? 'Failed to load',
                onRetry: provider.refresh,
              ),
            )
          else if (provider.activities.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateWidget(
                title: 'No activities yet',
                message: 'Your rides will appear here once recorded.',
                icon: Icons.directions_bike_outlined,
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final activity = provider.activities[i];
                    return ActivityCard(
                      activity: activity,
                      onTap: () => context.push('/activities/${activity.id}'),
                    );
                  },
                  childCount: provider.activities.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ActivitiesHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => kToolbarHeight + 135;

  @override
  double get maxExtent => kToolbarHeight + 135;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final provider = context.watch<ActivityProvider>();

    final padding = Responsive.horizontalPadding(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(
        padding,
        16,
        padding,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search rides...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: provider.setSearch,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: provider.zoneFilter == null,
                  onTap: () => provider.setZoneFilter(null),
                ),
                ...TrainingZone.values.map(
                  (z) => _FilterChip(
                    label: z.name.toUpperCase(),
                    selected: provider.zoneFilter == z,
                    onTap: () => provider.setZoneFilter(z),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant SliverPersistentHeaderDelegate oldDelegate,
  ) {
    return true;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}
