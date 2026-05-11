import '../models/meal_entry.dart';
import '../models/user_profile.dart';
import '../models/workout_entry.dart';

/// Rule-based personalization layer (ready to swap for learned models).
class PersonalizationEngine {
  const PersonalizationEngine();

  /// Mifflin–St Jeor BMR (kcal/day).
  double bmr(UserProfile p) {
    final w = p.weightKg;
    final h = p.heightCm;
    final a = p.age.toDouble();
    double base = 10 * w + 6.25 * h - 5 * a;
    switch (p.sex) {
      case Sex.male:
        base += 5;
        break;
      case Sex.female:
        base -= 161;
        break;
      case Sex.other:
        base -= 78;
        break;
    }
    return base.clamp(800, 6000);
  }

  double tdee(UserProfile p) => bmr(p) * p.activityLevel.multiplier;

  int dailyCalorieTarget(UserProfile p) {
    final raw = tdee(p) + p.goal.calorieDeltaFromTdee();
    return raw.round().clamp(1200, 6000);
  }

  /// Grams per kg bodyweight targets (simple heuristic by goal).
  ({double protein, double carbs, double fat}) macroTargetsPerKg(UserProfile p) {
    switch (p.goal) {
      case NutritionGoal.loseWeight:
        return (protein: 2.0, carbs: 4.0, fat: 0.7);
      case NutritionGoal.maintain:
        return (protein: 1.8, carbs: 5.0, fat: 0.8);
      case NutritionGoal.gainMuscle:
        return (protein: 2.2, carbs: 5.5, fat: 0.9);
    }
  }

  MacroTotals macroGramTargets(UserProfile p) {
    final m = macroTargetsPerKg(p);
    final w = p.weightKg;
    return MacroTotals(
      proteinG: (m.protein * w).roundToDouble(),
      carbsG: (m.carbs * w).roundToDouble(),
      fatG: (m.fat * w).roundToDouble(),
    );
  }

  List<MealEntry> mealsForDay(List<MealEntry> all, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return all.where((e) {
      final x = DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day);
      return x == d;
    }).toList();
  }

  DailyNutritionSummary summarizeDay(
    UserProfile profile,
    List<MealEntry> mealsOnDay,
  ) {
    int cal = 0;
    double p = 0, c = 0, f = 0;
    for (final m in mealsOnDay) {
      cal += m.calories;
      p += m.proteinG;
      c += m.carbsG;
      f += m.fatG;
    }
    final target = dailyCalorieTarget(profile);
    final macros = macroGramTargets(profile);
    return DailyNutritionSummary(
      caloriesConsumed: cal,
      calorieTarget: target,
      proteinG: p,
      carbsG: c,
      fatG: f,
      proteinTargetG: macros.proteinG,
      carbsTargetG: macros.carbsG,
      fatTargetG: macros.fatG,
    );
  }

  /// Explainable nutrition nudge for dashboard.
  String nutritionInsight(UserProfile p, DailyNutritionSummary s) {
    final calRem = s.calorieTarget - s.caloriesConsumed;
    if (calRem > 450) {
      return 'You have meaningful calories left today. Prioritize ${p.goal == NutritionGoal.gainMuscle ? "lean protein + carbs around training" : "protein and vegetables"}.';
    }
    if (calRem < -250) {
      return 'You are above today’s calorie target. Tomorrow, try smaller portions or one fewer energy-dense snack.';
    }
    if (s.proteinG < s.proteinTargetG * 0.85) {
      return 'Protein is below your personalized target—add a palm-sized protein source at your next meal.';
    }
    if (p.wearableStepsAvg != null && p.wearableStepsAvg! > 10000 && p.goal == NutritionGoal.loseWeight) {
      return 'High step counts detected—your plan already reflects activity; avoid “eating back” all burned calories unless energy is low.';
    }
    return 'Intake is close to your personalized plan. Keep consistent logging for better adaptive recommendations.';
  }

  List<WorkoutEntry> workoutsSince(List<WorkoutEntry> all, DateTime from) {
    return all.where((w) => w.completedAt.isAfter(from)).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  /// Simple sequential-style recommendation (FitRec-inspired: recency + balance).
  WorkoutRecommendation nextWorkoutSuggestion(
    UserProfile p,
    List<WorkoutEntry> recent,
  ) {
    final last7 = workoutsSince(
      recent,
      DateTime.now().subtract(const Duration(days: 7)),
    );
    final strength = last7.where((w) => w.type == WorkoutType.strength).length;
    final cardio = last7.where((w) => w.type == WorkoutType.cardio).length;
    final last = last7.isEmpty ? null : last7.first;

    if (last != null) {
      final daysSince = DateTime.now().difference(last.completedAt).inHours / 24;
      if (daysSince >= 2 && last.type == WorkoutType.strength) {
        return WorkoutRecommendation(
          title: 'Upper-body strength (45 min)',
          type: WorkoutType.strength,
          rationale:
              'You have not logged strength recently—continuity improves adherence (sequence-aware coaching).',
          intensityHint: 'RPE 7–8 on working sets if sleep was good.',
        );
      }
    }

    if (cardio > strength + 2) {
      return WorkoutRecommendation(
        title: 'Full-body strength + core',
        type: WorkoutType.strength,
        rationale:
            'Recent logs skew cardio-heavy; balance supports recovery and lean mass for your goal: ${p.goal.label}.',
        intensityHint: 'Start moderate; increase load if last session felt easy (RPE ≤6).',
      );
    }

    if (strength > cardio + 2) {
      return WorkoutRecommendation(
        title: 'Zone 2 cardio (30–40 min)',
        type: WorkoutType.cardio,
        rationale:
            'You have logged more strength than cardio—adding easy aerobic work supports health and recovery.',
        intensityHint: 'Conversation pace; optional HR ~60–70% max HR estimate.',
      );
    }

    return WorkoutRecommendation(
      title: p.goal == NutritionGoal.gainMuscle
          ? 'Progressive overload lower session'
          : 'Mixed circuit: strength + short intervals',
      type: WorkoutType.strength,
      rationale:
          'Balanced default based on your profile and recent mix—personalized as a baseline before ML ranking.',
      intensityHint: 'Log RPE after the session to tune next recommendations.',
    );
  }
}

class MacroTotals {
  const MacroTotals({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double proteinG;
  final double carbsG;
  final double fatG;
}

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.caloriesConsumed,
    required this.calorieTarget,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.proteinTargetG,
    required this.carbsTargetG,
    required this.fatTargetG,
  });

  final int caloriesConsumed;
  final int calorieTarget;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double proteinTargetG;
  final double carbsTargetG;
  final double fatTargetG;

  double get calorieProgress =>
      calorieTarget == 0 ? 0 : (caloriesConsumed / calorieTarget).clamp(0.0, 1.2);
}

class WorkoutRecommendation {
  const WorkoutRecommendation({
    required this.title,
    required this.type,
    required this.rationale,
    required this.intensityHint,
  });

  final String title;
  final WorkoutType type;
  final String rationale;
  final String intensityHint;
}
