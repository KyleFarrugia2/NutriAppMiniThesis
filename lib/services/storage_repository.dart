import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_entry.dart';
import '../models/user_profile.dart';
import '../models/workout_entry.dart';
import '../models/weekly_workout_program.dart';

class StorageRepository {
  static const _profileKey = 'user_profile_v1';
  static const _mealsKey = 'meals_v1';
  static const _workoutsKey = 'workouts_v1';
  static const _weeklyPlanKey = 'weekly_workout_plan_v1';
  static const _programSessionsKey = 'program_workout_sessions_v1';
  static const _usdaApiKey = 'usda_fdc_api_key_v1';
  static const _trainingDaysKey = 'training_day_flags_v1';
  static const _stepsNudgeDismissYmdKey = 'steps_nudge_dismiss_ymd_v1';
  static const _workoutSuggestedNoteDismissedKey =
      'workout_suggested_note_dismissed_v1';
  static const _nutritionInsightCardDismissedKey =
      'nutrition_insight_card_dismissed_v1';
  static const _dashboardWorkoutSuggestionDismissedKey =
      'dashboard_workout_suggestion_dismissed_v1';
  static const _workoutCoachSuggestionDismissedKey =
      'workout_coach_suggestion_dismissed_v1';
  static const _mealSlotMacroSuggestionsHiddenKey =
      'meal_slot_macro_suggestions_hidden_v1';
  static const _playerTotalXpKey = 'player_total_xp_v1';
  static const _playerMealXpDaysKey = 'player_meal_xp_days_v1';
  static const _playerWorkoutXpGrantsKey = 'player_workout_xp_grants_v1';

  Future<UserProfile?> loadProfile() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_profileKey);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_profileKey, jsonEncode(p.toJson()));
  }

  Future<List<MealEntry>> loadMeals() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_mealsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMeals(List<MealEntry> meals) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _mealsKey,
      jsonEncode(meals.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<WorkoutEntry>> loadWorkouts() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_workoutsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WorkoutEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWorkouts(List<WorkoutEntry> w) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _workoutsKey,
      jsonEncode(w.map((e) => e.toJson()).toList()),
    );
  }

  Future<WeeklyWorkoutPlan?> loadWeeklyWorkoutPlan() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_weeklyPlanKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return WeeklyWorkoutPlan.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveWeeklyWorkoutPlan(WeeklyWorkoutPlan plan) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_weeklyPlanKey, jsonEncode(plan.toJson()));
  }

  Future<List<ProgramWorkoutSession>> loadProgramWorkoutSessions() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_programSessionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ProgramWorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProgramWorkoutSessions(List<ProgramWorkoutSession> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _programSessionsKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<String?> loadUsdaApiKey() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_usdaApiKey);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  Future<void> saveUsdaApiKey(String? key) async {
    final sp = await SharedPreferences.getInstance();
    if (key == null || key.trim().isEmpty) {
      await sp.remove(_usdaApiKey);
    } else {
      await sp.setString(_usdaApiKey, key.trim());
    }
  }

  Future<Map<String, bool>> loadTrainingDayFlags() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_trainingDaysKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};
    return decoded.map((k, v) => MapEntry(k, v == true));
  }

  Future<void> saveTrainingDayFlags(Map<String, bool> flags) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_trainingDaysKey, jsonEncode(flags));
  }

  Future<String?> loadStepsNudgeDismissDate() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_stepsNudgeDismissYmdKey);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  Future<void> saveStepsNudgeDismissDate(String ymd) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_stepsNudgeDismissYmdKey, ymd);
  }

  Future<bool> loadWorkoutSuggestedNoteDismissed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_workoutSuggestedNoteDismissedKey) ?? false;
  }

  Future<void> saveWorkoutSuggestedNoteDismissed(bool dismissed) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_workoutSuggestedNoteDismissedKey, dismissed);
  }

  Future<bool> loadNutritionInsightCardDismissed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_nutritionInsightCardDismissedKey) ?? false;
  }

  Future<void> saveNutritionInsightCardDismissed(bool dismissed) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_nutritionInsightCardDismissedKey, dismissed);
  }

  Future<bool> loadDashboardWorkoutSuggestionDismissed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_dashboardWorkoutSuggestionDismissedKey) ?? false;
  }

  Future<void> saveDashboardWorkoutSuggestionDismissed(bool dismissed) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_dashboardWorkoutSuggestionDismissedKey, dismissed);
  }

  Future<bool> loadWorkoutCoachSuggestionDismissed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_workoutCoachSuggestionDismissedKey) ?? false;
  }

  Future<void> saveWorkoutCoachSuggestionDismissed(bool dismissed) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_workoutCoachSuggestionDismissedKey, dismissed);
  }

  Future<bool> loadMealSlotMacroSuggestionsHidden() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_mealSlotMacroSuggestionsHiddenKey) ?? false;
  }

  Future<void> saveMealSlotMacroSuggestionsHidden(bool hidden) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_mealSlotMacroSuggestionsHiddenKey, hidden);
  }

  Future<int> loadPlayerTotalXp() async {
    final sp = await SharedPreferences.getInstance();
    return (sp.getInt(_playerTotalXpKey) ?? 0).clamp(0, 1 << 30);
  }

  Future<void> savePlayerTotalXp(int xp) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_playerTotalXpKey, xp.clamp(0, 1 << 30));
  }

  Future<Set<String>> loadPlayerMealXpDays() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_playerMealXpDaysKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> savePlayerMealXpDays(Set<String> days) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _playerMealXpDaysKey,
      jsonEncode(days.toList()..sort()),
    );
  }

  Future<Map<String, int>> loadPlayerWorkoutXpGrants() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_playerWorkoutXpGrantsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toInt().clamp(0, 99)));
    } catch (_) {
      return {};
    }
  }

  Future<void> savePlayerWorkoutXpGrants(Map<String, int> grants) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_playerWorkoutXpGrantsKey, jsonEncode(grants));
  }
}
