import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_work_app/models/user_profile.dart';
import 'package:nutri_work_app/services/meal_suggestion_service.dart';

void main() {
  final profile = UserProfile(
    displayName: 'Test',
    age: 25,
    heightCm: 175,
    weightKg: 72,
    sex: Sex.male,
    activityLevel: ActivityLevel.moderate,
    fitnessGoal: FitnessGoal.bodybuilding,
    goal: NutritionGoal.gainMuscle,
  );

  test('meal 1 always includes whole eggs and egg whites', () {
    final meal = MealSuggestionService().suggestionForSlot(
      profile: profile,
      trainingDay: true,
      slotId: 'm1',
    );
    expect(meal, isNotNull);
    final notes = meal!.items.map((i) => i.food.sourceNote).toSet();
    expect(notes, contains('local:egg_whole'));
    expect(notes, contains('local:egg_white'));
    expect(notes, isNot(contains('local:banana')));
  });

  test('meal 1 protein comes mainly from eggs not oats', () {
    final meal = MealSuggestionService().suggestionForSlot(
      profile: profile,
      trainingDay: true,
      slotId: 'm1',
    )!;
    double proteinFromEggs = 0;
    double proteinFromOats = 0;
    for (final i in meal.items) {
      final p = i.food.scaledForGrams(i.grams).proteinG;
      if (i.food.sourceNote == 'local:oats_dry') {
        proteinFromOats += p;
      } else if (i.food.sourceNote == 'local:egg_whole' ||
          i.food.sourceNote == 'local:egg_white') {
        proteinFromEggs += p;
      }
    }
    expect(proteinFromEggs, greaterThan(proteinFromOats));
    expect(proteinFromEggs, greaterThan(10));
  });

  test('meal 1 lists whole eggs by count and whites in grams', () {
    final meal = MealSuggestionService().suggestionForSlot(
      profile: profile,
      trainingDay: true,
      slotId: 'm1',
    )!;
    expect(meal.summaryLine, contains('whole egg'));
    expect(meal.summaryLine, contains('Egg white'));
    expect(meal.summaryLine, contains(' g'));
    final whole = meal.items.firstWhere((i) => i.food.sourceNote == 'local:egg_whole');
    final white = meal.items.firstWhere((i) => i.food.sourceNote == 'local:egg_white');
    expect(whole.quantityLabel, isNotNull);
    expect(whole.quantityLabel, isNot(contains(' g')));
    expect(white.quantityLabel, isNull);
  });

  test('chicken salmon beef portions are 165 g', () {
    final svc = MealSuggestionService();
    for (final slot in ['m2', 'm3', 'm5']) {
      final meal = svc.suggestionForSlot(
        profile: profile,
        trainingDay: false,
        slotId: slot,
      );
      expect(meal, isNotNull);
      final meat = meal!.items.firstWhere(
        (i) =>
            i.food.sourceNote == 'local:chicken_breast_roasted' ||
            i.food.sourceNote == 'local:salmon_raw' ||
            i.food.sourceNote == 'local:beef_sirloin_raw',
      );
      expect(meat.grams, MealSuggestionService.standardMeatPortionG);
    }
  });
}
