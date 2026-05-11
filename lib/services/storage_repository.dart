import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_entry.dart';
import '../models/user_profile.dart';
import '../models/workout_entry.dart';

class StorageRepository {
  static const _profileKey = 'user_profile_v1';
  static const _mealsKey = 'meals_v1';
  static const _workoutsKey = 'workouts_v1';

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
}
