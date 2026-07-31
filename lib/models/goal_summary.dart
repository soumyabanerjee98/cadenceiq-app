import 'package:cadenceiq/models/goal.dart';

enum Trend { improving, overreaching, stable }

enum FatigueRisk { low, medium, high }

class GoalSummary {
  const GoalSummary({
    required this.id,
    required this.plannedLoad,
    required this.actualLoad,
    required this.adherenceScore,
    required this.trend,
    required this.fatigueRisk,
    required this.goal,
    this.aiSummary = '',
    this.aiPositives = const [],
    this.aiIssues = const [],
    this.aiCurrentState = '',
    this.aiRecommendations = const [],
  });

  final String id;
  final num plannedLoad;
  final num actualLoad;
  final num adherenceScore;
  final Trend trend;
  final FatigueRisk fatigueRisk;
  final Goal goal;
  final String? aiSummary;
  final List<String>? aiPositives;
  final List<String>? aiIssues;
  final String? aiCurrentState;
  final List<String>? aiRecommendations;

  factory GoalSummary.fromJson(Map<String, dynamic> json) {
    return GoalSummary(
      id: json['id'],
      plannedLoad: json['plannedLoad'],
      actualLoad: json['actualLoad'],
      adherenceScore: json['adherenceScore'],
      trend: Trend.values.firstWhere((e) => e.name == json["trend"]),
      fatigueRisk: FatigueRisk.values.firstWhere(
        (e) => e.name == json["fatigueRisk"],
      ),
      goal: Goal.fromJson(json['goal']),
      aiSummary: json['aiSummary'] ?? "",
      aiPositives: json['aiPositives'] != null
          ? (json['aiPositives'] as List).map((e) => e.toString()).toList()
          : [],
      aiIssues: json['aiIssues'] != null
          ? (json['aiIssues'] as List).map((e) => e.toString()).toList()
          : [],
      aiCurrentState: json['aiCurrentState'] ?? "",
      aiRecommendations: json['aiRecommendations'] != null
          ? (json['aiRecommendations'] as List)
                .map((e) => e.toString())
                .toList()
          : [],
    );
  }
}
