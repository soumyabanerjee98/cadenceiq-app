import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum ExperienceLevel { beginner, intermediate, advanced, elite }

enum PlanType {
  rest,
  recovery,
  endurance,
  easy,
  tempo,
  threshold,
  vo2,
  sprint,
  long,
}

Color planColor(PlanType type) {
  switch (type) {
    case PlanType.rest:
      return Colors.grey;

    case PlanType.recovery:
      return Colors.teal;

    case PlanType.easy:
      return Colors.green;

    case PlanType.endurance:
      return Colors.blue;

    case PlanType.tempo:
      return Colors.orange;

    case PlanType.threshold:
      return Colors.deepOrange;

    case PlanType.vo2:
      return Colors.red;

    case PlanType.sprint:
      return Colors.purple;

    case PlanType.long:
      return AppColors.primary;
  }
}

IconData planIcon(PlanType type) {
  switch (type) {
    case PlanType.rest:
      return Icons.hotel;
    case PlanType.recovery:
      return Icons.favorite;
    case PlanType.easy:
      return Icons.directions_bike;
    case PlanType.endurance:
      return Icons.route;
    case PlanType.tempo:
      return Icons.speed;
    case PlanType.threshold:
      return Icons.local_fire_department;
    case PlanType.vo2:
      return Icons.monitor_heart;
    case PlanType.sprint:
      return Icons.flash_on;
    case PlanType.long:
      return Icons.landscape;
  }
}

enum GoalStatus { ontrack, overtrained, undertrained }

class PrePlan {
  const PrePlan({
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.targetLoad,
    required this.targetDistance,
    required this.targetDuration,
    required this.instructions,
  });

  final DateTime date;
  final PlanType type;
  final String title;
  final String description;
  final num targetLoad;
  final int targetDistance; // km
  final Duration targetDuration; // minutes
  final String instructions;

  factory PrePlan.fromJson(Map<String, dynamic> json) {
    return PrePlan(
      date: DateTime.parse(json['date']),
      type: PlanType.values.firstWhere((e) => e.name == json["type"]),
      title: json['title'],
      description: json['description'],
      targetLoad: json['targetLoad'],
      targetDistance: json['targetDistance'],
      targetDuration: Duration(minutes: json['targetDuration']),
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date.toIso8601String().split("T")[0],
      "type": type.name,
      "title": title,
      "description": description,
      "targetLoad": targetLoad,
      "targetDistance": targetDistance,
      "targetDuration": targetDuration.inMinutes,
      "instructions": instructions,
    };
  }
}

class TrainingTarget {
  const TrainingTarget({
    required this.currentLoad,
    required this.targetLoad,
    required this.adjustedLoad,
    required this.fatigue,
    required this.fitness,
    required this.readiness,
    required this.goalDifficulty,
    required this.goalConfidence,
    required this.goalReason,
    required this.plan,
  });
  final num currentLoad;
  final num targetLoad;
  final num adjustedLoad;
  final num fatigue;
  final num fitness;
  final num readiness;
  final String goalDifficulty;
  final int goalConfidence;
  final String goalReason;
  final List<PrePlan> plan;

  factory TrainingTarget.fromJson(Map<String, dynamic> json) {
    return TrainingTarget(
      currentLoad: json["currentLoad"],
      targetLoad: json["targetLoad"],
      adjustedLoad: json["adjustedLoad"],
      fatigue: json["fatigue"],
      fitness: json["fitness"],
      readiness: json["readiness"],
      goalDifficulty: json["goalSummary"]["difficulty"],
      goalConfidence: json["goalSummary"]["confidence"],
      goalReason: json["goalSummary"]["reason"],
      plan: (json["plan"] as List).map((e) => PrePlan.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "currentLoad": currentLoad,
      "targetLoad": targetLoad,
      "adjustedLoad": adjustedLoad,
      "fatigue": fatigue,
      "fitness": fitness,
      "readiness": readiness,
      "plan": plan.map((e) => e.toJson()).toList(),
      "goalSummary": {
        "difficulty": goalDifficulty,
        "confidence": goalConfidence,
        "reason": goalReason,
      },
    };
  }
}

class Plan {
  const Plan({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    this.instructions = '',
    required this.targetLoad,
    required this.targetDistance,
    required this.targetDuration,
    required this.completed,
    this.completedAt,
    required this.actualLoad,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final PlanType type;
  final String title;
  final String description;
  final String? instructions;
  final num targetLoad;
  final num targetDistance; // km
  final Duration targetDuration; // minutes
  final bool completed;
  final DateTime? completedAt;
  final num? actualLoad;
  final DateTime createdAt;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: PlanType.values.firstWhere((e) => e.name == json["type"]),
      title: json['title'],
      description: json['description'],
      instructions: json['instructions'] ?? "",
      targetLoad: json["targetLoad"],
      targetDistance: json["targetDistance"],
      targetDuration: Duration(minutes: json["targetDuration"]),
      completed: json["completed"],
      completedAt: json["completedAt"] != null
          ? DateTime.parse(json["completedAt"])
          : null,
      actualLoad: json["actualLoad"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}

class PlanInsight {
  const PlanInsight({
    required this.summary,
    required this.risk,
    required this.recommendations,
  });

  final String summary;
  final String risk;
  final List<String> recommendations;

  factory PlanInsight.fromJson(Map<String, dynamic> json) {
    return PlanInsight(
      summary: json['summary'],
      risk: json['risk'],
      recommendations: (json["recommendations"] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class Goal {
  const Goal({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.experienceLevel,
    this.customGoalRequest = '',
    required this.currentLoad,
    required this.targetLoad,
    required this.adjustedLoad,
    required this.fatigue,
    required this.fitness,
    required this.readiness,
    required this.status,
    required this.isActive,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.completion,
    this.plans = const [],
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final ExperienceLevel experienceLevel;
  final String? customGoalRequest;
  final num currentLoad;
  final num targetLoad;
  final num adjustedLoad;
  final num fatigue;
  final num fitness;
  final num readiness;
  final GoalStatus status;
  final bool isActive;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Plan> plans;
  final num completion;

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      title: json['title'],
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.name == json["experienceLevel"],
      ),
      customGoalRequest: json['customGoalRequest'] ?? "",
      currentLoad: json['currentLoad'],
      targetLoad: json["targetLoad"],
      adjustedLoad: json['adjustedLoad'],
      fatigue: json["fatigue"],
      fitness: json["fitness"],
      readiness: json["readiness"],
      status: GoalStatus.values.firstWhere((e) => e.name == json["status"]),
      isActive: json["isActive"],
      isCompleted: json["isCompleted"],
      completion: json['completion'],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      plans: (json["plan"] as List).map((e) => Plan.fromJson(e)).toList(),
    );
  }

  int get daysRemaining =>
      endDate.difference(DateTime.now()).inDays.clamp(0, 999);

  String get experienceLabel => switch (experienceLevel) {
    ExperienceLevel.beginner => 'Beginner',
    ExperienceLevel.intermediate => 'Intermediate',
    ExperienceLevel.advanced => 'Advanced',
    ExperienceLevel.elite => 'Elite',
  };
}
