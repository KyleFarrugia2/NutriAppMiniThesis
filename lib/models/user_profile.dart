enum Sex { male, female, other }

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
}

enum NutritionGoal { loseWeight, maintain, gainMuscle }

/// Minimum average daily steps recommended in-app for every nutrition goal.
const int kRecommendedMinDailySteps = 8000;

/// Adaptive uses recent logs. Fixed ignores them for a simple baseline comparison.
enum WorkoutGuidanceMode { adaptive, fixedRotation }

extension WorkoutGuidanceModeX on WorkoutGuidanceMode {
  String get label {
    switch (this) {
      case WorkoutGuidanceMode.adaptive:
        return 'Adaptive (uses your logs)';
      case WorkoutGuidanceMode.fixedRotation:
        return 'Fixed rotation (ignores logs)';
    }
  }
}

extension ActivityLevelX on ActivityLevel {
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary (desk job)';
      case ActivityLevel.light:
        return 'Light (1–3 workouts/week)';
      case ActivityLevel.moderate:
        return 'Moderate (3–5 workouts/week)';
      case ActivityLevel.active:
        return 'Active (6–7 workouts/week)';
      case ActivityLevel.veryActive:
        return 'Very active (athlete / physical job)';
    }
  }
}

extension NutritionGoalX on NutritionGoal {
  String get label {
    switch (this) {
      case NutritionGoal.loseWeight:
        return 'Lose weight';
      case NutritionGoal.maintain:
        return 'Maintain';
      case NutritionGoal.gainMuscle:
        return 'Build muscle';
    }
  }

  /// Daily calorie adjustment from TDEE.
  int calorieDeltaFromTdee() {
    switch (this) {
      case NutritionGoal.loseWeight:
        return -400;
      case NutritionGoal.maintain:
        return 0;
      case NutritionGoal.gainMuscle:
        return 300;
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.sex,
    required this.activityLevel,
    required this.goal,
    this.wearableStepsAvg,
    this.workoutGuidanceMode = WorkoutGuidanceMode.adaptive,
  });

  final String displayName;
  final int age;
  final double heightCm;
  final double weightKg;
  final Sex sex;
  final ActivityLevel activityLevel;
  final NutritionGoal goal;

  /// Optional average daily steps (e.g. from a wearable) for activity-aware copy.
  final int? wearableStepsAvg;

  /// How the next workout suggestion is produced (thesis comparison).
  final WorkoutGuidanceMode workoutGuidanceMode;

  UserProfile copyWith({
    String? displayName,
    int? age,
    double? heightCm,
    double? weightKg,
    Sex? sex,
    ActivityLevel? activityLevel,
    NutritionGoal? goal,
    int? wearableStepsAvg,
    WorkoutGuidanceMode? workoutGuidanceMode,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      wearableStepsAvg: wearableStepsAvg ?? this.wearableStepsAvg,
      workoutGuidanceMode: workoutGuidanceMode ?? this.workoutGuidanceMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'sex': sex.name,
        'activityLevel': activityLevel.name,
        'goal': goal.name,
        'wearableStepsAvg': wearableStepsAvg,
        'workoutGuidanceMode': workoutGuidanceMode.name,
      };

  static UserProfile fromJson(Map<String, dynamic> j) {
    return UserProfile(
      displayName: j['displayName'] as String? ?? 'User',
      age: (j['age'] as num?)?.toInt() ?? 30,
      heightCm: (j['heightCm'] as num?)?.toDouble() ?? 170,
      weightKg: (j['weightKg'] as num?)?.toDouble() ?? 70,
      sex: Sex.values.firstWhere(
        (e) => e.name == j['sex'],
        orElse: () => Sex.other,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == j['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      ),
      goal: NutritionGoal.values.firstWhere(
        (e) => e.name == j['goal'],
        orElse: () => NutritionGoal.maintain,
      ),
      wearableStepsAvg: (j['wearableStepsAvg'] as num?)?.toInt(),
      workoutGuidanceMode: WorkoutGuidanceMode.values.firstWhere(
        (e) => e.name == j['workoutGuidanceMode'],
        orElse: () => WorkoutGuidanceMode.adaptive,
      ),
    );
  }
}
