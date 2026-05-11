import 'package:flutter/foundation.dart';

import 'models/meal_entry.dart';
import 'models/user_profile.dart';
import 'models/workout_entry.dart';
import 'services/personalization_engine.dart';
import 'services/storage_repository.dart';

class AppState extends ChangeNotifier {
  AppState({
    StorageRepository? storage,
    PersonalizationEngine? engine,
  })  : _storage = storage ?? StorageRepository(),
        _engine = engine ?? const PersonalizationEngine();

  final StorageRepository _storage;
  final PersonalizationEngine _engine;

  UserProfile? profile;
  List<MealEntry> meals = [];
  List<WorkoutEntry> workouts = [];
  bool loaded = false;

  PersonalizationEngine get engine => _engine;

  Future<void> bootstrap() async {
    profile = await _storage.loadProfile();
    meals = await _storage.loadMeals();
    workouts = await _storage.loadWorkouts();
    loaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding(UserProfile p) async {
    profile = p;
    await _storage.saveProfile(p);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile p) async {
    profile = p;
    await _storage.saveProfile(p);
    notifyListeners();
  }

  Future<void> addMeal(MealEntry m) async {
    meals = [m, ...meals];
    await _storage.saveMeals(meals);
    notifyListeners();
  }

  Future<void> addWorkout(WorkoutEntry w) async {
    workouts = [w, ...workouts];
    await _storage.saveWorkouts(workouts);
    notifyListeners();
  }

  DailyNutritionSummary? todaySummary() {
    final p = profile;
    if (p == null) return null;
    final day = _engine.mealsForDay(meals, DateTime.now());
    return _engine.summarizeDay(p, day);
  }

  WorkoutRecommendation? workoutSuggestion() {
    final p = profile;
    if (p == null) return null;
    return _engine.nextWorkoutSuggestion(p, workouts);
  }

  String? nutritionInsight() {
    final p = profile;
    final s = todaySummary();
    if (p == null || s == null) return null;
    return _engine.nutritionInsight(p, s);
  }
}
