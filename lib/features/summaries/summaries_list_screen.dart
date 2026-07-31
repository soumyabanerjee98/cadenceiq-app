import 'package:cadenceiq/models/goal.dart';
import 'package:cadenceiq/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/widgets/state_widgets.dart';
import 'package:cadenceiq/core/widgets/summary_card.dart';

class SummariesListScreen extends StatefulWidget {
  const SummariesListScreen({super.key});

  @override
  State<SummariesListScreen> createState() => _SummariesListScreenState();
}

class _SummariesListScreenState extends State<SummariesListScreen> {
  late GoalProvider goal;

  @override
  void initState() {
    goal = context.read<GoalProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    goal = context.watch<GoalProvider>();
    final pastGoals = goal.pastGoals;
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 16, padding, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Summaries',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your completed training blocks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (pastGoals.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateWidget(
                title: 'No summaries yet',
                message: 'Complete a training goal to see your summary here.',
                icon: Icons.emoji_events_outlined,
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final Goal summary = pastGoals[i];
                  return SummaryCard(
                    summary: summary,
                    onTap: () => context.push('/summaries/${summary.id}'),
                  );
                }, childCount: pastGoals.length),
              ),
            ),
        ],
      ),
    );
  }
}
