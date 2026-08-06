import 'package:cadenceiq/core/widgets/ai_action_button.dart';
import 'package:cadenceiq/core/widgets/ai_insight_card.dart';
import 'package:cadenceiq/core/widgets/loading.dart';
import 'package:cadenceiq/models/goal.dart';
import 'package:cadenceiq/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/formatters.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq/core/widgets/metric_card.dart';
import 'package:cadenceiq/models/goal_summary.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';

class SummaryDetailScreen extends StatefulWidget {
  const SummaryDetailScreen({super.key, required this.summaryId});

  final String summaryId;

  @override
  State<SummaryDetailScreen> createState() => _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends State<SummaryDetailScreen> {
  late GoalProvider goal;
  bool isLoading = false;
  bool isAILoading = false;
  GoalSummary? summary;

  Future<void> getSummary({bool softLoad = false}) async {
    if (!softLoad) {
      setState(() {
        isLoading = true;
      });
    }
    final GoalSummary? res = await goal.getSummary(widget.summaryId);
    if (!mounted) return;
    setState(() {
      summary = res;
      isLoading = false;
    });
  }

  Future<void> getAISummary() async {
    setState(() {
      isAILoading = true;
    });
    final bool res = await goal.getAISummary(summary!.id);
    if (!mounted) return;
    setState(() {
      isAILoading = false;
    });
    if (res) {
      getSummary(softLoad: true);
    } else {
      AppSnackbar.show(
        context,
        message: goal.errorMessage ?? 'Failed to generate AI summary.',
        status: SnackbarStatus.error,
      );
    }
  }

  @override
  void initState() {
    goal = context.read<GoalProvider>();
    getSummary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    goal = context.watch<GoalProvider>();

    return Scaffold(
      appBar: CadenceAppBar(showBack: true, title: 'Summary'),
      body: SafePage(
        child: isLoading
            ? AppLoading()
            : summary == null
            ? Center(child: Text('Summary not found'))
            : ListView(
                padding: EdgeInsets.all(padding),
                children: [
                  _OverviewHeader(summary: summary!),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Completion',
                          value: Formatters.percent(summary!.goal.completion),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          label: 'Sessions',
                          value:
                              '${summary!.goal.plans.where((t) => t.completed || t.type == PlanType.rest).length}/${summary!.goal.plans.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Training Load',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _CompareRow(
                            label: 'Planned Load',
                            value: Formatters.load(summary!.plannedLoad),
                          ),
                          const Divider(height: 24),
                          _CompareRow(
                            label: 'Actual Load',
                            value: Formatters.load(summary!.actualLoad),
                            highlight: true,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${((summary!.actualLoad / summary!.plannedLoad) * 100).round()}% of planned volume',
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fitness Progression',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _CtlStat(
                            label: 'Start CTL',
                            value: summary!.goal.initialFitness.toDouble(),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppColors.primary,
                          ),
                          _CtlStat(
                            label: 'End CTL',
                            value: summary!.goal.fitness.toDouble(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (summary!.aiSummary!.isEmpty)
                    Row(
                      children: [
                        AiActionButton(
                          label: "Generate AI Summary",
                          loading: isAILoading,
                          onPressed: getAISummary,
                        ),
                      ],
                    )
                  else
                    AiInsightCard(
                      title: "AI Summary",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary!.aiSummary!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Positives",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...summary!.aiRecommendations!.map(
                            (recommendation) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.thumb_up_alt_outlined,
                                      size: 18,
                                      color: AppColors.success,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      recommendation,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Issues",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...summary!.aiIssues!.map(
                            (recommendation) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.thumb_down_alt_outlined,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      recommendation,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Current State",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            summary!.aiCurrentState!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Recommendations",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ai,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...summary!.aiRecommendations!.map(
                            (recommendation) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 18,
                                      color: AppColors.ai,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      recommendation,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 36),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.summary});
  final GoalSummary summary;

  IconData get _icon {
    if (summary.goal.isCompleted) return Icons.check;
    return Icons.close;
  }

  Color get _color {
    if (summary.goal.isCompleted) return AppColors.success;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color.withOpacity(0.15), _color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: _color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.goal.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${Formatters.date(summary.goal.startDate)} – ${Formatters.date(summary.goal.endDate)}',
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(summary.goal.experienceLabel),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: highlight ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}

class _CtlStat extends StatelessWidget {
  const _CtlStat({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 12),
        ),
      ],
    );
  }
}
