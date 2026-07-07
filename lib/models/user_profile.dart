class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.name = '',
    this.age = 0,
    this.maxHr = 0,
    this.restingHr = 0,
    this.currentGoalId = '',
  });

  final String id;
  final String email;
  final String? name;
  final int? age;
  final int? maxHr;
  final int? restingHr;
  final String? currentGoalId;

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
      age: json["age"] ?? 0,
      maxHr: json["maxHR"] ?? 0,
      restingHr: json["restingHR"] ?? 0,
      currentGoalId: json["currentGoalId"] ?? "",
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
      "currentGoalId": currentGoalId,
    };
  }
}
