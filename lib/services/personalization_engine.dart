import '../models/meal_entry.dart';
import '../models/user_profile.dart';
import '../models/workout_entry.dart';

/// Rule-based personalization (transparent heuristics, no ML).
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

  /// Calorie target for a calendar day given training vs rest layout.
  /// Rest days are ~10% below the profile baseline; training days ~10% above
  /// (extra fuel around sessions; lighter days on rest).
  int dailyCalorieTargetForDayType(UserProfile p, {required bool trainingDay}) {
    final base = dailyCalorieTarget(p);
    final scaled = trainingDay ? base * 1.10 : base * 0.90;
    return scaled.round().clamp(1200, 6000);
  }

  /// Grams per kg bodyweight targets (fitness goal + lose/gain when applicable).
  ({double protein, double carbs, double fat}) macroTargetsPerKg(UserProfile p) {
    if (p.goal == NutritionGoal.loseWeight) {
      return (protein: 2.1, carbs: 3.5, fat: 0.65);
    }
    switch (p.fitnessGoal) {
      case FitnessGoal.loseWeight:
        return (protein: 2.1, carbs: 3.5, fat: 0.65);
      case FitnessGoal.stayFit:
        return (protein: 1.8, carbs: 5.0, fat: 0.8);
      case FitnessGoal.bodybuilding:
        return (protein: 2.3, carbs: 5.0, fat: 0.85);
      case FitnessGoal.powerlifting:
        return (protein: 2.0, carbs: 4.5, fat: 0.9);
      case FitnessGoal.powerBuilding:
        return (protein: 2.2, carbs: 5.5, fat: 0.9);
    }
  }

  int dailyCalorieTarget(UserProfile p) {
    var delta = p.goal.calorieDeltaFromTdee();
    if (p.goal == NutritionGoal.gainMuscle &&
        (p.fitnessGoal == FitnessGoal.powerlifting ||
            p.fitnessGoal == FitnessGoal.powerBuilding)) {
      delta += 100;
    }
    final raw = tdee(p) + delta;
    return raw.round().clamp(1200, 6000);
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
    List<MealEntry> mealsOnDay, {
    required bool trainingDay,
  }) {
    int cal = 0;
    double p = 0, c = 0, f = 0;
    for (final m in mealsOnDay) {
      cal += m.calories;
      p += m.proteinG;
      c += m.carbsG;
      f += m.fatG;
    }
    final baseCal = dailyCalorieTarget(profile);
    final target = dailyCalorieTargetForDayType(profile, trainingDay: trainingDay);
    final macros = macroGramTargets(profile);
    final factor = baseCal <= 0 ? 1.0 : target / baseCal;
    return DailyNutritionSummary(
      caloriesConsumed: cal,
      calorieTarget: target,
      proteinG: p,
      carbsG: c,
      fatG: f,
      proteinTargetG: macros.proteinG * factor,
      carbsTargetG: macros.carbsG * factor,
      fatTargetG: macros.fatG * factor,
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

  /// Non-sequential baseline: same template from goal only (no log history).
  WorkoutRecommendation _nonSequentialSuggestion(UserProfile p) {
    switch (p.fitnessGoal) {
      case FitnessGoal.loseWeight:
        return const WorkoutRecommendation(
          title: 'Baseline: steady-state cardio (35 min)',
          type: WorkoutType.cardio,
          rationale:
              'Non-sequential baseline — generic cardio template from goal only; does not read your recent logs (RQ2 comparison).',
          intensityHint: 'Moderate pace; same suggestion regardless of prior sessions.',
        );
      case FitnessGoal.bodybuilding:
        return const WorkoutRecommendation(
          title: 'Baseline: machine hypertrophy (45 min)',
          type: WorkoutType.strength,
          rationale:
              'Non-sequential baseline — machine-focused template for bodybuilding; ignores training history.',
          intensityHint: 'Pec deck, leg press, cables — no barbell bench in this template.',
        );
      case FitnessGoal.powerlifting:
        return const WorkoutRecommendation(
          title: 'Baseline: squat + bench (50 min)',
          type: WorkoutType.strength,
          rationale:
              'Non-sequential baseline — powerlifting pattern from goal only.',
          intensityHint: 'Heavy compounds; long rest between work sets.',
        );
      case FitnessGoal.powerBuilding:
        return const WorkoutRecommendation(
          title: 'Baseline: squat + machine pump (50 min)',
          type: WorkoutType.strength,
          rationale:
              'Non-sequential baseline — strength plus hypertrophy accessories.',
          intensityHint: 'Main lift heavy, accessories moderate volume.',
        );
      case FitnessGoal.stayFit:
        return const WorkoutRecommendation(
          title: 'Baseline: mixed conditioning (40 min)',
          type: WorkoutType.cardio,
          rationale:
              'Non-sequential baseline — static mixed session; no sequence-aware adjustment.',
          intensityHint: 'Conversation pace; unchanged by what you logged last week.',
        );
    }
  }

  /// Fixed weekday rotation: ignores logs (explicit thesis / evaluation baseline).
  WorkoutRecommendation _fixedRotationSuggestion(UserProfile p) {
    final strengthDay = DateTime.now().weekday.isOdd;
    if (strengthDay) {
      return WorkoutRecommendation(
        title: 'Template: full-body strength (40–50 min)',
        type: WorkoutType.strength,
        rationale:
            'Fixed rotation (odd weekdays → strength). This template does not use your recent logs—use it as a transparent baseline when comparing adherence or UX.',
        intensityHint:
            'Moderate loads; add weight only when form stays crisp across sets.',
      );
    }
    return WorkoutRecommendation(
      title: 'Template: aerobic conditioning (30–40 min)',
      type: WorkoutType.cardio,
      rationale:
            'Fixed rotation (even weekdays → cardio). Same pattern regardless of what you logged recently.',
      intensityHint: 'Easy to moderate “conversation pace” unless your goal is high intensity.',
    );
  }

  /// Recency-aware mix balancing for the next session suggestion.
  WorkoutRecommendation nextWorkoutSuggestion(
    UserProfile p,
    List<WorkoutEntry> recent,
  ) {
    if (p.workoutGuidanceMode == WorkoutGuidanceMode.fixedRotation) {
      return _fixedRotationSuggestion(p);
    }
    if (p.workoutGuidanceMode == WorkoutGuidanceMode.nonSequential) {
      return _nonSequentialSuggestion(p);
    }

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

    final title = switch (p.fitnessGoal) {
      FitnessGoal.bodybuilding => p.sex == Sex.female
          ? 'Glutes & legs (machine focus)'
          : 'Machine push / pull split day',
      FitnessGoal.powerlifting => 'Heavy squat or deadlift day',
      FitnessGoal.powerBuilding => 'Main lift + hypertrophy accessories',
      FitnessGoal.loseWeight => 'Circuit: strength + cardio finishers',
      FitnessGoal.stayFit => 'Full-body strength + core',
    };
    return WorkoutRecommendation(
      title: title,
      type: WorkoutType.strength,
      rationale:
          'Balanced default from your ${p.fitnessGoal.label} goal, sex, age (${p.age}), and recent training mix.',
      intensityHint: p.age >= 50
          ? 'Prioritize form; leave 1–2 reps in reserve on most sets.'
          : 'Log RPE after the session to tune next recommendations.',
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
