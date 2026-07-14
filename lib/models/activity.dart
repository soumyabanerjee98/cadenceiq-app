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
  final num? avgHr;

  factory ActivitySplit.fromJson(Map<String, dynamic> json) {
    return ActivitySplit(
      label: json["split"].toString(),
      distanceKm: json["distance"] / 1000,
      duration: Duration(seconds: json["moving_time"]),
      avgSpeedKmh: json["average_speed"] * 3.6,
      avgHr: json["average_heartrate"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "split": int.parse(label),
      "distance": distanceKm * 1000,
      "moving_time": duration.inSeconds,
      "average_speed": avgSpeedKmh / 3.6,
      "average_heartrate": avgHr,
    };
  }
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
    this.elevationM = 0,
    this.avgSpeedKmh = 0,
    this.avgHr = 0,
    this.maxHr = 0,
    this.calories = 0,
    this.avgPower = 0,
    this.splits = const [],
  });

  final String id;
  final String name;
  final DateTime date;
  final double distanceKm;
  final Duration duration;
  final num trainingLoad;
  final TrainingZone zone;
  final num elevationM;
  final double avgSpeedKmh;
  final int? avgHr;
  final int? maxHr;
  final int calories;
  final num avgPower;
  final List<ActivitySplit> splits;

  String get zoneLabel => switch (zone) {
    TrainingZone.z1 => 'Z1 Recovery',
    TrainingZone.z2 => 'Z2 Endurance',
    TrainingZone.z3 => 'Z3 Tempo',
    TrainingZone.z4 => 'Z4 Threshold',
    TrainingZone.z5 => 'Z5 VO2max',
  };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json["id"],
      name: json["name"],
      date: DateTime.parse(json["startDate"]),
      distanceKm: json["distance"] / 1000,
      duration: Duration(seconds: json["movingTime"]),
      trainingLoad: json["trainingLoad"],
      zone: TrainingZone.values.firstWhere((e) => e.name == json["zone"]),
      elevationM: json["elevationGain"],
      avgSpeedKmh: json["avgSpeed"] * 3.6,
      avgHr: json["avgHR"],
      maxHr: json["maxHR"],
      calories: json["calories"],
      avgPower: json["avgWatts"],
      splits: (json["splits"] as List)
          .map((e) => ActivitySplit.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "startDate": date.toString(),
      "distance": distanceKm * 1000,
      "movingTime": duration.inSeconds,
      "trainingLoad": trainingLoad,
      "zone": zone.name,
      "elevationGain": elevationM,
      "avgSpeed": avgSpeedKmh / 3.6,
      "avgHR": avgHr,
      "maxHR": maxHr,
      "calories": calories,
      "avgWatts": avgPower,
      "splits": splits.map((e) => e.toJson()).toList(),
    };
  }
}

class StravaActivity {
  const StravaActivity({
    required this.id,
    required this.name,
    required this.distance,
    required this.date,
  });

  final String id;
  final String name;
  final num distance;
  final DateTime date;

  factory StravaActivity.fromJson(Map<String, dynamic> json) {
    return StravaActivity(
      id: json["id"],
      name: json["name"],
      distance: json["distance"],
      date: DateTime.parse(json["date"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "distance": distance,
      "date": date.toString(),
    };
  }
}
