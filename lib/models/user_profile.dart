class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.name = '',
    this.avatarUrl,
    this.age,
    this.maxHr,
    this.restingHr,
    this.atl = 0,
    this.ctl = 0,
    this.tsb = 0,
    this.stravaConnected = false,
    this.totalActivities = 0,
    this.totalDistance = 0,
    this.totalHours = 0,
    this.goalsCompleted = 0,
    required this.weeklyLoad,
    required this.zoneDistribution,
  });

  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final int? age;
  final int? maxHr;
  final int? restingHr;
  final num atl;
  final num ctl;
  final num tsb;
  final bool stravaConnected;
  final int totalActivities;
  final num totalDistance;
  final num totalHours;
  final int goalsCompleted;
  final List<WeeklyLoad> weeklyLoad;
  final Map<String, num> zoneDistribution;

  String get initials {
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name!.isNotEmpty ? name![0].toUpperCase() : '?';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"],
      name: json["name"] ?? "",
      avatarUrl: json["avatarUrl"],
      email: json["email"],
      age: json["age"],
      maxHr: json["maxHR"],
      restingHr: json["restingHR"],
      atl: json["metrics"]["atl"],
      ctl: json["metrics"]["ctl"],
      tsb: json["metrics"]["tsb"],
      stravaConnected: json["settings"]["stravaConnected"],
      totalActivities: json["stats"]["totalActivities"],
      totalDistance: json["stats"]["totalDistance"],
      totalHours: json["stats"]["totalHours"],
      goalsCompleted: json["stats"]["goalsCompleted"],
      weeklyLoad: (json["stats"]["weeklyLoad"] as List)
          .map(((e) => WeeklyLoad.fromJson(e)))
          .toList(),
      zoneDistribution:
          (json["stats"]["zoneDistribution"] as Map<String, dynamic>)
              .cast<String, num>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "avatarUrl": avatarUrl,
      "email": email,
      "age": age,
      "maxHR": maxHr,
      "restingHR": restingHr,
      "metrics": {"atl": atl, "ctl": ctl, "tsb": tsb},
      "settings": {"stravaConnected": stravaConnected},
      "stats": {
        "totalActivities": totalActivities,
        "totalDistance": totalDistance,
        "totalHours": totalHours,
        "goalsCompleted": goalsCompleted,
        "weeklyLoad": weeklyLoad.map((e) => e.toJson()).toList(),
        "zoneDistribution": zoneDistribution,
      },
    };
  }
}

class WeeklyLoad {
  const WeeklyLoad({required this.date, required this.day, required this.load});

  final DateTime date;
  final String day;
  final num load;

  factory WeeklyLoad.fromJson(Map<String, dynamic> json) {
    return WeeklyLoad(
      date: DateTime.parse(json["date"]),
      day: json["day"],
      load: json["load"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date.toIso8601String().split("T")[0],
      "day": day,
      "load": load,
    };
  }
}
