import 'package:cadenceiq/core/constants/route_paths.dart';
import 'package:cadenceiq/core/validation/goal_form_validation.dart';
import 'package:cadenceiq/core/utils/snackbar.dart';
import 'package:cadenceiq/core/widgets/ai_action_button.dart';
import 'package:cadenceiq/core/widgets/plan_insight_card.dart';
import 'package:cadenceiq/core/widgets/text_form_field.dart';
import 'package:cadenceiq/core/widgets/training_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/responsive.dart';
import 'package:cadenceiq/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq/core/widgets/primary_button.dart';
import 'package:cadenceiq/core/widgets/safe_page.dart';
import 'package:cadenceiq/models/goal.dart';
import 'package:cadenceiq/providers/goal_provider.dart';

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
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime? _startDate;
  DateTime? _endDate;
  ExperienceLevel _level = ExperienceLevel.beginner;
  String _notes = '';
  TrainingGoal? _goal;
  int? _maxTrainingDays;
  int? _maxWeeklyDistance;
  int? _maxWeeklyDuration;
  Weekday? _preferredLongRideDay;
  final Set<Weekday> _preferredTrainingDays = {};
  final Set<PlanType> _preferredSessionTypes = {};
  final PageController _controller = PageController();
  int currentPage = 0;

  static const int _maxPlanMonths = 6;
  static const int _maxStartMonthsAhead = 12;

  DateTime _todayOnly() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day);
  }

  @override
  void initState() {
    provider = context.read<GoalProvider>();
    _level = widget.args.experienceLevel;
    _startDate = _todayOnly();
    _endDate = _todayOnly().add(const Duration(days: 6));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  Future<void> _pickDate(bool isStart) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (isStart) {
      final initial = _startDate ?? todayOnly;
      final picked = await showDatePicker(
        context: context,
        initialDate: initial.isBefore(todayOnly) ? todayOnly : initial,
        firstDate: todayOnly,
        lastDate: _addMonths(todayOnly, _maxStartMonthsAhead),
      );

      if (picked == null) return;

      setState(() {
        _startDate = picked;
      });
    } else {
      if (_startDate == null) {
        AppSnackbar.show(
          context,
          message: 'Select a start date first',
          status: SnackbarStatus.error,
        );
        return;
      }

      final minEnd = _startDate!.add(const Duration(days: 1));
      final maxEnd = _addMonths(_startDate!, _maxPlanMonths);
      final initial = _endDate ?? minEnd;

      final picked = await showDatePicker(
        context: context,
        initialDate: initial.isBefore(minEnd) ? minEnd : initial,
        firstDate: minEnd,
        lastDate: maxEnd,
      );

      if (picked == null) return;

      setState(() {
        _endDate = picked;
      });
    }
  }

  String? _validatePlanPreferences() {
    return GoalFormValidation.validateBuildPlan(
      title: _title,
      startDate: _startDate,
      endDate: _endDate,
      goal: _goal,
      maxTrainingDays: _maxTrainingDays,
      maxWeeklyDistance: _maxWeeklyDistance,
      maxWeeklyDuration: _maxWeeklyDuration,
      preferredLongRideDay: _preferredLongRideDay,
      preferredTrainingDays: _preferredTrainingDays,
      preferredSessionTypes: _preferredSessionTypes,
    );
  }

  void _toggleTrainingDay(Weekday day) {
    setState(() {
      if (_preferredTrainingDays.contains(day)) {
        _preferredTrainingDays.remove(day);
        if (_preferredLongRideDay == day) {
          _preferredLongRideDay = null;
        }
      } else if (_preferredTrainingDays.length <
          GoalFormValidation.maxPreferredTrainingDays) {
        _preferredTrainingDays.add(day);
      }
    });
  }

  void _toggleSessionType(PlanType type) {
    setState(() {
      if (_preferredSessionTypes.contains(type)) {
        _preferredSessionTypes.remove(type);
      } else {
        _preferredSessionTypes.add(type);
      }
    });
  }

  void _action() {
    switch (currentPage) {
      case 0:
        _buildPlan();
        break;
      case 1:
        _createGoal();
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
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final preferenceError = _validatePlanPreferences();
    if (preferenceError != null) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: GoalFormValidation.humanizeMessage(preferenceError),
        status: SnackbarStatus.error,
      );
      return;
    }

    final startDate = _startDate;
    final endDate = _endDate;
    final goal = _goal;
    if (startDate == null || endDate == null || goal == null) {
      return;
    }

    final res = await provider.buildPlan(
      startDate: startDate,
      endDate: endDate,
      level: _level,
      goal: goal,
      maxTrainingDays: _maxTrainingDays,
      maxWeeklyDistance: _maxWeeklyDistance,
      maxWeeklyDuration: _maxWeeklyDuration,
      preferredLongRideDay: _preferredLongRideDay,
      preferredTrainingDays: kDayOfWeekValues
          .where(_preferredTrainingDays.contains)
          .toList(),
      preferredSessionTypes: _preferredSessionTypes.toList(),
      notes: _notes,
    );
    if (res) {
      _nextPage();
    } else {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: GoalFormValidation.humanizeMessage(
          provider.errorMessage ?? "Something went wrong!",
        ),
        status: SnackbarStatus.error,
      );
    }
  }

  Future<void> _generateInsight() async {
    final res = await provider.buildPlanInsight();
    if (res) {
      _nextPage();
    } else {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: GoalFormValidation.humanizeMessage(
          provider.errorMessage ?? "Something went wrong!",
        ),
        status: SnackbarStatus.error,
      );
    }
  }

  Future<void> _createGoal() async {
    final titleError = GoalFormValidation.validateTitle(_title);
    if (titleError != null) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: titleError,
        status: SnackbarStatus.error,
      );
      return;
    }
    final res = await provider.createGoal(
      startDate: _startDate!,
      endDate: _endDate!,
      level: _level,
      request: _notes,
      title: _title,
    );
    if (res) {
      if (!mounted) return;
      context.go(RoutePaths.goals);
    } else {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: GoalFormValidation.humanizeMessage(
          provider.errorMessage ?? "Something went wrong!",
        ),
        status: SnackbarStatus.error,
      );
    }
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
          physics: const NeverScrollableScrollPhysics(),
          children: [_buildPlanPage(), _buildCalendarPage()],
        ),
      ),
    );
  }

  Widget _buildPlanPage() {
    final padding = Responsive.horizontalPadding(context);
    final TextStyle? normal = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondaryOf(context),
      height: 1.5,
    );
    final TextStyle? highlight = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(
          color: AppColors.primary,
          height: 1.5,
          fontWeight: FontWeight.w600,
        );
    return Form(
      key: _formKey,
      child: ListView(
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
            text: "End date must be ",
            children: [
              TextSpan(text: "after ", style: highlight),
              TextSpan(text: "start date (up to "),
              TextSpan(text: "$_maxPlanMonths months ", style: highlight),
              TextSpan(text: "apart)."),
            ],
          ),
          style: normal,
        ),
        const SizedBox(height: 24),
        CustomTextFormField(
          label: "Title of goal",
          hintText: 'e.g. Gran Fondo 2026',
          initialValue: _title,
          onChanged: (value) {
            setState(() {
              _title = value;
            });
          },
          validator: (v) => GoalFormValidation.validateTitle(v),
        ),
        CustomTextFormField(
          label: "Notes (optional)",
          hintText: 'Any extra context for your coach...',
          initialValue: _notes,
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
        ),
        const SizedBox(height: 8),
        _sectionHeader(
          context,
          title: 'Goal type',
          subtitle: 'Required · what are you training for?',
        ),
        const SizedBox(height: 8),
        _sectionHeader(
          context,
          title: 'Event preparation',
          subtitle: 'Race and event-focused goals',
          compact: true,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kEventPrepGoals.map((g) => _goalChip(g)).toList(),
        ),
        const SizedBox(height: 12),
        _sectionHeader(
          context,
          title: 'Other goals',
          compact: true,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kGoalTypeValues
              .where((g) => !kEventPrepGoals.contains(g))
              .map((g) => _goalChip(g))
              .toList(),
        ),
        const SizedBox(height: 16),
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
        _sectionHeader(
          context,
          title: 'Experience Level',
          subtitle: 'This is based on your Strava history',
        ),
        const SizedBox(height: 8),
        Text(
          _levelLabel(_level),
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        _sectionHeader(
          context,
          title: 'Weekly limits',
          subtitle: 'Optional caps used when building your plan',
        ),
        const SizedBox(height: 8),
        _sectionHeader(
          context,
          title: 'Max training days per week',
          subtitle: 'Optional · 1–${GoalFormValidation.maxTrainingDaysCap}',
          compact: true,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(GoalFormValidation.maxTrainingDaysCap, (i) {
            final days = i + 1;
            return _SelectChip(
              label: '$days',
              selected: _maxTrainingDays == days,
              onTap: () {
                setState(() {
                  _maxTrainingDays = _maxTrainingDays == days ? null : days;
                });
              },
            );
          }),
        ),
        CustomTextFormField(
          label: 'Max weekly distance (km)',
          hintText: 'e.g. 200',
          initialValue: '',
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              if (value.trim().isEmpty) {
                _maxWeeklyDistance = null;
              } else {
                _maxWeeklyDistance = int.tryParse(value.trim());
              }
            });
          },
          validator: GoalFormValidation.validateOptionalPositiveInt,
        ),
        CustomTextFormField(
          label: 'Max weekly duration (hours)',
          hintText: 'e.g. 10',
          initialValue: '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            setState(() {
              if (value.trim().isEmpty) {
                _maxWeeklyDuration = null;
              } else {
                _maxWeeklyDuration =
                    GoalFormValidation.hoursToWeeklyDurationMinutes(value);
              }
            });
          },
          validator: GoalFormValidation.validateOptionalPositiveHours,
        ),
        const SizedBox(height: 16),
        _sectionHeader(
          context,
          title: 'Preferred training days',
          subtitle:
              'Required · 1–${GoalFormValidation.maxPreferredTrainingDays} days '
              '(${_preferredTrainingDays.length}/${GoalFormValidation.maxPreferredTrainingDays})',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kDayOfWeekValues.map((day) {
            final selected = _preferredTrainingDays.contains(day);
            final atCap = !selected &&
                _preferredTrainingDays.length >=
                    GoalFormValidation.maxPreferredTrainingDays;
            return _SelectChip(
              label: day.label,
              selected: selected,
              onTap: atCap ? null : () => _toggleTrainingDay(day),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _sectionHeader(
          context,
          title: 'Preferred long ride day',
          subtitle:
              'Optional · must be one of your preferred training days',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kDayOfWeekValues.map((day) {
            return _SelectChip(
              label: day.label,
              selected: _preferredLongRideDay == day,
              onTap: () => setState(() {
                _preferredLongRideDay =
                    _preferredLongRideDay == day ? null : day;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _sectionHeader(
          context,
          title: 'Preferred session types',
          subtitle: 'Required · select at least one workout style',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kSessionTypeValues.map((type) {
            return _SelectChip(
              label: _sessionTypeLabel(type),
              selected: _preferredSessionTypes.contains(type),
              onTap: () => _toggleSessionType(type),
            );
          }).toList(),
        ),
        ],
      ),
    );
  }

  Widget _goalChip(TrainingGoal g) {
    return _SelectChip(
      label: g.label,
      selected: _goal == g,
      onTap: () => setState(() => _goal = g),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
    bool compact = false,
  }) {
    final titleStyle = compact
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          )
        : Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ],
      ],
    );
  }

  String _sessionTypeLabel(PlanType type) => switch (type) {
    PlanType.rest => 'Rest',
    PlanType.recovery => 'Recovery',
    PlanType.easy => 'Easy',
    PlanType.endurance => 'Endurance',
    PlanType.tempo => 'Tempo',
    PlanType.threshold => 'Threshold',
    PlanType.vo2 => 'VO2',
    PlanType.sprint => 'Sprint',
    PlanType.long => 'Long',
  };

  Widget _buildCalendarPage() {
    provider = context.watch<GoalProvider>();
    final padding = Responsive.horizontalPadding(context);
    final TextStyle? normal = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondaryOf(context),
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
                onPressed: _generateInsight,
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

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
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
          date == null
              ? 'Select date'
              : '${date!.month}/${date!.day}/${date!.year}',
          style: TextStyle(
            fontSize: 16,
            color: date == null
                ? AppColors.textSecondaryOf(context)
                : null,
          ),
        ),
      ),
    );
  }
}
