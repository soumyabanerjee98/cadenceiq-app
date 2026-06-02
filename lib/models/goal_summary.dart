class AchievementBadge {
  const AchievementBadge({
    required this.title,
    required this.description,
    required this.iconName,
  });

  final String title;
  final String description;
  final String iconName;
}

class GoalSummary {
  const GoalSummary({
    required this.id,
    required this.goalTitle,
    required this.startDate,
    required this.endDate,
    required this.completionPercent,
    required this.plannedLoad,
    required this.actualLoad,
    required this.plannedSessions,
    required this.completedSessions,
    required this.ctlStart,
    required this.ctlEnd,
    required this.insights,
    required this.badges,
    required this.experienceLevel,
  });

  final String id;
  final String goalTitle;
  final DateTime startDate;
  final DateTime endDate;
  final double completionPercent;
  final double plannedLoad;
  final double actualLoad;
  final int plannedSessions;
  final int completedSessions;
  final double ctlStart;
  final double ctlEnd;
  final List<String> insights;
  final List<AchievementBadge> badges;
  final String experienceLevel;
}
