import 'package:cadenceiq/models/goal.dart';

/// Client-side validation aligned with backend `goalSchema`.
class GoalFormValidation {
  static const int maxPreferredTrainingDays = 6;
  static const int maxTrainingDaysCap = 6;

  static const Map<String, String> _fieldLabels = {
    'startDate': 'Start date',
    'endDate': 'End date',
    'experienceLevel': 'Experience level',
    'goal': 'Goal type',
    'maxTrainingDays': 'Max training days',
    'maxWeeklyDistance': 'Max weekly distance',
    'maxWeeklyDuration': 'Max weekly duration',
    'preferredLongRideDay': 'Long ride day',
    'preferredTrainingDays': 'Preferred training days',
    'preferredSessionTypes': 'Preferred session types',
    'notes': 'Notes',
    'title': 'Title',
  };

  /// Rewrites API / schema field keys in error text for display.
  static String humanizeMessage(String message) {
    var result = message;
    for (final entry in _fieldLabels.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Enter a title';
    }
    return null;
  }

  static String? validateBuildPlan({
    required String title,
    required DateTime? startDate,
    required DateTime? endDate,
    required TrainingGoal? goal,
    required int? maxTrainingDays,
    required int? maxWeeklyDistance,
    required int? maxWeeklyDuration,
    required Weekday? preferredLongRideDay,
    required Iterable<Weekday> preferredTrainingDays,
    required Iterable<PlanType> preferredSessionTypes,
  }) {
    final titleError = validateTitle(title);
    if (titleError != null) {
      return titleError;
    }
    if (startDate == null) {
      return 'Select a start date';
    }
    if (endDate == null) {
      return 'Select an end date';
    }
    if (!_isAfter(endDate, startDate)) {
      return 'End date must be after start date';
    }
    if (goal == null) {
      return 'Select a goal type';
    }

    final trainingDays = preferredTrainingDays.toList();
    if (trainingDays.isEmpty) {
      return 'Select at least one preferred training day';
    }
    if (trainingDays.length > maxPreferredTrainingDays) {
      return 'Select at most $maxPreferredTrainingDays preferred training days';
    }
    if (trainingDays.map((d) => d.apiValue).toSet().length !=
        trainingDays.length) {
      return 'Preferred training days must be unique';
    }

    final sessionTypes = preferredSessionTypes.toList();
    if (sessionTypes.isEmpty) {
      return 'Select at least one preferred session type';
    }
    if (sessionTypes.map((t) => t.apiValue).toSet().length !=
        sessionTypes.length) {
      return 'Preferred session types must be unique';
    }

    if (preferredLongRideDay != null &&
        !trainingDays.contains(preferredLongRideDay)) {
      return 'Long ride day must be one of your preferred training days';
    }

    if (maxTrainingDays != null) {
      if (maxTrainingDays < 1 || maxTrainingDays > maxTrainingDaysCap) {
        return 'Max training days must be between 1 and $maxTrainingDaysCap';
      }
      if (maxTrainingDays > trainingDays.length) {
        return
            'Max training days cannot exceed the number of preferred training days';
      }
    }

    if (maxWeeklyDistance != null && maxWeeklyDistance <= 0) {
      return 'Max weekly distance must be a positive number';
    }
    if (maxWeeklyDuration != null && maxWeeklyDuration <= 0) {
      return 'Max weekly duration must be a positive number';
    }

    return null;
  }

  static String? validateOptionalPositiveInt(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final n = int.tryParse(raw.trim());
    if (n == null || n <= 0) {
      return 'Must be a positive number';
    }
    return null;
  }

  static String? validateOptionalPositiveHours(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final hours = double.tryParse(raw.trim());
    if (hours == null || hours <= 0) {
      return 'Must be a positive number of hours';
    }
    return null;
  }

  /// Converts UI hours to API minutes (rounded).
  static int? hoursToWeeklyDurationMinutes(String raw) {
    final hours = double.tryParse(raw.trim());
    if (hours == null || hours <= 0) return null;
    return (hours * 60).round();
  }

  static bool _isAfter(DateTime end, DateTime start) {
    final endOnly = DateTime(end.year, end.month, end.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    return endOnly.isAfter(startOnly);
  }
}
