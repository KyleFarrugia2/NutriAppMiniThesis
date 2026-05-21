/// Informal metrics for thesis research questions (stored on device).
class ResearchStudyRecord {
  const ResearchStudyRecord({
    this.adaptiveMealsLogged = 0,
    this.adaptiveWorkoutsLogged = 0,
    this.adaptiveSuggestionsAccepted = 0,
    this.fixedMealsLogged = 0,
    this.fixedWorkoutsLogged = 0,
    this.fixedSuggestionsAccepted = 0,
    this.imageAssistedMealsLogged = 0,
    this.manualMealsLogged = 0,
    this.sequentialWorkoutsLogged = 0,
    this.nonSequentialWorkoutsLogged = 0,
    this.mealSearchTaskMs,
    this.manualMealTaskMs,
    this.workoutLogTaskMs,
    this.usabilityEase,
    this.usabilityClarity,
    this.usabilityWouldUseAgain,
    this.usabilityComment = '',
    this.rq1AdaptiveChecklist = false,
    this.rq1FixedChecklist = false,
    this.rq2UsabilityChecklist = false,
  });

  final int adaptiveMealsLogged;
  final int adaptiveWorkoutsLogged;
  final int adaptiveSuggestionsAccepted;
  final int fixedMealsLogged;
  final int fixedWorkoutsLogged;
  final int fixedSuggestionsAccepted;
  final int imageAssistedMealsLogged;
  final int manualMealsLogged;
  final int sequentialWorkoutsLogged;
  final int nonSequentialWorkoutsLogged;
  final int? mealSearchTaskMs;
  final int? manualMealTaskMs;
  final int? workoutLogTaskMs;
  final int? usabilityEase;
  final int? usabilityClarity;
  final int? usabilityWouldUseAgain;
  final String usabilityComment;
  final bool rq1AdaptiveChecklist;
  final bool rq1FixedChecklist;
  final bool rq2UsabilityChecklist;

  static const empty = ResearchStudyRecord();

  bool get rq1HasAdaptiveData =>
      adaptiveMealsLogged > 0 || adaptiveWorkoutsLogged > 0;
  bool get rq1HasFixedData => fixedMealsLogged > 0 || fixedWorkoutsLogged > 0;

  bool get rq1Answerable => rq1HasAdaptiveData && rq1HasFixedData;

  bool get rq2Answerable =>
      imageAssistedMealsLogged > 0 &&
      manualMealsLogged > 0 &&
      mealSearchTaskMs != null &&
      usabilityEase != null;

  ResearchStudyRecord copyWith({
    int? adaptiveMealsLogged,
    int? adaptiveWorkoutsLogged,
    int? adaptiveSuggestionsAccepted,
    int? fixedMealsLogged,
    int? fixedWorkoutsLogged,
    int? fixedSuggestionsAccepted,
    int? imageAssistedMealsLogged,
    int? manualMealsLogged,
    int? sequentialWorkoutsLogged,
    int? nonSequentialWorkoutsLogged,
    int? mealSearchTaskMs,
    int? manualMealTaskMs,
    int? workoutLogTaskMs,
    int? usabilityEase,
    int? usabilityClarity,
    int? usabilityWouldUseAgain,
    String? usabilityComment,
    bool? rq1AdaptiveChecklist,
    bool? rq1FixedChecklist,
    bool? rq2UsabilityChecklist,
  }) {
    return ResearchStudyRecord(
      adaptiveMealsLogged: adaptiveMealsLogged ?? this.adaptiveMealsLogged,
      adaptiveWorkoutsLogged:
          adaptiveWorkoutsLogged ?? this.adaptiveWorkoutsLogged,
      adaptiveSuggestionsAccepted: adaptiveSuggestionsAccepted ??
          this.adaptiveSuggestionsAccepted,
      fixedMealsLogged: fixedMealsLogged ?? this.fixedMealsLogged,
      fixedWorkoutsLogged: fixedWorkoutsLogged ?? this.fixedWorkoutsLogged,
      fixedSuggestionsAccepted:
          fixedSuggestionsAccepted ?? this.fixedSuggestionsAccepted,
      imageAssistedMealsLogged:
          imageAssistedMealsLogged ?? this.imageAssistedMealsLogged,
      manualMealsLogged: manualMealsLogged ?? this.manualMealsLogged,
      sequentialWorkoutsLogged:
          sequentialWorkoutsLogged ?? this.sequentialWorkoutsLogged,
      nonSequentialWorkoutsLogged:
          nonSequentialWorkoutsLogged ?? this.nonSequentialWorkoutsLogged,
      mealSearchTaskMs: mealSearchTaskMs ?? this.mealSearchTaskMs,
      manualMealTaskMs: manualMealTaskMs ?? this.manualMealTaskMs,
      workoutLogTaskMs: workoutLogTaskMs ?? this.workoutLogTaskMs,
      usabilityEase: usabilityEase ?? this.usabilityEase,
      usabilityClarity: usabilityClarity ?? this.usabilityClarity,
      usabilityWouldUseAgain:
          usabilityWouldUseAgain ?? this.usabilityWouldUseAgain,
      usabilityComment: usabilityComment ?? this.usabilityComment,
      rq1AdaptiveChecklist: rq1AdaptiveChecklist ?? this.rq1AdaptiveChecklist,
      rq1FixedChecklist: rq1FixedChecklist ?? this.rq1FixedChecklist,
      rq2UsabilityChecklist: rq2UsabilityChecklist ?? this.rq2UsabilityChecklist,
    );
  }

  Map<String, dynamic> toJson() => {
        'adaptiveMealsLogged': adaptiveMealsLogged,
        'adaptiveWorkoutsLogged': adaptiveWorkoutsLogged,
        'adaptiveSuggestionsAccepted': adaptiveSuggestionsAccepted,
        'fixedMealsLogged': fixedMealsLogged,
        'fixedWorkoutsLogged': fixedWorkoutsLogged,
        'fixedSuggestionsAccepted': fixedSuggestionsAccepted,
        'imageAssistedMealsLogged': imageAssistedMealsLogged,
        'manualMealsLogged': manualMealsLogged,
        'sequentialWorkoutsLogged': sequentialWorkoutsLogged,
        'nonSequentialWorkoutsLogged': nonSequentialWorkoutsLogged,
        'mealSearchTaskMs': mealSearchTaskMs,
        'manualMealTaskMs': manualMealTaskMs,
        'workoutLogTaskMs': workoutLogTaskMs,
        'usabilityEase': usabilityEase,
        'usabilityClarity': usabilityClarity,
        'usabilityWouldUseAgain': usabilityWouldUseAgain,
        'usabilityComment': usabilityComment,
        'rq1AdaptiveChecklist': rq1AdaptiveChecklist,
        'rq1FixedChecklist': rq1FixedChecklist,
        'rq2UsabilityChecklist': rq2UsabilityChecklist,
      };

  static ResearchStudyRecord fromJson(Map<String, dynamic> j) {
    return ResearchStudyRecord(
      adaptiveMealsLogged: (j['adaptiveMealsLogged'] as num?)?.toInt() ?? 0,
      adaptiveWorkoutsLogged:
          (j['adaptiveWorkoutsLogged'] as num?)?.toInt() ?? 0,
      adaptiveSuggestionsAccepted:
          (j['adaptiveSuggestionsAccepted'] as num?)?.toInt() ?? 0,
      fixedMealsLogged: (j['fixedMealsLogged'] as num?)?.toInt() ?? 0,
      fixedWorkoutsLogged: (j['fixedWorkoutsLogged'] as num?)?.toInt() ?? 0,
      fixedSuggestionsAccepted:
          (j['fixedSuggestionsAccepted'] as num?)?.toInt() ?? 0,
      imageAssistedMealsLogged:
          (j['imageAssistedMealsLogged'] as num?)?.toInt() ?? 0,
      manualMealsLogged: (j['manualMealsLogged'] as num?)?.toInt() ?? 0,
      sequentialWorkoutsLogged:
          (j['sequentialWorkoutsLogged'] as num?)?.toInt() ?? 0,
      nonSequentialWorkoutsLogged:
          (j['nonSequentialWorkoutsLogged'] as num?)?.toInt() ?? 0,
      mealSearchTaskMs: (j['mealSearchTaskMs'] as num?)?.toInt(),
      manualMealTaskMs: (j['manualMealTaskMs'] as num?)?.toInt(),
      workoutLogTaskMs: (j['workoutLogTaskMs'] as num?)?.toInt(),
      usabilityEase: (j['usabilityEase'] as num?)?.toInt(),
      usabilityClarity: (j['usabilityClarity'] as num?)?.toInt(),
      usabilityWouldUseAgain: (j['usabilityWouldUseAgain'] as num?)?.toInt(),
      usabilityComment: j['usabilityComment'] as String? ?? '',
      rq1AdaptiveChecklist: j['rq1AdaptiveChecklist'] == true,
      rq1FixedChecklist: j['rq1FixedChecklist'] == true,
      rq2UsabilityChecklist: j['rq2UsabilityChecklist'] == true,
    );
  }

  String exportSummary() {
    final b = StringBuffer()
      ..writeln('Nutri Work — informal research session summary')
      ..writeln('(Exploratory only; not population inference.)')
      ..writeln()
      ..writeln('RQ1 — Adaptive vs fixed rule-based guidance')
      ..writeln('  Adaptive: meals=$adaptiveMealsLogged workouts=$adaptiveWorkoutsLogged suggestionsAccepted=$adaptiveSuggestionsAccepted')
      ..writeln('  Fixed:    meals=$fixedMealsLogged workouts=$fixedWorkoutsLogged suggestionsAccepted=$fixedSuggestionsAccepted')
      ..writeln('  Compare task completion (higher counts may favour one mode in self-testing).')
      ..writeln()
      ..writeln('RQ2 — Image-assisted logging, sequence vs non-sequential, usability')
      ..writeln('  Image-assisted meals logged: $imageAssistedMealsLogged')
      ..writeln('  Manual meals logged: $manualMealsLogged')
      ..writeln('  Sequential (adaptive) workouts: $sequentialWorkoutsLogged')
      ..writeln('  Non-sequential baseline workouts: $nonSequentialWorkoutsLogged')
      ..writeln('  Timed meal search (ms): ${mealSearchTaskMs ?? "—"}')
      ..writeln('  Timed manual meal (ms): ${manualMealTaskMs ?? "—"}')
      ..writeln('  Timed workout log (ms): ${workoutLogTaskMs ?? "—"}')
      ..writeln('  Usability ease (1–5): ${usabilityEase ?? "—"}')
      ..writeln('  Usability clarity (1–5): ${usabilityClarity ?? "—"}')
      ..writeln('  Would use again (1–5): ${usabilityWouldUseAgain ?? "—"}')
      ..writeln('  Comment: ${usabilityComment.isEmpty ? "—" : usabilityComment}')
      ..writeln()
      ..writeln('Offline ML benchmarks (Food-101, FitRec) are documented separately in the thesis paper.');
    return b.toString();
  }
}

/// How a meal was logged (for RQ2 comparison).
enum MealLogMethod { manual, imageAssisted }

extension MealLogMethodX on MealLogMethod {
  static MealLogMethod fromImageNote(String? note) {
    if (note == null || note == 'manual') return MealLogMethod.manual;
    if (note.startsWith('local:') ||
        note.startsWith('fdc:') ||
        note.startsWith('image:')) {
      return MealLogMethod.imageAssisted;
    }
    return MealLogMethod.manual;
  }

  String get label {
    switch (this) {
      case MealLogMethod.manual:
        return 'Manual entry';
      case MealLogMethod.imageAssisted:
        return 'Image-assisted / catalog search';
    }
  }
}
