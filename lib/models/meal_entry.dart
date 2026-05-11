class MealEntry {
  MealEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.loggedAt,
    this.imageNote,
  });

  final String id;
  final String name;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final DateTime loggedAt;

  /// Placeholder for food-image pipeline (thesis: CV + nutrient estimation).
  final String? imageNote;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'loggedAt': loggedAt.toIso8601String(),
        'imageNote': imageNote,
      };

  static MealEntry fromJson(Map<String, dynamic> j) {
    return MealEntry(
      id: j['id'] as String,
      name: j['name'] as String,
      calories: (j['calories'] as num).toInt(),
      proteinG: (j['proteinG'] as num).toDouble(),
      carbsG: (j['carbsG'] as num).toDouble(),
      fatG: (j['fatG'] as num).toDouble(),
      loggedAt: DateTime.parse(j['loggedAt'] as String),
      imageNote: j['imageNote'] as String?,
    );
  }
}
