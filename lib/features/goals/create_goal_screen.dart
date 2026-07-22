import 'package:cadenceiq_app/core/utils/snackbar.dart';
import 'package:cadenceiq_app/core/widgets/ai_action_button.dart';
import 'package:cadenceiq_app/core/widgets/plan_insight_card.dart';
import 'package:cadenceiq_app/core/widgets/text_form_field.dart';
import 'package:cadenceiq_app/core/widgets/training_calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/providers/goal_provider.dart';

class CreateGoalScreenArgs {
  const CreateGoalScreenArgs({required this.experienceLevel});
  final ExperienceLevel experienceLevel;
}

class CreateGoalScreen extends StatefulWidget {
  final CreateGoalScreenArgs args;
  const CreateGoalScreen({super.key, required this.args});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen>
    with TickerProviderStateMixin {
  late GoalProvider provider;
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  ExperienceLevel _level = ExperienceLevel.beginner;
  String _request = '';
  final PageController _controller = PageController();
  int currentPage = 0;
  late final AnimationController _lottieController;

  @override
  void initState() {
    provider = context.read<GoalProvider>();
    _lottieController = AnimationController(vsync: this);
    setState(() {
      _level = widget.args.experienceLevel;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final int monthGap = 1;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (isStart) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _startDate.isBefore(todayOnly) ? todayOnly : _startDate,
        firstDate: todayOnly,
        lastDate: DateTime(
          todayOnly.year,
          todayOnly.month + monthGap,
          todayOnly.day,
        ),
      );

      if (picked == null) return;

      setState(() {
        _startDate = picked;

        final minEnd = _startDate.add(const Duration(days: 7));
        final maxEnd = DateTime(
          _startDate.year,
          _startDate.month + monthGap,
          _startDate.day,
        );

        if (_endDate.isBefore(minEnd)) {
          _endDate = minEnd;
        } else if (_endDate.isAfter(maxEnd)) {
          _endDate = maxEnd;
        }
      });
    } else {
      final minEnd = _startDate.add(const Duration(days: 7));
      final maxEnd = DateTime(
        _startDate.year,
        _startDate.month + monthGap,
        _startDate.day,
      );

      final picked = await showDatePicker(
        context: context,
        initialDate: _endDate.isBefore(minEnd) ? minEnd : _endDate,
        firstDate: minEnd,
        lastDate: maxEnd,
      );

      if (picked == null) return;

      setState(() {
        _endDate = picked;
      });
    }
  }

  void _action() {
    switch (currentPage) {
      case 0:
        _buildPlan();
        break;
      case 1:
        _generatePlan();
        break;
      default:
    }
  }

  void _nextPage() {
    setState(() {
      _controller.nextPage(
        duration: Durations.medium4,
        curve: Curves.decelerate,
      );
    });
  }

  void _previousPage() {
    provider.prepareNewGoal();
    setState(() {
      _controller.previousPage(
        duration: Durations.medium4,
        curve: Curves.decelerate,
      );
    });
  }

  Future<void> _buildPlan() async {
    if (!_formKey.currentState!.validate()) return;
    final res = await provider.buildPlan(
      startDate: _startDate,
      endDate: _endDate,
      level: _level,
      request: _request,
    );
    if (res.response != null) {
      _nextPage();
    } else {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: res.error?.errorMessage ?? "Something went wrong!",
        status: SnackbarStatus.error,
      );
    }
  }

  Future<void> _generatePlan() async {}

  @override
  Widget build(BuildContext context) {
    provider = context.watch<GoalProvider>();

    return Scaffold(
      appBar: const CadenceAppBar(showBack: true, title: 'Create Goal'),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: PrimaryButton(
          label: currentPage == 0 ? 'Generate Training Plan' : 'Set Goal',
          ai: currentPage == 0,
          shine: currentPage == 0,
          isLoading: provider.isGenerating,
          onPressed: _action,
        ),
      ),
      body: SafePage(
        child: PageView(
          controller: _controller,
          onPageChanged: (value) {
            setState(() {
              currentPage = value;
            });
          },
          physics: NeverScrollableScrollPhysics(),
          children: [_buildPlanPage(), _buildCalendarPage()],
        ),
      ),
    );
  }

  Widget _buildPlanPage() {
    final padding = Responsive.horizontalPadding(context);
    final TextStyle? normal = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.5,
    );
    final TextStyle? highlight = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(
          color: AppColors.primary,
          height: 1.5,
          fontWeight: FontWeight.w600,
        );
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        Text.rich(
          TextSpan(
            text: "Tell us about your goal and our ",
            children: [
              TextSpan(text: "AI coach ", style: highlight),
              TextSpan(text: "will build a "),
              TextSpan(text: "personalized ", style: highlight),
              TextSpan(text: "training plan."),
            ],
          ),
          style: normal,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: "We will collect ",
            children: [
              TextSpan(text: "30 days ", style: highlight),
              TextSpan(text: "of your "),
              TextSpan(text: "Strava ", style: highlight),
              TextSpan(text: "history and generate a "),
              TextSpan(text: "tailored plan ", style: highlight),
              TextSpan(text: "suitable for you."),
            ],
          ),
          style: normal,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: "Your ",
            children: [
              TextSpan(text: "minimum ", style: highlight),
              TextSpan(text: "and "),
              TextSpan(text: "maximum ", style: highlight),
              TextSpan(text: "training range will be "),
              TextSpan(text: "7 days ", style: highlight),
              TextSpan(text: "and "),
              TextSpan(text: "1 month ", style: highlight),
              TextSpan(text: "respectively."),
            ],
          ),
          style: normal,
        ),
        const SizedBox(height: 24),
        Text(
          'Describe your goal',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Tell us about your goal, briefly explain what you want to achieve',
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Form(
          key: _formKey,
          child: CustomTextFormField(
            label: "Describe your goal",
            hintText:
                'e.g. Prepare for a 160km gran fondo in June with focus on climbing and endurance...',
            initialValue: _request,
            maxLines: 5,
            onChanged: (value) {
              setState(() {
                _request = value;
              });
            },
            validator: (v) => v == null || v.isEmpty ? 'Enter a goal' : null,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Select a range',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Select start date and end date of your goal',
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _DateField(
          label: 'Start Date',
          date: _startDate,
          onTap: () => _pickDate(true),
        ),
        const SizedBox(height: 16),
        _DateField(
          label: 'End Date',
          date: _endDate,
          onTap: () => _pickDate(false),
        ),
        const SizedBox(height: 24),
        Text(
          'Experience Level',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'This is based on your Strava history',
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          _levelLabel(_level),
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildCalendarPage() {
    provider = context.watch<GoalProvider>();
    final padding = Responsive.horizontalPadding(context);
    final TextStyle? normal = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.5,
    );
    final TextStyle? highlight = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(
          color: AppColors.primary,
          height: 1.5,
          fontWeight: FontWeight.w600,
        );
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        Text.rich(
          TextSpan(
            text: "Here is your ",
            children: [
              TextSpan(text: "tailored plan ", style: highlight),
              TextSpan(
                text:
                    "for selected range. If you want to rebuild the plan, press ",
              ),
              TextSpan(text: "\"Rebuild Plan\" ", style: highlight),
              TextSpan(text: "below."),
            ],
          ),
          style: normal,
        ),
        const SizedBox(height: 24),
        if (provider.target != null) ...[
          TrainingCalendar(
            plans: provider.target!.plan,
            onRebuild: () => _previousPage(),
          ),
          const SizedBox(height: 18),
        ],
        Row(
          spacing: 8,
          children: [
            Icon(Icons.lightbulb_circle_outlined, color: AppColors.warning),
            Text("Tap on the events to view details"),
          ],
        ),
        const SizedBox(height: 24),
        if (provider.insight != null)
          PlanInsightCard(insight: provider.insight!)
        else
          Row(
            children: [
              AiActionButton(
                loading: provider.isPlanInsightLoading,
                onPressed: provider.buildPlanInsight,
                label: "Generate AI Insight",
              ),
            ],
          ),
      ],
    );
  }

  String _levelLabel(ExperienceLevel level) => switch (level) {
    ExperienceLevel.beginner => 'Beginner',
    ExperienceLevel.intermediate => 'Intermediate',
    ExperienceLevel.advanced => 'Advanced',
    ExperienceLevel.elite => 'Elite',
  };
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${date.month}/${date.day}/${date.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
