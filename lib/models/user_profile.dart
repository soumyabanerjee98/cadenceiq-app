import 'package:cadenceiq_app/models/goal.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.name = '',
    this.age,
    this.maxHr,
    this.restingHr,
    this.goal,
    this.atl = 0,
    this.ctl = 0,
    this.tsb = 0,
    this.stravaConnected = false,
    this.totalActivities = 0,
    this.totalDistance = 0,
    this.totalHours = 0,
    this.goalsCompleted = 0,
  });

  final String id;
  final String email;
  final String? name;
  final int? age;
  final int? maxHr;
  final int? restingHr;
  final Goal? goal;
  final num atl;
  final num ctl;
  final num tsb;
  final bool stravaConnected;
  final int totalActivities;
  final num totalDistance;
  final num totalHours;
  final int goalsCompleted;

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
      email: json["email"],
      age: json["age"],
      maxHr: json["maxHR"],
      restingHr: json["restingHR"],
      goal: json["goal"],
      atl: json["metrics"]["atl"],
      ctl: json["metrics"]["ctl"],
      tsb: json["metrics"]["tsb"],
      stravaConnected: json["settings"]["stravaConnected"],
      totalActivities: json["stats"]["totalActivities"],
      totalDistance: json["stats"]["totalDistance"],
      totalHours: json["stats"]["totalHours"],
      goalsCompleted: json["stats"]["goalsCompleted"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "age": age,
      "maxHR": maxHr,
      "restingHR": restingHr,
      "goal": goal,
      "metrics": {"atl": atl, "ctl": ctl, "tsb": tsb},
      "settings": {"stravaConnected": stravaConnected},
      "stats": {
        "totalActivities": totalActivities,
        "totalDistance": totalDistance,
        "totalHours": totalHours,
        "goalsCompleted": goalsCompleted,
      },
    };
  }
}
