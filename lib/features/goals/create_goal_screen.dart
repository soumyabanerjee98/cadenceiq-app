import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:cadenceiq_app/core/utils/responsive.dart';
import 'package:cadenceiq_app/core/widgets/cadence_app_bar.dart';
import 'package:cadenceiq_app/core/widgets/primary_button.dart';
import 'package:cadenceiq_app/core/widgets/safe_page.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/providers/goal_provider.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));
  ExperienceLevel _level = ExperienceLevel.intermediate;
  final _requestController = TextEditingController();

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generate() async {
    if (_requestController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your training goal')),
      );
      return;
    }

    final provider = context.read<GoalProvider>();
    final goal = await provider.createGoal(
      startDate: _startDate,
      endDate: _endDate,
      level: _level,
      request: _requestController.text.trim(),
    );

    if (!mounted) return;
    if (goal != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Training plan generated!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: const CadenceAppBar(showBack: true, title: 'Create Goal'),
      body: SafePage(
        child: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          Text(
            'Tell us about your goal and our AI coach will build a personalized training plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
              labelText: 'Describe your goal',
              hintText:
                  'e.g. Prepare for a 160km gran fondo in June with focus on climbing and endurance...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Generate Training Plan',
            icon: Icons.auto_awesome,
            isLoading: provider.isGenerating,
            onPressed: _generate,
          ),
        ],
        ),
      ),
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
