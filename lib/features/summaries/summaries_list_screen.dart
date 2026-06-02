import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/state_widgets.dart';
import 'package:cadenceiq_app/core/widgets/summary_card.dart';
import 'package:cadenceiq_app/providers/summary_provider.dart';

class SummariesListScreen extends StatelessWidget {
  const SummariesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summaries = context.watch<SummaryProvider>().summaries;
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
          if (summaries.isEmpty)
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
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final summary = summaries[i];
                    return SummaryCard(
                      summary: summary,
                      onTap: () => context.push('/summaries/${summary.id}'),
                    );
                  },
                  childCount: summaries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
