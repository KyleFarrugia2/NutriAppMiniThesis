import 'workout_split_style.dart';

enum Sex { male, female, other }

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
}

enum NutritionGoal { loseWeight, maintain, gainMuscle }

/// Primary training + lifestyle goal (drives weekly plan and macro emphasis).
enum FitnessGoal {
  stayFit,
  loseWeight,
  bodybuilding,
  powerlifting,
  powerBuilding,
}

extension FitnessGoalX on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.stayFit:
        return 'Stay fit';
      case FitnessGoal.loseWeight:
        return 'Lose weight';
      case FitnessGoal.bodybuilding:
        return 'Bodybuilding';
      case FitnessGoal.powerlifting:
        return 'Powerlifting';
      case FitnessGoal.powerBuilding:
        return 'Powerbuilding';
    }
  }

  String get subtitle {
    switch (this) {
      case FitnessGoal.stayFit:
        return 'Balanced strength, cardio, and mobility';
      case FitnessGoal.loseWeight:
        return 'More conditioning and full-body circuits';
      case FitnessGoal.bodybuilding:
        return 'Hypertrophy — machine & cable focus';
      case FitnessGoal.powerlifting:
        return 'Squat, bench, deadlift strength';
      case FitnessGoal.powerBuilding:
        return 'Heavy compounds plus muscle-building accessories';
    }
  }

  /// Bodybuilding, powerlifting, and powerbuilding need an explicit lose vs gain choice.
  bool get asksWeightPhase =>
      this == FitnessGoal.bodybuilding ||
      this == FitnessGoal.powerlifting ||
      this == FitnessGoal.powerBuilding;

  /// Calorie direction when [asksWeightPhase] is false.
  NutritionGoal get defaultNutritionGoal {
    switch (this) {
      case FitnessGoal.stayFit:
        return NutritionGoal.maintain;
      case FitnessGoal.loseWeight:
        return NutritionGoal.loseWeight;
      case FitnessGoal.bodybuilding:
      case FitnessGoal.powerlifting:
      case FitnessGoal.powerBuilding:
        return NutritionGoal.gainMuscle;
    }
  }
}

extension NutritionGoalWeightPhaseX on NutritionGoal {
  /// Lose or gain only (for lifting-style goals).
  bool get isWeightPhaseChoice =>
      this == NutritionGoal.loseWeight || this == NutritionGoal.gainMuscle;
}

/// Minimum average daily steps recommended in-app for every nutrition goal.
const int kRecommendedMinDailySteps = 8000;

/// Adaptive = sequence-aware (RQ1/RQ2). Fixed = weekday template (RQ1 baseline).
/// Non-sequential = goal-only template, ignores history (RQ2 baseline).
enum WorkoutGuidanceMode { adaptive, fixedRotation, nonSequential }

extension WorkoutGuidanceModeX on WorkoutGuidanceMode {
  String get label {
    switch (this) {
      case WorkoutGuidanceMode.adaptive:
        return 'Adaptive — sequence-aware (RQ1/RQ2)';
      case WorkoutGuidanceMode.fixedRotation:
        return 'Fixed rotation — rule baseline (RQ1)';
      case WorkoutGuidanceMode.nonSequential:
        return 'Non-sequential — static baseline (RQ2)';
    }
  }

  String get shortLabel {
    switch (this) {
      case WorkoutGuidanceMode.adaptive:
        return 'Adaptive';
      case WorkoutGuidanceMode.fixedRotation:
        return 'Fixed';
      case WorkoutGuidanceMode.nonSequential:
        return 'Non-seq.';
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
  UserProfile({
    required this.displayName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.sex,
    required this.activityLevel,
    required this.fitnessGoal,
    NutritionGoal? goal,
    this.wearableStepsAvg,
    this.workoutGuidanceMode = WorkoutGuidanceMode.adaptive,
    this.workoutSplitStyle = WorkoutSplitStyle.goalDefault,
  }) : goal = UserProfile.resolveNutritionGoal(fitnessGoal, goal);

  /// Picks stored [goal] or defaults from [fitnessGoal].
  static NutritionGoal resolveNutritionGoal(
    FitnessGoal fitnessGoal,
    NutritionGoal? goal,
  ) {
    if (fitnessGoal.asksWeightPhase) {
      if (goal == NutritionGoal.loseWeight || goal == NutritionGoal.gainMuscle) {
        return goal!;
      }
      return NutritionGoal.gainMuscle;
    }
    return fitnessGoal.defaultNutritionGoal;
  }

  final String displayName;
  final int age;
  final double heightCm;
  final double weightKg;
  final Sex sex;
  final ActivityLevel activityLevel;
  final FitnessGoal fitnessGoal;

  /// Derived from [fitnessGoal] for calorie/macro math (kept for storage compat).
  final NutritionGoal goal;

  /// Optional average daily steps (e.g. from a wearable) for activity-aware copy.
  final int? wearableStepsAvg;

  /// How the next workout suggestion is produced (thesis comparison).
  final WorkoutGuidanceMode workoutGuidanceMode;

  /// Weekly layout (PPL, upper/lower, full body, …). Regenerate anytime on Workouts.
  final WorkoutSplitStyle workoutSplitStyle;

  UserProfile copyWith({
    String? displayName,
    int? age,
    double? heightCm,
    double? weightKg,
    Sex? sex,
    ActivityLevel? activityLevel,
    FitnessGoal? fitnessGoal,
    NutritionGoal? goal,
    int? wearableStepsAvg,
    WorkoutGuidanceMode? workoutGuidanceMode,
    WorkoutSplitStyle? workoutSplitStyle,
  }) {
    final fg = fitnessGoal ?? this.fitnessGoal;
    return UserProfile(
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fg,
      goal: goal ?? resolveNutritionGoal(fg, this.goal),
      wearableStepsAvg: wearableStepsAvg ?? this.wearableStepsAvg,
      workoutGuidanceMode: workoutGuidanceMode ?? this.workoutGuidanceMode,
      workoutSplitStyle: workoutSplitStyle ?? this.workoutSplitStyle,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'sex': sex.name,
        'activityLevel': activityLevel.name,
        'fitnessGoal': fitnessGoal.name,
        'goal': goal.name,
        'wearableStepsAvg': wearableStepsAvg,
        'workoutGuidanceMode': workoutGuidanceMode.name,
        'workoutSplitStyle': workoutSplitStyle.name,
      };

  static FitnessGoal _fitnessGoalFromJson(Map<String, dynamic> j) {
    final raw = j['fitnessGoal'] as String?;
    if (raw != null) {
      return FitnessGoal.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => FitnessGoal.stayFit,
      );
    }
    final legacy = NutritionGoal.values.firstWhere(
      (e) => e.name == j['goal'],
      orElse: () => NutritionGoal.maintain,
    );
    return switch (legacy) {
      NutritionGoal.loseWeight => FitnessGoal.loseWeight,
      NutritionGoal.gainMuscle => FitnessGoal.bodybuilding,
      NutritionGoal.maintain => FitnessGoal.stayFit,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> j) {
    final fitnessGoal = _fitnessGoalFromJson(j);
    NutritionGoal? storedGoal;
    final goalRaw = j['goal'] as String?;
    if (goalRaw != null) {
      for (final e in NutritionGoal.values) {
        if (e.name == goalRaw) {
          storedGoal = e;
          break;
        }
      }
    }
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
      fitnessGoal: fitnessGoal,
      goal: resolveNutritionGoal(fitnessGoal, storedGoal),
      wearableStepsAvg: (j['wearableStepsAvg'] as num?)?.toInt(),
      workoutGuidanceMode: WorkoutGuidanceMode.values.firstWhere(
        (e) => e.name == j['workoutGuidanceMode'],
        orElse: () => WorkoutGuidanceMode.adaptive,
      ),
      workoutSplitStyle: WorkoutSplitStyle.values.firstWhere(
        (e) => e.name == j['workoutSplitStyle'],
        orElse: () => WorkoutSplitStyle.goalDefault,
      ),
    );
  }
}
