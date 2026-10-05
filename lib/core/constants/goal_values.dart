/// API-aligned goal / plan preference values (mirrors backend constants).
class GoalValues {
  static const dayOfWeekValues = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const sessionTypeValues = [
    'rest',
    'recovery',
    'easy',
    'endurance',
    'tempo',
    'threshold',
    'vo2',
    'sprint',
    'long',
  ];

  static const goalTypeValues = [
    'general_fitness',
    'pace_improvement',
    'endurance',
    'weight_loss',
    'time_trial',
    'gran_fondo',
    'bikepacking',
    'race',
    'commuting',
    'maintenance',
    'custom',
  ];

  static const eventPrepGoals = [
    'race',
    'gran_fondo',
    'time_trial',
    'bikepacking',
  ];
}
