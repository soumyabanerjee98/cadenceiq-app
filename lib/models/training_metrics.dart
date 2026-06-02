class TrainingMetrics {
  const TrainingMetrics({
    required this.ctl,
    required this.atl,
    required this.tsb,
    required this.currentLoad,
    required this.targetLoad,
    required this.adjustedLoad,
    required this.weeklyLoads,
    required this.zoneDistribution,
  });

  final double ctl;
  final double atl;
  final double tsb;
  final double currentLoad;
  final double targetLoad;
  final double adjustedLoad;
  final List<double> weeklyLoads;
  final Map<String, double> zoneDistribution;
}

class TodaySession {
  const TodaySession({
    required this.title,
    required this.duration,
    required this.distanceKm,
    required this.targetLoad,
    required this.zone,
  });

  final String title;
  final Duration duration;
  final double distanceKm;
  final double targetLoad;
  final String zone;
}
