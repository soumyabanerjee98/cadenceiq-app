import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/theme/app_spacing.dart';
import 'package:cadenceiq/core/utils/app_animations.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/core/widgets/floating_action_button.dart';
import 'package:cadenceiq/core/widgets/goal_card.dart';
import 'package:cadenceiq/core/widgets/state_widgets.dart';
import 'package:cadenceiq/features/goals/create_goal_screen.dart';
import 'package:cadenceiq/features/goals/goal_detail_screen.dart';
import 'package:cadenceiq/services/repo/activity_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/models/goal.dart';
import 'package:cadenceiq/providers/goal_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late GoalProvider goal;
  late TabController _tabController;
  bool loading = false;
  final ActivityRepository _repository = ActivityRepository();

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
    super.initState();
    goal = context.read<GoalProvider>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    goal = context.watch<GoalProvider>();
    final padding = Responsive.horizontalPadding(context);

    if (goal.isLoading && goal.activeGoal == null && goal.pastGoals.isEmpty) {
      return const Scaffold(body: SkeletonList());
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, AppSpacing.lg, padding, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Goals',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Current Goal'),
                  Tab(text: 'Past Goals'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _GoalDetails(goal: goal.activeGoal),
            _GoalList(goals: goal.pastGoals, padding: padding),
          ],
        ),
      ),
      floatingActionButton: goal.activeGoal == null
          ? AppFAB.extended(
              icon: Icons.add,
              label: 'Create Goal',
              isLoading: loading,
              onPressed: _navigateToGoal,
            )
          : null,
    );
  }
}

class _GoalDetails extends StatelessWidget {
  final Goal? goal;
  const _GoalDetails({required this.goal});

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return const EmptyStateWidget(
        title: 'No active goal',
        message: 'No active goal. Create one to get started!',
        icon: Icons.flag_outlined,
      );
    }
    return GoalDetails(goal: goal!);
  }
}

class _GoalList extends StatelessWidget {
  const _GoalList({required this.goals, required this.padding});

  final List<Goal> goals;
  final double padding;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const EmptyStateWidget(
        title: 'No completed goals yet',
        message: 'No completed goals yet.',
        icon: Icons.emoji_events_outlined,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: goals.length,
      itemBuilder: (_, i) {
        final goal = goals[i];
        return AppAnimations.staggeredListItem(
          index: i,
          child: GoalCard(
            goal: goal,
            onTap: () => context.push('/goals/${goal.id}'),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
