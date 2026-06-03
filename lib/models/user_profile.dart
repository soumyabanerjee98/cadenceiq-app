class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.age = 0,
    this.maxHr = 0,
    this.restingHr = 0,
    this.avatarUrl = '',
    this.totalActivities = 0,
    this.totalDistanceKm = 0,
    this.totalHours = 0,
    this.goalsCompleted = 0,
  });

  final String id;
  final String name;
  final String email;
  final int age;
  final int maxHr;
  final int restingHr;
  final String avatarUrl;
  final int totalActivities;
  final double totalDistanceKm;
  final double totalHours;
  final int goalsCompleted;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfile(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      age: json["age"] ?? 0,
      maxHr: json["maxHr"] ?? 0,
      restingHr: json["restingHr"] ?? 0,
      avatarUrl: json["avatarUrl"] ?? "",
      totalActivities: json["totalActivities"] ?? 0,
      totalDistanceKm: json["totalDistanceKm"] ?? 0,
      totalHours: json["totalHours"] ?? 0,
      goalsCompleted: json["goalsCompleted"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "age": age,
      "maxHr": maxHr,
      "restingHr": restingHr,
      "avatarUrl": avatarUrl,
      "totalActivities": totalActivities,
      "totalDistanceKm": totalDistanceKm,
      "totalHours": totalHours,
      "goalsCompleted": goalsCompleted,
    };
  }
}
