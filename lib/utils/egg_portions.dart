import '../models/food_reference.dart';

/// Whole eggs by count; egg whites stay in grams.
class EggPortions {
  EggPortions._();

  static const double gramsPerWholeEgg = 50;
  static const double gramsPerEggWhite = 33;

  static bool isWholeEgg(FoodReference food) =>
      food.sourceNote == 'local:egg_whole';

  static bool isEggWhite(FoodReference food) =>
      food.sourceNote == 'local:egg_white';

  static bool isCountedByPiece(FoodReference food) => isWholeEgg(food);

  static double gramsForWholeEggCount(int count) => count * gramsPerWholeEgg;

  static String formatWholeEggs(int count) =>
      count == 1 ? '1 whole egg' : '$count whole eggs';

  /// Log name for [MealEntry] when adding whole eggs by count.
  static String mealNameForWholeEggs(int count) => formatWholeEggs(count);
}
