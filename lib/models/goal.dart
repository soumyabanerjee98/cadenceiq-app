enum ExperienceLevel { beginner, intermediate, advanced, elite }

enum GoalStatus { active, completed, upcoming }

class PlannedSession {
  const PlannedSession({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.targetLoad,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final double targetLoad;
  final bool isCompleted;
}

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.experienceLevel,
    required this.currentLoad,
    required this.targetLoad,
    required this.adjustedLoad,
    required this.progress,
    required this.status,
    this.description = '',
    this.goalRequest = '',
    this.plannedSessions = const [],
  });

  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final ExperienceLevel experienceLevel;
  final double currentLoad;
  final double targetLoad;
  final double adjustedLoad;
  final double progress;
  final GoalStatus status;
  final String description;
  final String goalRequest;
  final List<PlannedSession> plannedSessions;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays.clamp(0, 999);

  String get experienceLabel => switch (experienceLevel) {
        ExperienceLevel.beginner => 'Beginner',
        ExperienceLevel.intermediate => 'Intermediate',
        ExperienceLevel.advanced => 'Advanced',
        ExperienceLevel.elite => 'Elite',
      };
}
