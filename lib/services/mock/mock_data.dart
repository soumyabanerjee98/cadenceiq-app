import 'package:cadenceiq_app/models/activity.dart';
import 'package:cadenceiq_app/models/goal.dart';
import 'package:cadenceiq_app/models/goal_summary.dart';
import 'package:cadenceiq_app/models/training_metrics.dart';

abstract final class MockData {
  static final metrics = TrainingMetrics(
    ctl: 72.4,
    atl: 58.1,
    tsb: 14.3,
    currentLoad: 420,
    targetLoad: 480,
    adjustedLoad: 445,
    weeklyLoads: [320, 380, 410, 395, 450, 420, 445, 460],
    zoneDistribution: {
      'Z1': 0.15,
      'Z2': 0.35,
      'Z3': 0.25,
      'Z4': 0.15,
      'Z5': 0.10,
    },
  );

  static const todaySession = TodaySession(
    title: 'Tempo Intervals',
    duration: Duration(hours: 1, minutes: 15),
    distanceKm: 32.0,
    targetLoad: 85,
    zone: 'Z3-Z4',
  );

  static final List<PlannedSession> _plannedSessions = List.generate(12, (i) {
    final date = DateTime.now().add(Duration(days: i * 2 - 4));
    return PlannedSession(
      id: 'session-$i',
      title: _sessionTitles[i % _sessionTitles.length],
      date: date,
      duration: Duration(minutes: 45 + (i * 10) % 60),
      targetLoad: 55.0 + (i * 7) % 40,
      isCompleted: i < 5,
    );
  });

  static const _sessionTitles = [
    'Endurance Ride',
    'Sweet Spot',
    'Recovery Spin',
    'VO2 Intervals',
    'Long Ride',
    'Hill Repeats',
  ];

  static final activeGoal = Goal(
    id: 'goal-active-1',
    title: 'Gran Fondo Preparation',
    startDate: DateTime(2026, 3, 1),
    endDate: DateTime(2026, 6, 15),
    experienceLevel: ExperienceLevel.intermediate,
    currentLoad: 420,
    targetLoad: 480,
    adjustedLoad: 445,
    progress: 0.62,
    status: GoalStatus.active,
    description:
        'Build endurance and climbing strength for a 160km gran fondo.',
    goalRequest:
        'Prepare for a hilly 160km gran fondo in June with focus on sustained power.',
    plannedSessions: _plannedSessions,
  );

  static final List<Goal> goals = [
    activeGoal,
    Goal(
      id: 'goal-active-2',
      title: 'FTP Builder',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 5, 30),
      experienceLevel: ExperienceLevel.advanced,
      currentLoad: 380,
      targetLoad: 420,
      adjustedLoad: 400,
      progress: 0.28,
      status: GoalStatus.active,
      description: 'Increase functional threshold power by 5%.',
    ),
    Goal(
      id: 'goal-past-1',
      title: 'Spring Century',
      startDate: DateTime(2025, 1, 15),
      endDate: DateTime(2025, 4, 20),
      experienceLevel: ExperienceLevel.intermediate,
      currentLoad: 450,
      targetLoad: 450,
      adjustedLoad: 448,
      progress: 1.0,
      status: GoalStatus.completed,
    ),
    Goal(
      id: 'goal-past-2',
      title: 'Winter Base Building',
      startDate: DateTime(2024, 11, 1),
      endDate: DateTime(2025, 2, 28),
      experienceLevel: ExperienceLevel.intermediate,
      currentLoad: 380,
      targetLoad: 400,
      adjustedLoad: 395,
      progress: 1.0,
      status: GoalStatus.completed,
    ),
  ];

  static final List<Activity> activities = _generateActivities();

  static List<Activity> _generateActivities() {
    final names = [
      'Morning Coffee Ride',
      'Weekend Long Ride',
      'Hill Repeats - Lookout Mtn',
      'Recovery Spin',
      'Commute Home',
      'Sweet Spot Session',
      'Group Ride - River Trail',
      'Tempo Tuesday',
      'FTP Test',
      'Easy Spin',
      'Gran Fondo Simulation',
      'VO2 Max Intervals',
      'Base Endurance',
      'Sunset Cruise',
      'Crit Practice',
      'Mountain Pass Climb',
      'Indoor Trainer - ERG',
      'Brick Workout',
      'Cadence Drills',
      'Zone 2 Endurance',
      'Threshold 2x20',
      'Recovery Coffee Ride',
      'Century Training Ride',
      'Sprint Intervals',
      'Gravel Adventure',
      'Coastal Highway Ride',
      'Alpine Climbing Day',
      'Team Training Camp',
      'Race Simulation',
      'Active Recovery',
    ];

    final zones = TrainingZone.values;
    final now = DateTime.now();

    return List.generate(28, (i) {
      final daysAgo = i * 2 + (i % 3);
      final zone = zones[i % zones.length];
      final distance = 25.0 + (i * 3.7) % 80;
      final hours = (distance / 28).floor();
      final mins = ((distance / 28 - hours) * 60).round();

      return Activity(
        id: 'activity-$i',
        name: names[i % names.length],
        date: now.subtract(Duration(days: daysAgo)),
        distanceKm: distance,
        duration: Duration(hours: hours, minutes: mins),
        trainingLoad: 45 + (i * 11) % 120,
        zone: zone,
        elevationM: 150 + (i * 47) % 1200,
        avgSpeedKmh: 22 + (i % 8),
        avgHr: 125 + (i * 3) % 45,
        maxHr: 165 + (i * 2) % 25,
        calories: (distance * 28).round(),
        avgPower: 180 + (i * 7) % 80,
        splits: i % 3 == 0
            ? [
                ActivitySplit(
                  label: 'Lap 1',
                  distanceKm: distance / 3,
                  duration: Duration(minutes: (mins / 3).round()),
                  avgSpeedKmh: 24 + i % 3,
                  avgHr: 130 + i % 10,
                ),
                ActivitySplit(
                  label: 'Lap 2',
                  distanceKm: distance / 3,
                  duration: Duration(minutes: (mins / 3).round()),
                  avgSpeedKmh: 23 + i % 3,
                  avgHr: 140 + i % 10,
                ),
                ActivitySplit(
                  label: 'Lap 3',
                  distanceKm: distance / 3,
                  duration: Duration(minutes: (mins / 3).round()),
                  avgSpeedKmh: 22 + i % 3,
                  avgHr: 145 + i % 10,
                ),
              ]
            : [],
      );
    });
  }

  static final List<GoalSummary> summaries = [
    GoalSummary(
      id: 'summary-1',
      goalTitle: 'Spring Century',
      startDate: DateTime(2025, 1, 15),
      endDate: DateTime(2025, 4, 20),
      completionPercent: 0.94,
      plannedLoad: 4200,
      actualLoad: 4085,
      plannedSessions: 48,
      completedSessions: 45,
      ctlStart: 45.2,
      ctlEnd: 68.7,
      experienceLevel: 'Intermediate',
      insights: [
        'CTL increased 52% over the training block — excellent aerobic development.',
        'You completed 94% of planned sessions, with most misses on recovery weeks.',
        'Zone 2 volume was 8% above target, contributing to strong endurance gains.',
        'Consider adding more Z4 work in your next block for event-specific fitness.',
      ],
      badges: [
        const AchievementBadge(
          title: 'Century Ready',
          description: 'Completed a 100+ mile ride during the block',
          iconName: 'emoji_events',
        ),
        const AchievementBadge(
          title: 'Consistency King',
          description: '12 weeks with 4+ rides per week',
          iconName: 'local_fire_department',
        ),
        const AchievementBadge(
          title: 'Climber',
          description: '10,000m elevation gained',
          iconName: 'terrain',
        ),
      ],
    ),
    GoalSummary(
      id: 'summary-2',
      goalTitle: 'Winter Base Building',
      startDate: DateTime(2024, 11, 1),
      endDate: DateTime(2025, 2, 28),
      completionPercent: 0.88,
      plannedLoad: 3600,
      actualLoad: 3420,
      plannedSessions: 42,
      completedSessions: 37,
      ctlStart: 32.1,
      ctlEnd: 52.4,
      experienceLevel: 'Intermediate',
      insights: [
        'Solid base phase with consistent weekly volume averaging 8.2 hours.',
        'Holiday period caused a 2-week dip — plan buffer weeks for future blocks.',
        'Resting HR dropped 4 bpm indicating improved aerobic efficiency.',
      ],
      badges: [
        const AchievementBadge(
          title: 'Base Builder',
          description: 'Completed full winter base phase',
          iconName: 'foundation',
        ),
        const AchievementBadge(
          title: 'Early Bird',
          description: '20 rides started before 7 AM',
          iconName: 'wb_sunny',
        ),
      ],
    ),
    GoalSummary(
      id: 'summary-3',
      goalTitle: 'Crit Season Prep',
      startDate: DateTime(2024, 4, 1),
      endDate: DateTime(2024, 6, 30),
      completionPercent: 0.91,
      plannedLoad: 2800,
      actualLoad: 2750,
      plannedSessions: 36,
      completedSessions: 33,
      ctlStart: 55.0,
      ctlEnd: 71.2,
      experienceLevel: 'Advanced',
      insights: [
        'High-intensity sessions were well-timed with adequate recovery.',
        'Sprint power improved 12% based on estimated metrics.',
        'Race-day simulation rides correlated with strong crit performances.',
      ],
      badges: [
        const AchievementBadge(
          title: 'Sprinter',
          description: 'Peak 5s power in top 10% of your history',
          iconName: 'bolt',
        ),
      ],
    ),
    GoalSummary(
      id: 'summary-4',
      goalTitle: 'Gran Fondo 2024',
      startDate: DateTime(2024, 2, 1),
      endDate: DateTime(2024, 5, 15),
      completionPercent: 0.96,
      plannedLoad: 4500,
      actualLoad: 4620,
      plannedSessions: 52,
      completedSessions: 50,
      ctlStart: 48.0,
      ctlEnd: 74.5,
      experienceLevel: 'Intermediate',
      insights: [
        'Outstanding adherence — one of your best training blocks.',
        'Long ride progression peaked at 145km, event-ready distance.',
        'Nutrition strategy improved in final 4 weeks based on session notes.',
      ],
      badges: [
        const AchievementBadge(
          title: 'Event Finisher',
          description: 'Completed target gran fondo event',
          iconName: 'flag',
        ),
        const AchievementBadge(
          title: 'Volume Beast',
          description: '500+ hours lifetime after this block',
          iconName: 'fitness_center',
        ),
      ],
    ),
  ];
}
