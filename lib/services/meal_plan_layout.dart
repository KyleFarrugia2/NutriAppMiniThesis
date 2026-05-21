import 'personalization_engine.dart';

/// One row in the daily meal plan (training vs rest).
class MealSlotDef {
  const MealSlotDef({
    required this.id,
    required this.title,
    required this.calorieFraction,
    required this.hint,
  });

  final String id;
  final String title;

  /// Share of daily calorie target for suggested row (sums to 1.0 per layout).
  final double calorieFraction;

  final String hint;

  static List<MealSlotDef> training() => const [
        MealSlotDef(
          id: 'm1',
          title: 'Meal 1',
          calorieFraction: 0.22,
          hint: 'Any time of day',
        ),
        MealSlotDef(
          id: 'm2',
          title: 'Meal 2',
          calorieFraction: 0.22,
          hint: 'Any time of day',
        ),
        MealSlotDef(
          id: 'm3',
          title: 'Meal 3',
          calorieFraction: 0.18,
          hint: 'Any time of day',
        ),
        MealSlotDef(
          id: 'pre',
          title: 'Pre workout',
          calorieFraction: 0.19,
          hint: 'Before your training session',
        ),
        MealSlotDef(
          id: 'post',
          title: 'Post workout',
          calorieFraction: 0.19,
          hint: 'After your training session',
        ),
      ];

  static List<MealSlotDef> rest() => const [
        MealSlotDef(
          id: 'm1',
          title: 'Meal 1',
          calorieFraction: 0.2,
          hint: 'Any time of day',
        ),
        MealSlotDef(
          id: 'm2',
          title: 'Meal 2',
          calorieFraction: 0.2,
          hint: 'Any time of day',
        ),
        MealSlotDef(
          id: 'm3',
          title: 'Meal 3',
          calorieFraction: 0.2,
          hint: 'Any time of day',
        ),
        MealSlotDef(
          id: 'm4',
          title: 'Meal 4',
          calorieFraction: 0.2,
          hint: 'Any time of day',
        ),
        MealSlotDef(
          id: 'm5',
          title: 'Meal 5',
          calorieFraction: 0.2,
          hint: 'Any time of day',
        ),
      ];

  /// Suggested kcal and macro grams for this slot from daily targets.
  static ({int kcal, int p, int c, int f}) suggestedMacros({
    required MealSlotDef slot,
    required DailyNutritionSummary targets,
  }) {
    final w = slot.calorieFraction;
    return (
      kcal: (targets.calorieTarget * w).round(),
      p: (targets.proteinTargetG * w).round(),
      c: (targets.carbsTargetG * w).round(),
      f: (targets.fatTargetG * w).round(),
    );
  }
}
