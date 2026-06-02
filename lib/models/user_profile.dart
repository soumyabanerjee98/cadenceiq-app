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
}
