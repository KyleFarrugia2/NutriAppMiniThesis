import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'models/meal_entry.dart';
import 'models/user_profile.dart';
import 'models/workout_entry.dart';
import 'models/weekly_workout_program.dart';
import 'services/personalization_engine.dart';
import 'services/progression_service.dart';
import 'services/storage_repository.dart';

/// Stored on [WorkoutEntry.logSource] for mirrored program completions.
const String kWeeklyProgramLogSource = 'weekly_program';

class AppState extends ChangeNotifier {
  AppState({
    StorageRepository? storage,
    PersonalizationEngine? engine,
  })  : _storage = storage ?? StorageRepository(),
        _engine = engine ?? const PersonalizationEngine();

  final StorageRepository _storage;
  final PersonalizationEngine _engine;
  final _uuid = Uuid();

  UserProfile? profile;
  List<MealEntry> meals = [];
  List<WorkoutEntry> workouts = [];
  bool loaded = false;

  /// Editable Mon–Sun template (exercises + rest days).
  WeeklyWorkoutPlan weeklyPlan = WeeklyWorkoutPlan.defaultSuggested();

  /// Logged program sessions (weight × reps per set).
  List<ProgramWorkoutSession> programSessions = [];

  /// User closed the “suggested program” banner on the Workouts tab.
  bool workoutSuggestedNoteDismissed = false;

  /// User dismissed the dashboard nutrition insight card.
  bool nutritionInsightCardDismissed = false;

  /// User dismissed the dashboard “Suggested next workout” card.
  bool dashboardWorkoutSuggestionDismissed = false;

  /// User dismissed the Workouts tab “Coach suggestion” card.
  bool workoutCoachSuggestionDismissed = false;

  /// User hid per-slot “Suggested ~ kcal …” lines on the Nutrition tab.
  bool mealSlotMacroSuggestionsHidden = false;

  bool get hasDismissedSuggestionContent =>
      nutritionInsightCardDismissed ||
      dashboardWorkoutSuggestionDismissed ||
      workoutCoachSuggestionDismissed ||
      mealSlotMacroSuggestionsHidden;

  /// USDA FoodData Central API key (optional). Also reads `USDA_API_KEY` dart-define if unset.
  String? usdaFdcApiKey;

  /// `yyyy-MM-dd` → training layout (M1–3 + pre/post). Absent entries = **rest** (M1–5).
  Map<String, bool> trainingDayByDate = {};

  int totalPlayerXp = 0;
  Set<String> mealXpAwardedDays = {};
  Map<String, int> workoutXpGrantsByDay = {};

  PersonalizationEngine get engine => _engine;

  ProgressionSnapshot get progressionSnapshot =>
      ProgressionService.snapshot(totalPlayerXp);

  bool get hasUsdaApiKey =>
      usdaFdcApiKey != null && usdaFdcApiKey!.trim().isNotEmpty;

  Future<void> bootstrap() async {
    profile = await _storage.loadProfile();
    meals = await _storage.loadMeals();
    workouts = await _storage.loadWorkouts();
    usdaFdcApiKey = await _storage.loadUsdaApiKey();
    trainingDayByDate = await _storage.loadTrainingDayFlags();
    weeklyPlan =
        await _storage.loadWeeklyWorkoutPlan() ?? WeeklyWorkoutPlan.defaultSuggested();
    programSessions = await _storage.loadProgramWorkoutSessions();
    workoutSuggestedNoteDismissed =
        await _storage.loadWorkoutSuggestedNoteDismissed();
    nutritionInsightCardDismissed =
        await _storage.loadNutritionInsightCardDismissed();
    dashboardWorkoutSuggestionDismissed =
        await _storage.loadDashboardWorkoutSuggestionDismissed();
    workoutCoachSuggestionDismissed =
        await _storage.loadWorkoutCoachSuggestionDismissed();
    mealSlotMacroSuggestionsHidden =
        await _storage.loadMealSlotMacroSuggestionsHidden();
    totalPlayerXp = await _storage.loadPlayerTotalXp();
    mealXpAwardedDays = await _storage.loadPlayerMealXpDays();
    workoutXpGrantsByDay = await _storage.loadPlayerWorkoutXpGrants();
    if (!hasUsdaApiKey) {
      const env = String.fromEnvironment('USDA_API_KEY', defaultValue: '');
      if (env.isNotEmpty) {
        usdaFdcApiKey = env;
      }
    }
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
    final dayKey = dateKey(m.loggedAt);
    final firstMealOfDay = _engine.mealsForDay(meals, m.loggedAt).isEmpty;
    meals = [m, ...meals];
    await _storage.saveMeals(meals);
    if (firstMealOfDay && !mealXpAwardedDays.contains(dayKey)) {
      mealXpAwardedDays = {...mealXpAwardedDays, dayKey};
      totalPlayerXp += ProgressionService.mealDayXp;
      await _persistPlayerProgress();
    }
    notifyListeners();
  }

  Future<void> addWorkout(WorkoutEntry w) async {
    workouts = [w, ...workouts];
    await _storage.saveWorkouts(workouts);
    await _tryGrantWorkoutXp(
      w.completedAt,
      fromProgram: w.logSource == kWeeklyProgramLogSource,
    );
    notifyListeners();
  }

  Future<void> removeMeal(String id) async {
    meals = meals.where((m) => m.id != id).toList();
    await _storage.saveMeals(meals);
    notifyListeners();
  }

  Future<void> removeWorkout(String id) async {
    workouts = workouts.where((w) => w.id != id).toList();
    await _storage.saveWorkouts(workouts);
    notifyListeners();
  }

  ProgramWorkoutSession? programSessionForCalendarDay(DateTime d) {
    final k = dateKey(d);
    for (final s in programSessions) {
      if (dateKey(s.performedOn) == k) return s;
    }
    return null;
  }

  /// Same calendar weekday, **one week earlier** (for pre-fill).
  ProgramWorkoutSession? programSessionOneWeekBefore(DateTime d) {
    return programSessionForCalendarDay(d.subtract(const Duration(days: 7)));
  }

  Future<void> setWeeklyWorkoutPlan(WeeklyWorkoutPlan plan) async {
    weeklyPlan = plan;
    await _storage.saveWeeklyWorkoutPlan(plan);
    notifyListeners();
  }

  Future<void> saveProgramWorkoutSession(ProgramWorkoutSession session) async {
    final k = dateKey(session.performedOn);
    programSessions = [
      session,
      ...programSessions.where((s) => dateKey(s.performedOn) != k),
    ];
    await _storage.saveProgramWorkoutSessions(programSessions);

    workouts = workouts
        .where((w) =>
            !(w.logSource == kWeeklyProgramLogSource && dateKey(w.completedAt) == k))
        .toList();
    workouts = [
      WorkoutEntry(
        id: _uuid.v4(),
        title: session.planDayTitle,
        type: WorkoutType.strength,
        durationMinutes: session.durationMinutes ?? 50,
        completedAt: session.completedAt,
        rpe: null,
        notes: 'Program · ${session.exercises.length} lifts',
        logSource: kWeeklyProgramLogSource,
      ),
      ...workouts,
    ];
    await _storage.saveWorkouts(workouts);
    await _tryGrantWorkoutXp(session.completedAt, fromProgram: true);
    notifyListeners();
  }

  Future<void> removeProgramWorkoutSession(String id) async {
    final removed = programSessions.where((s) => s.id == id).toList();
    programSessions = programSessions.where((s) => s.id != id).toList();
    await _storage.saveProgramWorkoutSessions(programSessions);
    if (removed.isEmpty) {
      notifyListeners();
      return;
    }
    final dayKey = dateKey(removed.first.performedOn);
    workouts = workouts
        .where((w) =>
            !(w.logSource == kWeeklyProgramLogSource && dateKey(w.completedAt) == dayKey))
        .toList();
    await _storage.saveWorkouts(workouts);
    notifyListeners();
  }

  Future<void> _persistPlayerProgress() async {
    await Future.wait([
      _storage.savePlayerTotalXp(totalPlayerXp),
      _storage.savePlayerMealXpDays(mealXpAwardedDays),
      _storage.savePlayerWorkoutXpGrants(workoutXpGrantsByDay),
    ]);
  }

  Future<void> _tryGrantWorkoutXp(DateTime completedAt, {required bool fromProgram}) async {
    final day = dateKey(completedAt);
    final n = workoutXpGrantsByDay[day] ?? 0;
    if (n >= 2) return;
    final xp = n == 0
        ? ProgressionService.workoutFirstDailyXp +
            (fromProgram ? ProgressionService.programSessionFirstDailyBonus : 0)
        : ProgressionService.workoutSecondDailyXp;
    final next = Map<String, int>.from(workoutXpGrantsByDay);
    next[day] = n + 1;
    workoutXpGrantsByDay = next;
    totalPlayerXp += xp;
    await _persistPlayerProgress();
  }

  Future<void> setUsdaFdcApiKey(String? key) async {
    await _storage.saveUsdaApiKey(key);
    usdaFdcApiKey = await _storage.loadUsdaApiKey();
    notifyListeners();
  }

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Training = M1–M3 + pre/post. Default **rest** (M1–M5) until user toggles this date.
  bool isTrainingDay(DateTime d) => trainingDayByDate[dateKey(d)] ?? false;

  Future<void> setTrainingDay(DateTime d, bool training) async {
    final k = dateKey(d);
    trainingDayByDate = Map<String, bool>.from(trainingDayByDate);
    trainingDayByDate[k] = training;
    await _storage.saveTrainingDayFlags(trainingDayByDate);
    notifyListeners();
  }

  DailyNutritionSummary? daySummary(DateTime day) {
    final p = profile;
    if (p == null) return null;
    final list = _engine.mealsForDay(meals, day);
    return _engine.summarizeDay(
      p,
      list,
      trainingDay: isTrainingDay(day),
    );
  }

  /// Full-day calorie & macro **targets** for [day] (no meals applied).
  /// Reflects training vs rest flags for that date.
  DailyNutritionSummary? dailyTargets(DateTime day) {
    final p = profile;
    if (p == null) return null;
    return _engine.summarizeDay(
      p,
      const [],
      trainingDay: isTrainingDay(day),
    );
  }

  List<MealEntry> mealsOnDay(DateTime day) => _engine.mealsForDay(meals, day);

  DailyNutritionSummary? todaySummary() {
    final p = profile;
    if (p == null) return null;
    final now = DateTime.now();
    final day = _engine.mealsForDay(meals, now);
    return _engine.summarizeDay(
      p,
      day,
      trainingDay: isTrainingDay(now),
    );
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

  /// True when profile average steps are missing or below [kRecommendedMinDailySteps]
  /// and the user has not dismissed the nudge for today.
  Future<bool> shouldOfferStepsNudge() async {
    final p = profile;
    if (p == null) return false;
    final steps = p.wearableStepsAvg;
    if (steps != null && steps >= kRecommendedMinDailySteps) return false;
    final dismissed = await _storage.loadStepsNudgeDismissDate();
    return dismissed != dateKey(DateTime.now());
  }

  Future<void> dismissStepsNudgeForToday() async {
    await _storage.saveStepsNudgeDismissDate(dateKey(DateTime.now()));
  }

  Future<void> dismissWorkoutSuggestedNote() async {
    workoutSuggestedNoteDismissed = true;
    await _storage.saveWorkoutSuggestedNoteDismissed(true);
    notifyListeners();
  }

  Future<void> dismissNutritionInsightCard() async {
    nutritionInsightCardDismissed = true;
    await _storage.saveNutritionInsightCardDismissed(true);
    notifyListeners();
  }

  Future<void> dismissDashboardWorkoutSuggestion() async {
    dashboardWorkoutSuggestionDismissed = true;
    await _storage.saveDashboardWorkoutSuggestionDismissed(true);
    notifyListeners();
  }

  Future<void> dismissWorkoutCoachSuggestion() async {
    workoutCoachSuggestionDismissed = true;
    await _storage.saveWorkoutCoachSuggestionDismissed(true);
    notifyListeners();
  }

  Future<void> dismissMealSlotMacroSuggestions() async {
    mealSlotMacroSuggestionsHidden = true;
    await _storage.saveMealSlotMacroSuggestionsHidden(true);
    notifyListeners();
  }

  /// Shows again: dashboard insight cards, coach suggestion, nutrition slot lines.
  Future<void> restoreDismissedSuggestions() async {
    nutritionInsightCardDismissed = false;
    dashboardWorkoutSuggestionDismissed = false;
    workoutCoachSuggestionDismissed = false;
    mealSlotMacroSuggestionsHidden = false;
    await Future.wait([
      _storage.saveNutritionInsightCardDismissed(false),
      _storage.saveDashboardWorkoutSuggestionDismissed(false),
      _storage.saveWorkoutCoachSuggestionDismissed(false),
      _storage.saveMealSlotMacroSuggestionsHidden(false),
    ]);
    notifyListeners();
  }
}
