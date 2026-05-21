import '../models/food_reference.dart';
import '../models/user_profile.dart';
import '../utils/egg_portions.dart';
import 'local_food_catalog.dart';
import 'meal_plan_layout.dart';
import 'personalization_engine.dart';

/// One auto-built meal for a daily slot (user can accept to log in one tap).
class SuggestedMeal {
  const SuggestedMeal({
    required this.slotId,
    required this.title,
    required this.items,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
  });

  final String slotId;
  final String title;
  final List<SuggestedMealItem> items;
  final int totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;

  String get summaryLine {
    final parts = items.map((i) {
      if (i.quantityLabel != null) return i.quantityLabel!;
      return '${_shortName(i.food.name)} (${i.grams.round()} g)';
    }).join(' · ');
    return parts;
  }

  static String _shortName(String name) {
    final comma = name.indexOf(',');
    if (comma > 0 && comma < 40) return name.substring(0, comma);
    if (name.length > 36) return '${name.substring(0, 33)}…';
    return name;
  }
}

class SuggestedMealItem {
  const SuggestedMealItem({
    required this.food,
    required this.grams,
    this.quantityLabel,
  });

  final FoodReference food;
  final double grams;

  /// e.g. "2 whole eggs" — shown instead of grams for eggs.
  final String? quantityLabel;
}

class MealSuggestionService {
  const MealSuggestionService({PersonalizationEngine? engine})
      : _engine = engine ?? const PersonalizationEngine();

  final PersonalizationEngine _engine;

  /// Standard cooked portion for chicken, salmon, and beef (~35–51 g protein by food).
  static const double standardMeatPortionG = 165;

  FoodReference? _food(String key) => LocalFoodCatalog.findBySourceNote(key);

  /// Builds suggestions for every slot on a day (training vs rest layout).
  Map<String, SuggestedMeal> suggestionsForDay({
    required UserProfile profile,
    required bool trainingDay,
  }) {
    final layout =
        trainingDay ? MealSlotDef.training() : MealSlotDef.rest();

    final summary = _engine.summarizeDay(
      profile,
      const [],
      trainingDay: trainingDay,
    );

    final out = <String, SuggestedMeal>{};
    for (final slot in layout) {
      final sug = MealSlotDef.suggestedMacros(slot: slot, targets: summary);
      final meal = _buildSlotMeal(
        slotId: slot.id,
        slotTitle: slot.title,
        targetKcal: sug.kcal,
        targetP: sug.p,
        targetC: sug.c,
        targetF: sug.f,
        profile: profile,
      );
      if (meal != null) out[slot.id] = meal;
    }
    return out;
  }

  SuggestedMeal? suggestionForSlot({
    required UserProfile profile,
    required bool trainingDay,
    required String slotId,
  }) {
    return suggestionsForDay(profile: profile, trainingDay: trainingDay)[slotId];
  }

  SuggestedMeal? _buildSlotMeal({
    required String slotId,
    required String slotTitle,
    required int targetKcal,
    required int targetP,
    required int targetC,
    required int targetF,
    required UserProfile profile,
  }) {
    return switch (slotId) {
      'm1' => _buildBreakfast(
        slotTitle: slotTitle,
        targetKcal: targetKcal,
        targetP: targetP,
        targetC: targetC,
        profile: profile,
      ),
      'm2' => _buildMeatMeal(
        slotId: slotId,
        slotTitle: slotTitle,
        meatKey: 'local:chicken_breast_roasted',
        carbKey: 'local:white_rice_cooked',
        vegKey: 'local:broccoli_boiled',
        targetKcal: targetKcal,
        targetP: targetP,
        targetC: targetC,
      ),
      'm3' => _buildMeatMeal(
        slotId: slotId,
        slotTitle: slotTitle,
        meatKey: 'local:salmon_raw',
        carbKey: 'local:sweet_potato',
        vegKey: 'local:spinach_raw',
        targetKcal: targetKcal,
        targetP: targetP,
        targetC: targetC,
      ),
      'm5' => _buildMeatMeal(
        slotId: slotId,
        slotTitle: slotTitle,
        meatKey: 'local:beef_sirloin_raw',
        carbKey: 'local:brown_rice_cooked',
        vegKey: 'local:tomato',
        targetKcal: targetKcal,
        targetP: targetP,
        targetC: targetC,
      ),
      'm4' => _buildSnackMeal(
        slotId: slotId,
        slotTitle: slotTitle,
        targetKcal: targetKcal,
        targetP: targetP,
        targetC: targetC,
      ),
      'pre' => _buildPreWorkout(
        slotTitle: slotTitle,
        targetKcal: targetKcal,
        targetC: targetC,
      ),
      'post' => _buildMeatMeal(
        slotId: slotId,
        slotTitle: slotTitle,
        meatKey: 'local:chicken_breast_roasted',
        carbKey: 'local:white_rice_cooked',
        vegKey: 'local:broccoli_boiled',
        targetKcal: targetKcal,
        targetP: targetP,
        targetC: targetC,
      ),
      _ => null,
    };
  }

  /// Meal 1: whole eggs + egg whites (protein) + oats (carbs only).
  SuggestedMeal? _buildBreakfast({
    required String slotTitle,
    required int targetKcal,
    required int targetP,
    required int targetC,
    required UserProfile profile,
  }) {
    final whole = _food('local:egg_whole');
    final white = _food('local:egg_white');
    final oats = _food('local:oats_dry');
    if (whole == null || white == null) return null;

    // Scale egg counts (not grams) to hit most of the slot's protein target.
    final eggProteinTarget = targetP * 0.88;
    final wholeShare = profile.goal == NutritionGoal.loseWeight ? 0.4 : 0.55;

    final proteinPerWhole =
        whole.proteinPer100g * EggPortions.gramsPerWholeEgg / 100;

    final wholeCount = proteinPerWhole > 0
        ? (eggProteinTarget * wholeShare / proteinPerWhole).round().clamp(1, 6)
        : 2;

    final wholeG = EggPortions.gramsForWholeEggCount(wholeCount);
    var whiteG = white.proteinPer100g > 0
        ? (eggProteinTarget * (1 - wholeShare) / white.proteinPer100g * 100)
        : 80.0;
    whiteG = whiteG.clamp(60.0, 350.0);

    final items = <SuggestedMealItem>[
      SuggestedMealItem(
        food: whole,
        grams: wholeG,
        quantityLabel: EggPortions.formatWholeEggs(wholeCount),
      ),
      SuggestedMealItem(
        food: white,
        grams: whiteG,
      ),
    ];

    var totals = _sumItems(items);

    // Fill remaining carbs/calories with oats (not counted as protein).
    if (oats != null) {
      var carbGap = (targetC - totals.carbsG).clamp(15.0, 120.0);
      var kcalGap = (targetKcal - totals.calories).clamp(80.0, 600.0);
      var oatsG = 0.0;
      if (oats.carbsPer100g > 0) {
        oatsG = carbGap / oats.carbsPer100g * 100;
      }
      if (oats.kcalPer100g > 0) {
        final kcalBased = kcalGap / oats.kcalPer100g * 100;
        oatsG = oatsG > 0 ? (oatsG + kcalBased) / 2 : kcalBased;
      }
      oatsG = oatsG.clamp(25.0, 90.0);
      items.add(SuggestedMealItem(food: oats, grams: oatsG));
      totals = _sumItems(items);
    }

    return SuggestedMeal(
      slotId: 'm1',
      title: 'Suggested $slotTitle',
      items: items,
      totalCalories: totals.calories.round(),
      totalProteinG: totals.proteinG,
      totalCarbsG: totals.carbsG,
      totalFatG: totals.fatG,
    );
  }

  /// Chicken / salmon / beef at [standardMeatPortionG] + carb + veg scaled to slot.
  SuggestedMeal? _buildMeatMeal({
    required String slotId,
    required String slotTitle,
    required String meatKey,
    required String carbKey,
    required String vegKey,
    required int targetKcal,
    required int targetP,
    required int targetC,
  }) {
    final meat = _food(meatKey);
    final carb = _food(carbKey);
    final veg = _food(vegKey);
    if (meat == null) return null;

    final items = <SuggestedMealItem>[
      SuggestedMealItem(food: meat, grams: standardMeatPortionG),
    ];
    var totals = _sumItems(items);

    if (carb != null) {
      final carbGap = (targetC - totals.carbsG).clamp(10.0, 150.0);
      final kcalGap = (targetKcal - totals.calories).clamp(50.0, 500.0);
      var carbG = carb.carbsPer100g > 0
          ? carbGap / carb.carbsPer100g * 100
          : 80.0;
      if (carb.kcalPer100g > 0) {
        final fromKcal = kcalGap / carb.kcalPer100g * 100;
        carbG = (carbG + fromKcal) / 2;
      }
      carbG = carbG.clamp(40.0, 320.0);
      items.add(SuggestedMealItem(food: carb, grams: carbG));
      totals = _sumItems(items);
    }

    if (veg != null) {
      items.add(SuggestedMealItem(food: veg, grams: 80));
      totals = _sumItems(items);
    }

    return SuggestedMeal(
      slotId: slotId,
      title: 'Suggested $slotTitle',
      items: items,
      totalCalories: totals.calories.round(),
      totalProteinG: totals.proteinG,
      totalCarbsG: totals.carbsG,
      totalFatG: totals.fatG,
    );
  }

  SuggestedMeal? _buildSnackMeal({
    required String slotId,
    required String slotTitle,
    required int targetKcal,
    required int targetP,
    required int targetC,
  }) {
    final yogurt = _food('local:greek_yogurt_nf');
    final berries = _food('local:blueberries');
    if (yogurt == null) return null;

    final yogurtG = (targetP * 0.5 / yogurt.proteinPer100g * 100).clamp(80.0, 250.0);
    final items = <SuggestedMealItem>[
      SuggestedMealItem(food: yogurt, grams: yogurtG),
    ];
    if (berries != null) {
      items.add(SuggestedMealItem(food: berries, grams: 60));
    }
    final totals = _sumItems(items);
    return SuggestedMeal(
      slotId: slotId,
      title: 'Suggested $slotTitle',
      items: items,
      totalCalories: totals.calories.round(),
      totalProteinG: totals.proteinG,
      totalCarbsG: totals.carbsG,
      totalFatG: totals.fatG,
    );
  }

  /// Pre-workout: carbs only (no inflated protein from oats).
  SuggestedMeal? _buildPreWorkout({
    required String slotTitle,
    required int targetKcal,
    required int targetC,
  }) {
    final banana = _food('local:banana');
    final oats = _food('local:oatmeal_cooked');
    if (banana == null && oats == null) return null;

    final items = <SuggestedMealItem>[];
    if (banana != null) {
      items.add(SuggestedMealItem(food: banana, grams: 100));
    }
    if (oats != null) {
      final carbG = (targetC * 0.55 / oats.carbsPer100g * 100).clamp(80.0, 220.0);
      items.add(SuggestedMealItem(food: oats, grams: carbG));
    }
    final totals = _sumItems(items);
    return SuggestedMeal(
      slotId: 'pre',
      title: 'Suggested $slotTitle',
      items: items,
      totalCalories: totals.calories.round(),
      totalProteinG: totals.proteinG,
      totalCarbsG: totals.carbsG,
      totalFatG: totals.fatG,
    );
  }

  static ({
    double calories,
    double proteinG,
    double carbsG,
    double fatG,
  }) _sumItems(List<SuggestedMealItem> items) {
    var cal = 0.0;
    var p = 0.0;
    var c = 0.0;
    var f = 0.0;
    for (final i in items) {
      final s = i.food.scaledForGrams(i.grams);
      cal += s.calories;
      p += s.proteinG;
      c += s.carbsG;
      f += s.fatG;
    }
    return (calories: cal, proteinG: p, carbsG: c, fatG: f);
  }
}
