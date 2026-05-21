/// One line in the weekly template (exercise + target sets).
class PlanExercise {
  const PlanExercise({required this.name, required this.targetSets});

  final String name;
  final int targetSets;

  Map<String, dynamic> toJson() => {
        'name': name,
        'targetSets': targetSets,
      };

  factory PlanExercise.fromJson(Map<String, dynamic> j) {
    return PlanExercise(
      name: j['name'] as String,
      targetSets: (j['targetSets'] as num).toInt(),
    );
  }

  PlanExercise copyWith({String? name, int? targetSets}) {
    return PlanExercise(
      name: name ?? this.name,
      targetSets: targetSets ?? this.targetSets,
    );
  }
}

/// One weekday slot (Mon–Sun). [isRest] skips exercises.
class PlanDaySlot {
  const PlanDaySlot({
    required this.isRest,
    required this.title,
    required this.exercises,
  });

  final bool isRest;
  final String title;
  final List<PlanExercise> exercises;

  Map<String, dynamic> toJson() => {
        'isRest': isRest,
        'title': title,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory PlanDaySlot.fromJson(Map<String, dynamic> j) {
    final raw = j['exercises'];
    final list = raw is List<dynamic>
        ? raw.map((e) => PlanExercise.fromJson(e as Map<String, dynamic>)).toList()
        : <PlanExercise>[];
    return PlanDaySlot(
      isRest: j['isRest'] as bool? ?? false,
      title: j['title'] as String? ?? 'Workout',
      exercises: list,
    );
  }

  PlanDaySlot copyWith({
    bool? isRest,
    String? title,
    List<PlanExercise>? exercises,
  }) {
    return PlanDaySlot(
      isRest: isRest ?? this.isRest,
      title: title ?? this.title,
      exercises: exercises ?? List.from(this.exercises),
    );
  }
}

/// Seven slots: index **0 = Monday** … **6 = Sunday**.
class WeeklyWorkoutPlan {
  WeeklyWorkoutPlan({required List<PlanDaySlot> days})
      : days = List<PlanDaySlot>.from(days) {
    assert(
      days.length == slotCount,
      'WeeklyWorkoutPlan requires exactly $slotCount days (Mon–Sun).',
    );
  }

  static const int slotCount = 7;

  final List<PlanDaySlot> days;

  static WeeklyWorkoutPlan defaultSuggested() {
    return WeeklyWorkoutPlan(days: _defaultDays());
  }

  factory WeeklyWorkoutPlan.fromJson(Map<String, dynamic> j) {
    final raw = j['days'];
    if (raw is! List<dynamic> || raw.length != slotCount) {
      return WeeklyWorkoutPlan.defaultSuggested();
    }
    try {
      return WeeklyWorkoutPlan(
        days: raw
            .map((e) => PlanDaySlot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return WeeklyWorkoutPlan.defaultSuggested();
    }
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'days': days.map((e) => e.toJson()).toList(),
      };

  WeeklyWorkoutPlan copyWithDays(List<PlanDaySlot> d) {
    return WeeklyWorkoutPlan(days: List<PlanDaySlot>.from(d));
  }
}

List<PlanDaySlot> _defaultDays() {
  return [
    PlanDaySlot(
      isRest: false,
      title: 'Push A',
      exercises: const [
        PlanExercise(name: 'Y raise', targetSets: 2),
        PlanExercise(name: 'Upper chest flye', targetSets: 2),
        PlanExercise(name: 'Flat chest press', targetSets: 2),
        PlanExercise(name: 'Shoulder press', targetSets: 1),
        PlanExercise(name: 'Poliquin tricep extensions', targetSets: 3),
        PlanExercise(name: 'Cable crunch', targetSets: 2),
      ],
    ),
    PlanDaySlot(
      isRest: false,
      title: 'Pull A',
      exercises: const [
        PlanExercise(name: 'Wide grip pulldown', targetSets: 2),
        PlanExercise(name: 'Iliac lat pulldown', targetSets: 1),
        PlanExercise(name: 'Upper back row', targetSets: 2),
        PlanExercise(name: 'Cable hammer curl', targetSets: 2),
        PlanExercise(name: 'Dbell preacher curl', targetSets: 2),
        PlanExercise(
          name: 'Leg raise (bodyweight max reps)',
          targetSets: 2,
        ),
      ],
    ),
    PlanDaySlot(
      isRest: false,
      title: 'Legs A',
      exercises: const [
        PlanExercise(name: 'Glute bridge', targetSets: 2),
        PlanExercise(name: 'Seated leg curl', targetSets: 3),
        PlanExercise(name: 'Hyperextension', targetSets: 2),
        PlanExercise(name: 'Leg extension', targetSets: 2),
        PlanExercise(name: 'Straight leg calf raise', targetSets: 2),
        PlanExercise(name: 'Leg press', targetSets: 2),
        PlanExercise(name: 'Adductor', targetSets: 1),
      ],
    ),
    const PlanDaySlot(isRest: true, title: 'Rest', exercises: []),
    PlanDaySlot(
      isRest: false,
      title: 'Upper',
      exercises: const [
        PlanExercise(name: 'Machine side lateral raise', targetSets: 2),
        PlanExercise(name: 'Prime incline', targetSets: 2),
        PlanExercise(name: 'Pec dec', targetSets: 2),
        PlanExercise(name: 'Assisted pull up', targetSets: 2),
        PlanExercise(name: 'Cybex eagle lat row', targetSets: 1),
        PlanExercise(name: 'Tbar row', targetSets: 2),
        PlanExercise(name: 'Poliquin tricep extensions', targetSets: 2),
        PlanExercise(name: 'Cable hammer curl', targetSets: 1),
        PlanExercise(name: 'Dbell preacher curl', targetSets: 2),
      ],
    ),
    PlanDaySlot(
      isRest: false,
      title: 'Legs B',
      exercises: const [
        PlanExercise(name: 'Glute bridge', targetSets: 2),
        PlanExercise(name: 'Seated leg curl', targetSets: 3),
        PlanExercise(name: 'Hyperextension', targetSets: 2),
        PlanExercise(name: 'Leg extension', targetSets: 2),
        PlanExercise(name: 'Straight leg calf raise', targetSets: 2),
        PlanExercise(name: 'Squat press', targetSets: 2),
        PlanExercise(name: 'Adductor', targetSets: 1),
        PlanExercise(name: 'Rope crunch', targetSets: 2),
      ],
    ),
    const PlanDaySlot(isRest: true, title: 'Rest', exercises: []),
  ];
}

/// One performed set (weight optional for bodyweight).
class LoggedSet {
  const LoggedSet({
    required this.setIndex,
    this.weightKg,
    this.reps,
  });

  final int setIndex;
  final double? weightKg;
  final int? reps;

  Map<String, dynamic> toJson() => {
        'setIndex': setIndex,
        'weightKg': weightKg,
        'reps': reps,
      };

  factory LoggedSet.fromJson(Map<String, dynamic> j) {
    return LoggedSet(
      setIndex: (j['setIndex'] as num).toInt(),
      weightKg: (j['weightKg'] as num?)?.toDouble(),
      reps: (j['reps'] as num?)?.toInt(),
    );
  }
}

class LoggedExercise {
  const LoggedExercise({required this.name, required this.sets});

  final String name;
  final List<LoggedSet> sets;

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets.map((e) => e.toJson()).toList(),
      };

  factory LoggedExercise.fromJson(Map<String, dynamic> j) {
    final raw = j['sets'];
    final list = raw is List<dynamic>
        ? raw.map((e) => LoggedSet.fromJson(e as Map<String, dynamic>)).toList()
        : <LoggedSet>[];
    return LoggedExercise(
      name: j['name'] as String,
      sets: list,
    );
  }
}

/// Logged gym session tied to a calendar day and plan label.
class ProgramWorkoutSession {
  const ProgramWorkoutSession({
    required this.id,
    required this.performedOn,
    required this.weekdayIndex,
    required this.planDayTitle,
    required this.exercises,
    required this.completedAt,
    this.durationMinutes,
  });

  final String id;

  /// Calendar date (local) this session belongs to.
  final DateTime performedOn;

  /// 0 = Monday … 6 = Sunday (matches [WeeklyWorkoutPlan.days]).
  final int weekdayIndex;
  final String planDayTitle;
  final List<LoggedExercise> exercises;
  final DateTime completedAt;
  final int? durationMinutes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'performedOn': performedOn.toIso8601String(),
        'weekdayIndex': weekdayIndex,
        'planDayTitle': planDayTitle,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'completedAt': completedAt.toIso8601String(),
        'durationMinutes': durationMinutes,
      };

  factory ProgramWorkoutSession.fromJson(Map<String, dynamic> j) {
    final raw = j['exercises'];
    final list = raw is List<dynamic>
        ? raw.map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>)).toList()
        : <LoggedExercise>[];
    return ProgramWorkoutSession(
      id: j['id'] as String,
      performedOn: DateTime.parse(j['performedOn'] as String),
      weekdayIndex: (j['weekdayIndex'] as num).toInt(),
      planDayTitle: j['planDayTitle'] as String,
      exercises: list,
      completedAt: DateTime.parse(j['completedAt'] as String),
      durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
    );
  }
}
