import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/formatters.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/state_widgets.dart';
import 'package:cadenceiq_app/models/activity.dart';
import 'package:cadenceiq_app/services/repo/activity_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SyncStravaActivity extends StatefulWidget {
  const SyncStravaActivity({super.key});

  @override
  State<SyncStravaActivity> createState() => _SyncStravaActivityState();
}

class _SyncStravaActivityState extends State<SyncStravaActivity> {
  final ScrollController _scrollController = ScrollController();
  final ActivityRepository _repo = ActivityRepository();
  List<StravaActivity> activities = [];
  List<int> selectedActivities = [];
  bool loading = false;
  bool loadingMore = false;
  int currentPage = 1;
  bool hasNext = false;
  bool syncing = false;

  Future<void> fetchActivities() async {
    setState(() {
      loading = true;
    });
    final res = await _repo.fetchStravaActivities(currentPage: currentPage);
    if (res.response != null) {
      if (mounted) {
        setState(() {
          activities = (res.response['activities'] as List)
              .map((e) => StravaActivity.fromJson(e))
              .toList();
          hasNext = res.response["hasNext"];
          currentPage = res.response["nextPage"];
        });
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchMoreActivities() async {
    if (loadingMore == true || hasNext == false) return;
    setState(() {
      loadingMore = true;
    });
    final res = await _repo.fetchStravaActivities(currentPage: currentPage);
    if (res.response != null) {
      final List<StravaActivity> newActivities =
          (res.response['activities'] as List)
              .map((e) => StravaActivity.fromJson(e))
              .toList();
      if (mounted) {
        setState(() {
          activities.addAll(newActivities);
          hasNext = res.response["hasNext"];
          currentPage = res.response["nextPage"];
        });
      }
    }
    if (mounted) {
      setState(() {
        loadingMore = false;
      });
    }
  }

  Future<void> refresh() async {
    setState(() {
      currentPage = 1;
      activities.clear();
    });
    fetchActivities();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    const threshold = 300.0;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      fetchMoreActivities();
    }
  }

  Future<void> _sync() async {
    setState(() {
      syncing = true;
    });
    final res = await _repo.syncStravaActivities(
      activityIds: selectedActivities,
    );
    if (mounted) {
      setState(() {
        syncing = false;
      });
      if (res.response != null) {
        context.pop(true);
      }
    }
  }

  @override
  void initState() {
    fetchActivities();
    _scrollController.addListener(_onScroll);
    super.initState();
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
    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: PrimaryButton(
          label:
              "Sync${selectedActivities.isNotEmpty ? " ${selectedActivities.length} " : " "}Activities",
          // isLoading: auth.state == AuthState.loading,
          onPressed: selectedActivities.isNotEmpty ? _sync : null,
          isLoading: syncing,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: ActivitiesHeaderDelegate(),
            ),
            if (loading)
              const SliverFillRemaining(child: SkeletonList())
            else if (activities.isEmpty)
              const SliverFillRemaining(
                child: EmptyStateWidget(
                  title: 'No activities found!',
                  message: 'Start recording activities on Strava.',
                  icon: Icons.directions_bike_outlined,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final activity = activities[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Formatters.date(activity.date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      Formatters.distanceKm(
                                        activity.distance / 1000,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: selectedActivities.contains(
                                  int.parse(activity.id),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == false) {
                                      selectedActivities.remove(
                                        int.parse(activity.id),
                                      );
                                    } else {
                                      selectedActivities.add(
                                        int.parse(activity.id),
                                      );
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: activities.length),
                ),
              ),
            if (loadingMore)
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
  @override
  double get minExtent => kToolbarHeight * 2;

  @override
  double get maxExtent => kToolbarHeight * 2;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const CadenceAppBar(showBack: true, title: 'Sync New Activities');
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
