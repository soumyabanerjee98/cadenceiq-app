enum ActivityStatus { completed, planned, skipped }

enum TrainingZone { z1, z2, z3, z4, z5 }

class ActivitySplit {
  const ActivitySplit({
    required this.label,
    required this.distanceKm,
    required this.duration,
    required this.avgSpeedKmh,
    required this.avgHr,
  });

  final String label;
  final double distanceKm;
  final Duration duration;
  final double avgSpeedKmh;
  final int avgHr;
}

class Activity {
  const Activity({
    required this.id,
    required this.name,
    required this.date,
    required this.distanceKm,
    required this.duration,
    required this.trainingLoad,
    required this.zone,
    required this.status,
    this.elevationM = 0,
    this.avgSpeedKmh = 0,
    this.avgHr = 0,
    this.maxHr = 0,
    this.calories = 0,
    this.avgPower = 0,
    this.notes = '',
    this.splits = const [],
  });

  final String id;
  final String name;
  final DateTime date;
  final double distanceKm;
  final Duration duration;
  final double trainingLoad;
  final TrainingZone zone;
  final ActivityStatus status;
  final double elevationM;
  final double avgSpeedKmh;
  final int avgHr;
  final int maxHr;
  final int calories;
  final double avgPower;
  final String notes;
  final List<ActivitySplit> splits;

  String get zoneLabel => switch (zone) {
        TrainingZone.z1 => 'Z1 Recovery',
        TrainingZone.z2 => 'Z2 Endurance',
        TrainingZone.z3 => 'Z3 Tempo',
        TrainingZone.z4 => 'Z4 Threshold',
        TrainingZone.z5 => 'Z5 VO2max',
      };
}
