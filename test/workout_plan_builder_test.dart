import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_work_app/models/user_profile.dart';
import 'package:nutri_work_app/models/weekly_workout_program.dart';
import 'package:nutri_work_app/models/workout_split_style.dart';
import 'package:nutri_work_app/services/workout_plan_builder.dart';

UserProfile _profile({
  required FitnessGoal fg,
  required WorkoutSplitStyle split,
  Sex sex = Sex.male,
}) {
  return UserProfile(
    displayName: 'Test',
    age: 28,
    heightCm: 175,
    weightKg: 72,
    sex: sex,
    activityLevel: ActivityLevel.moderate,
    fitnessGoal: fg,
    goal: fg.asksWeightPhase ? NutritionGoal.gainMuscle : fg.defaultNutritionGoal,
    workoutSplitStyle: split,
  );
}

void main() {
  test('every goal and sex builds a 7-day weekly plan', () {
    for (final fg in FitnessGoal.values) {
      for (final sex in Sex.values) {
        final plan = WorkoutPlanBuilder.buildFor(_profile(fg: fg, split: WorkoutSplitStyle.goalDefault, sex: sex));
        expect(plan.days.length, WeeklyWorkoutPlan.slotCount, reason: '${fg.name} / ${sex.name}');
      }
    }
  });

  test('bodybuilding splits have at least two rest days', () {
    for (final split in workoutSplitOptionsForGoal(FitnessGoal.bodybuilding)) {
      final plan = WorkoutPlanBuilder.buildFor(
        _profile(fg: FitnessGoal.bodybuilding, split: split),
      );
      final rests = plan.days.where((d) => d.isRest).length;
      expect(rests, greaterThanOrEqualTo(WorkoutPlanBuilder.minRestDaysPerWeek),
          reason: split.name);
    }
  });
}
