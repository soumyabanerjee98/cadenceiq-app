import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/widgets/warning_card.dart';
import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/widgets/activity_card.dart';
import 'package:cadenceiq/core/widgets/state_widgets.dart';
import 'package:cadenceiq/models/activity.dart';
import 'package:cadenceiq/providers/activity_provider.dart';

class ActivitiesListScreen extends StatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  State<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends State<ActivitiesListScreen> {
  final ScrollController _scrollController = ScrollController();
  late ActivityProvider activity;

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    const threshold = 300.0;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      activity.loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
    activity = context.read<ActivityProvider>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final dashboard = context.watch<DashboardProvider>();
    activity = context.watch<ActivityProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => activity.refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: ActivitiesHeaderDelegate(dashboard: dashboard),
            ),
            if (activity.state == LoadState.loading)
              const SliverFillRemaining(child: SkeletonList())
            else if (activity.state == LoadState.error)
              SliverFillRemaining(
                child: ErrorStateWidget(
                  message: activity.errorMessage ?? 'Failed to load',
                  onRetry: activity.refresh,
                ),
              )
            else if (activity.activities.isEmpty)
              const SliverFillRemaining(
                child: EmptyStateWidget(
                  title: 'No activities yet!',
                  message: 'Your rides will appear here once recorded.',
                  icon: Icons.directions_bike_outlined,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final singleActivity = activity.activities[i];
                    return ActivityCard(
                      activity: singleActivity,
                      onTap: () async {
                        final reload = await context.push<bool>(
                          '/activities/${singleActivity.id}',
                        );
                        if (reload == true) {
                          activity.refresh();
                        }
                      },
                    );
                  }, childCount: activity.activities.length),
                ),
              ),
            if (activity.state == LoadState.loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ActivitiesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DashboardProvider dashboard;

  const ActivitiesHeaderDelegate({required this.dashboard});

  @override
  double get minExtent =>
      kToolbarHeight + (dashboard.user?.stravaConnected == true ? 150 : 209);

  @override
  double get maxExtent =>
      kToolbarHeight + (dashboard.user?.stravaConnected == true ? 150 : 209);

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
      padding: EdgeInsets.fromLTRB(padding, 16, padding, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activities',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                constraints: BoxConstraints(),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // Shrinks hit test area
                ),
                onPressed: dashboard.user?.stravaConnected == true
                    ? () async {
                        final res = await context.push<bool>(
                          RoutePaths.syncActivity,
                        );
                        if (res == true) {
                          provider.refresh();
                        }
                      }
                    : null,
                icon: Icon(
                  dashboard.user?.stravaConnected == true
                      ? Icons.sync_rounded
                      : Icons.sync_lock_rounded,
                  color: dashboard.user?.stravaConnected == true
                      ? AppColors.primary
                      : AppColors.warning,
                ),
                tooltip: dashboard.user?.stravaConnected == true
                    ? "Sync New Activities"
                    : "Strava Not Connected",
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (dashboard.user?.stravaConnected == false)
            WarningCard(
              message: "Strava not connected!",
              action: () => context.push(RoutePaths.connectStrava),
              actionText: "Connect",
            ),
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
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
