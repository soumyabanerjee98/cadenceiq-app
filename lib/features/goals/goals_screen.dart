import 'package:cadenceiq_app/core/utils/snackbar.dart';
import 'package:cadenceiq_app/core/widgets/floating_action_button.dart';
import 'package:cadenceiq_app/features/goals/create_goal_screen.dart';
import 'package:cadenceiq_app/features/goals/goal_detail_screen.dart';
import 'package:cadenceiq_app/services/repo/activity_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/constants/route_paths.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/goal_card.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/providers/goal_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 16, padding, 0),
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
            _GoalDetails(
              goal: provider.activeGoal,
              emptyMessage: 'No active goal. Create one to get started!',
            ),
            _GoalList(
              goals: provider.pastGoals,
              emptyMessage: 'No completed goals yet.',
              padding: padding,
            ),
          ],
        ),
      ),
      floatingActionButton: provider.activeGoal == null
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
  final String emptyMessage;
  const _GoalDetails({required this.goal, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return Center(child: Text(emptyMessage, textAlign: TextAlign.center));
    }
    return GoalDetails(goal: goal!);
  }
}

class _GoalList extends StatelessWidget {
  const _GoalList({
    required this.goals,
    required this.emptyMessage,
    required this.padding,
  });

  final List<Goal> goals;
  final String emptyMessage;
  final double padding;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(child: Text(emptyMessage, textAlign: TextAlign.center));
    }
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: goals.length,
      itemBuilder: (_, i) {
        final goal = goals[i];
        return GoalCard(
          goal: goal,
          onTap: () => context.push('/goals/${goal.id}'),
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
