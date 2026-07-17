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

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  late GoalProvider provider;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  ExperienceLevel _level = ExperienceLevel.beginner;
  final _requestController = TextEditingController();
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    provider = context.read<GoalProvider>();
    setState(() {
      _level = widget.args.experienceLevel;
    });
    super.initState();
  }

  @override
  void dispose() {
    _requestController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (isStart) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _startDate.isBefore(todayOnly) ? todayOnly : _startDate,
        firstDate: todayOnly,
        lastDate: DateTime(todayOnly.year, todayOnly.month + 6, todayOnly.day),
      );

      if (picked == null) return;

      setState(() {
        _startDate = picked;

        final minEnd = _startDate.add(const Duration(days: 7));
        final maxEnd = DateTime(
          _startDate.year,
          _startDate.month + 6,
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
        _startDate.month + 6,
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
    setState(() {
      _controller.previousPage(
        duration: Durations.medium4,
        curve: Curves.decelerate,
      );
    });
  }

  Future<void> _buildPlan() async {
    await provider.buildPlan(
      startDate: _startDate,
      endDate: _endDate,
      level: _level,
      request: _requestController.text,
    );
    _nextPage();
  }

  Future<void> _generatePlan() async {
    Map<String, String> payload = {
      "startDate": _startDate.toIso8601String().split("T")[0],
      "endDate": _endDate.toIso8601String().split("T")[0],
      "experienceLevel": _level.name,
    };
    if (_requestController.text.isNotEmpty) {
      payload.addAll({"customGoalRequirements": _requestController.text});
    }
    print(payload);
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<GoalProvider>();

    return Scaffold(
      appBar: const CadenceAppBar(showBack: true, title: 'Create Goal'),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: PrimaryButton(
          label: currentPage == 0 ? 'Generate Training Plan' : 'Set Goal',
          icon: currentPage == 0 ? Icons.auto_awesome : null,
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
              TextSpan(text: "6 months ", style: highlight),
              TextSpan(text: "respectively."),
            ],
          ),
          style: normal,
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
        ...ExperienceLevel.values.map((level) {
          return RadioListTile<ExperienceLevel>(
            title: Text(_levelLabel(level)),
            value: level,
            groupValue: _level,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _level = v!),
            contentPadding: EdgeInsets.zero,
          );
        }),
        const SizedBox(height: 16),
        TextFormField(
          controller: _requestController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Describe your goal (Optional)',
            hintText:
                'e.g. Prepare for a 160km gran fondo in June with focus on climbing and endurance...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarPage() {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: _previousPage, child: Text("Rebuild Plan")),
          ],
        ),
      ],
    );
  }

  String _levelLabel(ExperienceLevel level) => switch (level) {
    ExperienceLevel.beginner => 'Beginner (< 1 year)',
    ExperienceLevel.intermediate => 'Intermediate (1-3 years)',
    ExperienceLevel.advanced => 'Advanced (3-5 years)',
    ExperienceLevel.elite => 'Elite (5+ years)',
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
