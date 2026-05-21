/// USDA search row before a detail fetch fills [FoodReference].
class FoodSearchHit {
  const FoodSearchHit({required this.fdcId, required this.description});

  final int fdcId;
  final String description;
}

/// Normalised edible nutrition **per 100 g** (or equivalent basis from USDA FDC).
class FoodReference {
  const FoodReference({
    this.fdcId,
    required this.name,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.sourceNote,
  });

  /// USDA FDC identifier when from API; null for built-in catalog rows.
  final int? fdcId;
  final String name;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  /// e.g. `fdc:12345` or `local:chicken_breast` for [MealEntry.imageNote].
  final String? sourceNote;

  /// Scale macros for [grams] of this food (linear from per-100 g basis).
  ({
    int calories,
    double proteinG,
    double carbsG,
    double fatG,
  }) scaledForGrams(double grams) {
    final f = grams / 100.0;
    return (
      calories: (kcalPer100g * f).round().clamp(0, 20000),
      proteinG: (proteinPer100g * f).clamp(0, 2000),
      carbsG: (carbsPer100g * f).clamp(0, 2000),
      fatG: (fatPer100g * f).clamp(0, 2000),
    );
  }
}
