import 'user_profile.dart';

/// Weekly layout template (always 7 days with ≥2 rest days).
enum WorkoutSplitStyle {
  goalDefault,
  pplRest,
  pplUpperLower,
  upperLowerRest,
  fullBody3x,
}

extension WorkoutSplitStyleX on WorkoutSplitStyle {
  String get label {
    switch (this) {
      case WorkoutSplitStyle.goalDefault:
        return 'Recommended for your goal';
      case WorkoutSplitStyle.pplRest:
        return 'PPL + rest';
      case WorkoutSplitStyle.pplUpperLower:
        return 'PPL + rest + upper / lower';
      case WorkoutSplitStyle.upperLowerRest:
        return 'Upper / lower + rest';
      case WorkoutSplitStyle.fullBody3x:
        return 'Full body (3× / week)';
    }
  }

  String get subtitle {
    switch (this) {
      case WorkoutSplitStyle.goalDefault:
        return 'Auto-picked from your training goal, sex, and age';
      case WorkoutSplitStyle.pplRest:
        return 'Push · Pull · Legs · Rest · Push · Pull · Rest';
      case WorkoutSplitStyle.pplUpperLower:
        return 'Push · Pull · Legs · Rest · Upper · Lower · Rest';
      case WorkoutSplitStyle.upperLowerRest:
        return 'Upper · Lower · Rest · Upper · Lower · Rest · Rest';
      case WorkoutSplitStyle.fullBody3x:
        return 'Full body · Rest · Full body · Rest · Full body · Rest · Rest';
    }
  }

}

/// Splits users can rotate through when a plan is not a good fit.
List<WorkoutSplitStyle> workoutSplitOptionsForGoal(FitnessGoal goal) {
  switch (goal) {
    case FitnessGoal.bodybuilding:
    case FitnessGoal.powerBuilding:
      return const [
        WorkoutSplitStyle.goalDefault,
        WorkoutSplitStyle.pplRest,
        WorkoutSplitStyle.pplUpperLower,
        WorkoutSplitStyle.upperLowerRest,
        WorkoutSplitStyle.fullBody3x,
      ];
    case FitnessGoal.stayFit:
    case FitnessGoal.loseWeight:
      return const [
        WorkoutSplitStyle.goalDefault,
        WorkoutSplitStyle.upperLowerRest,
        WorkoutSplitStyle.fullBody3x,
        WorkoutSplitStyle.pplRest,
      ];
    case FitnessGoal.powerlifting:
      return const [
        WorkoutSplitStyle.goalDefault,
        WorkoutSplitStyle.upperLowerRest,
        WorkoutSplitStyle.fullBody3x,
      ];
  }
}

/// Shown on Workouts tab and regenerate screen.
const String kRecoveryRestDaysMessage =
    'Recovery is just as important as training. Every plan here includes at least '
    'two rest days per week — we recommend keeping that minimum, though you can '
    'still edit any day in your calendar if you prefer.';
