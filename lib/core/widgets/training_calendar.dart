import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Color _planColor(PlanType type) {
  switch (type) {
    case PlanType.rest:
      return Colors.grey;

    case PlanType.recovery:
      return Colors.teal;

    case PlanType.easy:
      return Colors.green;

    case PlanType.endurance:
      return Colors.blue;

    case PlanType.tempo:
      return Colors.orange;

    case PlanType.threshold:
      return Colors.deepOrange;

    case PlanType.vo2:
      return Colors.red;

    case PlanType.sprint:
      return Colors.purple;

    case PlanType.long:
      return AppColors.primary;
  }
}

class TrainingCalendarSource extends CalendarDataSource {
  TrainingCalendarSource(List<PrePlan> plans) {
    appointments = plans
        .map(
          (plan) => Appointment(
            id: plans.indexOf(plan),
            startTime: plan.date,
            endTime: plan.date.add(const Duration(hours: 1)),
            subject: plan.title,
            color: _planColor(plan.type),
            isAllDay: true,
            notes: plan.description,
          ),
        )
        .toList();
  }
}

enum CalendarMode { month, week }

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
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
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),

        const SizedBox(height: 8),

        Text(value, style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 4),

        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PlanBottomSheet extends StatelessWidget {
  const _PlanBottomSheet({required this.plan});

  final PrePlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _color(plan.type),
                    child: Icon(_icon(plan.type), color: Colors.white),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title, style: theme.textTheme.titleLarge),

                        const SizedBox(height: 4),

                        Text(
                          DateFormat("EEEE, dd MMMM").format(plan.date),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(plan.description, style: theme.textTheme.bodyLarge),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        icon: Icons.bolt,
                        title: "Load",
                        value: plan.targetLoad.toString(),
                      ),
                    ),

                    Expanded(
                      child: _Metric(
                        icon: Icons.route,
                        title: "Distance",
                        value: "${plan.targetDistance} km",
                      ),
                    ),

                    Expanded(
                      child: _Metric(
                        icon: Icons.schedule,
                        title: "Duration",
                        value: _format(plan.targetDuration),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text("Instructions", style: theme.textTheme.titleMedium),

              const SizedBox(height: 12),

              ...plan.instructions
                  .split('\n')
                  .where((e) => e.trim().isNotEmpty)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• "),

                          Expanded(child: Text(e)),
                        ],
                      ),
                    ),
                  ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(Duration d) {
    if (d.inHours == 0) {
      return "${d.inMinutes} min";
    }

    return "${d.inHours}h ${d.inMinutes.remainder(60)}m";
  }

  Color _color(PlanType type) {
    switch (type) {
      case PlanType.rest:
        return Colors.grey;
      case PlanType.recovery:
        return Colors.teal;
      case PlanType.easy:
        return Colors.green;
      case PlanType.endurance:
        return Colors.blue;
      case PlanType.tempo:
        return Colors.orange;
      case PlanType.threshold:
        return Colors.deepOrange;
      case PlanType.vo2:
        return Colors.red;
      case PlanType.sprint:
        return Colors.purple;
      case PlanType.long:
        return Colors.indigo;
    }
  }

  IconData _icon(PlanType type) {
    switch (type) {
      case PlanType.rest:
        return Icons.hotel;
      case PlanType.recovery:
        return Icons.favorite;
      case PlanType.easy:
        return Icons.directions_bike;
      case PlanType.endurance:
        return Icons.route;
      case PlanType.tempo:
        return Icons.speed;
      case PlanType.threshold:
        return Icons.local_fire_department;
      case PlanType.vo2:
        return Icons.monitor_heart;
      case PlanType.sprint:
        return Icons.flash_on;
      case PlanType.long:
        return Icons.landscape;
    }
  }
}

class TrainingCalendar extends StatefulWidget {
  final List<PrePlan> plans;
  const TrainingCalendar({super.key, required this.plans});

  @override
  State<TrainingCalendar> createState() => _TrainingCalendarState();
}

class _TrainingCalendarState extends State<TrainingCalendar> {
  final key = GlobalKey();
  final CalendarController _controller = CalendarController();

  Future<void> showPlanBottomSheet(BuildContext context, PrePlan plan) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PlanBottomSheet(plan: plan),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minDate = widget.plans.first.date;
    final maxDate = widget.plans.last.date;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 8,
          children: [
            _ChoiceChip(
              label: "Month",
              selected: _controller.view == CalendarView.month,
              onTap: () {
                setState(() {
                  _controller.view = CalendarView.month;
                });
              },
            ),
            _ChoiceChip(
              label: "Schedule",
              selected: _controller.view == CalendarView.schedule,
              onTap: () {
                setState(() {
                  _controller.view = CalendarView.schedule;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 12),
        SfCalendar(
          key: key,
          controller: _controller,
          minDate: minDate,
          maxDate: maxDate,
          dataSource: TrainingCalendarSource(widget.plans),

          headerHeight: 56,

          todayHighlightColor: Colors.transparent,
          todayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.normal,
          ),

          view: CalendarView.month,

          selectionDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),

          headerStyle: CalendarHeaderStyle(
            backgroundColor: AppColors.primary,
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),

          viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: Theme.of(context).textTheme.bodySmall!,
          ),

          monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
            showTrailingAndLeadingDates: false,
          ),
          scheduleViewSettings: ScheduleViewSettings(
            hideEmptyScheduleWeek: true,
            monthHeaderSettings: const MonthHeaderSettings(height: 0),
          ),

          appointmentBuilder: (context, details) {
            final appointment = details.appointments.first as Appointment;

            return Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

              decoration: BoxDecoration(
                color: appointment.color,
                borderRadius: BorderRadius.circular(6),
              ),

              child: Row(
                spacing: 6,
                children: [
                  Icon(Icons.directions_bike, size: 10, color: Colors.white),

                  Expanded(
                    child: Text(
                      appointment.subject,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },

          onTap: (p0) {
            final index = p0.appointments?.first.id;
            final PrePlan plan = widget.plans[index];
            showPlanBottomSheet(context, plan);
          },
        ),
      ],
    );
  }
}
