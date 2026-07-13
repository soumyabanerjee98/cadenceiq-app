import 'package:cadenceiq_app/models/goal.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.name = '',
    this.age = 0,
    this.maxHr = 0,
    this.restingHr = 0,
    this.goal,
    this.atl = 0,
    this.ctl = 0,
    this.tsb = 0,
    this.stravaConnected = false,
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

  String get initials {
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name!.isNotEmpty ? name![0].toUpperCase() : '?';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    print(json);
    return UserProfile(
      id: json["id"],
      name: json["name"] ?? "",
      email: json["email"],
      age: json["age"] ?? 0,
      maxHr: json["maxHR"] ?? 0,
      restingHr: json["restingHR"] ?? 0,
      goal: json["goal"],
      atl: json["metrics"]["atl"],
      ctl: json["metrics"]["ctl"],
      tsb: json["metrics"]["tsb"],
      stravaConnected: json["stravaConnected"],
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
      "atl": atl,
      "ctl": ctl,
      "tsb": tsb,
      "stravaConnected": stravaConnected,
    };
  }
}
