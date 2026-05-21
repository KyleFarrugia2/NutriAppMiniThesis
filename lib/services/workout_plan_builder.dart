import '../models/user_profile.dart';
import '../models/workout_split_style.dart';
import '../models/weekly_workout_program.dart';

/// Builds a Mon–Sun program from [UserProfile] (goal, sex, age, split style).
class WorkoutPlanBuilder {
  const WorkoutPlanBuilder._();

  static const int minRestDaysPerWeek = 2;

  static WeeklyWorkoutPlan buildFor(UserProfile profile) {
    final mult = _ageSetMultiplier(profile.age);
    final days = _daysForProfile(profile, mult);
    return WeeklyWorkoutPlan(days: _finalizeWeek(days));
  }

  static List<PlanDaySlot> _daysForProfile(UserProfile p, double mult) {
    final split = p.workoutSplitStyle;
    if (split != WorkoutSplitStyle.goalDefault &&
        _supportsCustomSplit(p.fitnessGoal)) {
      return switch (split) {
        WorkoutSplitStyle.pplRest => _pplRestWeek(p, mult),
        WorkoutSplitStyle.pplUpperLower => _pplUpperLowerWeek(p, mult),
        WorkoutSplitStyle.upperLowerRest => _upperLowerRestWeek(p, mult),
        WorkoutSplitStyle.fullBody3x => _fullBody3xWeek(p, mult),
        WorkoutSplitStyle.goalDefault => _goalDefaultWeek(p, mult),
      };
    }
    return _goalDefaultWeek(p, mult);
  }

  static bool _supportsCustomSplit(FitnessGoal goal) =>
      goal == FitnessGoal.bodybuilding ||
      goal == FitnessGoal.powerBuilding ||
      goal == FitnessGoal.stayFit ||
      goal == FitnessGoal.loseWeight ||
      goal == FitnessGoal.powerlifting;

  static List<PlanDaySlot> _goalDefaultWeek(UserProfile p, double mult) {
    return switch (p.fitnessGoal) {
      FitnessGoal.stayFit => _stayFitPlan(p, mult),
      FitnessGoal.loseWeight => _loseWeightPlan(p, mult),
      FitnessGoal.bodybuilding => _bodybuildingPlan(p, mult),
      FitnessGoal.powerlifting => _powerliftingPlan(p, mult),
      FitnessGoal.powerBuilding => _powerBuildingPlan(p, mult),
    };
  }

  /// Mon–Sun, ≥ [minRestDaysPerWeek] rest days.
  static List<PlanDaySlot> _finalizeWeek(List<PlanDaySlot> days) {
    var week = _ensureSevenDays(days);
    while (_restDayCount(week) < minRestDaysPerWeek) {
      final idx = week.indexWhere((d) => !d.isRest);
      if (idx < 0) break;
      week = List<PlanDaySlot>.from(week);
      week[idx] = _rest();
    }
    return week;
  }

  static int _restDayCount(List<PlanDaySlot> days) =>
      days.where((d) => d.isRest).length;

  /// Mon–Sun only; trims or pads with rest if a template drifts.
  static List<PlanDaySlot> _ensureSevenDays(List<PlanDaySlot> days) {
    const n = WeeklyWorkoutPlan.slotCount;
    if (days.length == n) return days;
    if (days.length > n) return days.sublist(0, n);
    return [...days, ...List.filled(n - days.length, _rest())];
  }

  // —— Rotating split templates (machine/hypertrophy bias for bodybuilding) ——

  static List<PlanDaySlot> _pplRestWeek(UserProfile p, double mult) => [
        _pushDay(p, mult),
        _pullDay(p, mult),
        _legsDay(p, mult),
        _rest(),
        _pushDay(p, mult, variant: 2),
        _pullDay(p, mult, variant: 2),
        _rest(),
      ];

  static List<PlanDaySlot> _pplUpperLowerWeek(UserProfile p, double mult) => [
        _pushDay(p, mult),
        _pullDay(p, mult),
        _legsDay(p, mult),
        _rest(),
        _upperDay(p, mult),
        _lowerDay(p, mult),
        _rest(),
      ];

  static List<PlanDaySlot> _upperLowerRestWeek(UserProfile p, double mult) => [
        _upperDay(p, mult),
        _lowerDay(p, mult),
        _rest(),
        _upperDay(p, mult, variant: 2),
        _lowerDay(p, mult, variant: 2),
        _rest(),
        _rest(),
      ];

  static List<PlanDaySlot> _fullBody3xWeek(UserProfile p, double mult) => [
        _fullBodyDay(p, mult),
        _rest(),
        _fullBodyDay(p, mult, variant: 2),
        _rest(),
        _fullBodyDay(p, mult, variant: 3),
        _rest(),
        _rest(),
      ];

  static PlanDaySlot _pushDay(UserProfile p, double mult, {int variant = 1}) {
    final title = variant == 1 ? 'Push' : 'Push B';
    return PlanDaySlot(
      isRest: false,
      title: title,
      exercises: [
        _ex(variant == 1 ? 'Machine chest press' : 'Machine incline press', 3, mult),
        _ex('Pec deck fly', 3, mult),
        _ex('Machine shoulder press', 3, mult),
        _ex('Cable lateral raise', 3, mult),
        _ex('Cable tricep pushdown', 3, mult),
      ],
    );
  }

  static PlanDaySlot _pullDay(UserProfile p, double mult, {int variant = 1}) {
    return PlanDaySlot(
      isRest: false,
      title: variant == 1 ? 'Pull' : 'Pull B',
      exercises: [
        _ex('Wide grip lat pulldown', 3, mult),
        _ex(variant == 1 ? 'Machine row' : 'Close grip row machine', 3, mult),
        _ex('Straight-arm pulldown', 2, mult),
        _ex('Face pull', 2, mult),
        _ex('Machine preacher curl', 3, mult),
      ],
    );
  }

  static PlanDaySlot _legsDay(UserProfile p, double mult, {int variant = 1}) {
    if (p.sex == Sex.female) {
      return PlanDaySlot(
        isRest: false,
        title: variant == 1 ? 'Legs (glute focus)' : 'Legs B (glute focus)',
        exercises: [
          _ex('Hip thrust machine', 4, mult),
          _ex('Leg press', 3, mult),
          _ex('Seated leg curl', 3, mult),
          _ex('Glute kickback machine', 3, mult),
          _ex('Standing calf raise machine', 2, mult),
        ],
      );
    }
    return PlanDaySlot(
      isRest: false,
      title: variant == 1 ? 'Legs' : 'Legs B',
      exercises: [
        _ex('Leg press', 4, mult),
        _ex('Hack squat machine', 3, mult),
        _ex('Leg extension', 3, mult),
        _ex('Seated leg curl', 3, mult),
        _ex('Calf raise machine', 3, mult),
      ],
    );
  }

  static PlanDaySlot _upperDay(UserProfile p, double mult, {int variant = 1}) {
    return PlanDaySlot(
      isRest: false,
      title: variant == 1 ? 'Upper' : 'Upper B',
      exercises: [
        _ex('Machine chest press', 3, mult),
        _ex('Wide grip lat pulldown', 3, mult),
        _ex('Machine shoulder press', 2, mult),
        _ex('Machine row', 2, mult),
        _ex('Cable curl', 2, mult),
        _ex('Rope tricep pushdown', 2, mult),
      ],
    );
  }

  static PlanDaySlot _lowerDay(UserProfile p, double mult, {int variant = 1}) {
    if (p.sex == Sex.female) {
      return PlanDaySlot(
        isRest: false,
        title: variant == 1 ? 'Lower (glutes)' : 'Lower B (glutes)',
        exercises: [
          _ex('Hip thrust machine', 4, mult),
          _ex('Romanian deadlift (Smith machine)', 3, mult),
          _ex('Leg extension', 2, mult),
          _ex('Seated leg curl', 3, mult),
          _ex('Cable crunch', 2, mult),
        ],
      );
    }
    return PlanDaySlot(
      isRest: false,
      title: variant == 1 ? 'Lower' : 'Lower B',
      exercises: [
        _ex('Leg press', 4, mult),
        _ex('Romanian deadlift (Smith machine)', 3, mult),
        _ex('Leg extension', 2, mult),
        _ex('Seated leg curl', 3, mult),
        _ex('Calf raise machine', 2, mult),
      ],
    );
  }

  static PlanDaySlot _fullBodyDay(UserProfile p, double mult, {int variant = 1}) {
    final legFocus = p.sex == Sex.female;
    return PlanDaySlot(
      isRest: false,
      title: 'Full body $variant',
      exercises: legFocus
          ? [
              _ex('Hip thrust machine', 3, mult),
              _ex('Machine chest press', 2, mult),
              _ex('Lat pulldown', 2, mult),
              _ex('Leg press', 2, mult),
              _ex('Cable tricep pushdown', 2, mult),
            ]
          : [
              _ex('Leg press', 3, mult),
              _ex('Machine chest press', 2, mult),
              _ex('Lat pulldown', 2, mult),
              _ex('Machine shoulder press', 2, mult),
              _ex('Cable curl', 2, mult),
            ],
    );
  }

  /// Slightly fewer working sets for older trainees; more for teens.
  static double _ageSetMultiplier(int age) {
    if (age < 20) return 1.1;
    if (age < 35) return 1.0;
    if (age < 50) return 0.9;
    if (age < 65) return 0.8;
    return 0.7;
  }

  static int _sets(int base, double mult) => (base * mult).round().clamp(1, 5);

  static PlanExercise _ex(String name, int sets, double mult) =>
      PlanExercise(name: name, targetSets: _sets(sets, mult));

  static PlanDaySlot _rest() =>
      const PlanDaySlot(isRest: true, title: 'Rest', exercises: []);

  // —— Stay fit: balanced 3× strength + light cardio ——
  static List<PlanDaySlot> _stayFitPlan(UserProfile p, double mult) {
    final legFocus = p.sex == Sex.female;
    return [
      PlanDaySlot(
        isRest: false,
        title: legFocus ? 'Lower body & glutes' : 'Full body A',
        exercises: legFocus
            ? [
                _ex('Leg press', 3, mult),
                _ex('Hip thrust machine', 3, mult),
                _ex('Seated leg curl', 2, mult),
                _ex('Walking lunges (bodyweight)', 2, mult),
                _ex('Plank', 2, mult),
              ]
            : [
                _ex('Goblet squat', 3, mult),
                _ex('Push-up or chest press machine', 2, mult),
                _ex('Lat pulldown', 2, mult),
                _ex('Plank', 2, mult),
              ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Cardio & core',
        exercises: [
          _ex('Brisk walk / bike (20–30 min)', 1, mult),
          _ex('Dead bug', 2, mult),
          _ex('Side plank', 2, mult),
        ],
      ),
      _rest(),
      PlanDaySlot(
        isRest: false,
        title: legFocus ? 'Glutes & hamstrings' : 'Full body B',
        exercises: legFocus
            ? [
                _ex('Romanian deadlift (machine)', 3, mult),
                _ex('Glute kickback machine', 3, mult),
                _ex('Leg extension', 2, mult),
                _ex('Calf raise machine', 2, mult),
              ]
            : [
                _ex('Leg press', 3, mult),
                _ex('Shoulder press machine', 2, mult),
                _ex('Seated row', 2, mult),
                _ex('Bicycle crunch', 2, mult),
              ],
      ),
      _rest(),
      PlanDaySlot(
        isRest: false,
        title: 'Active recovery',
        exercises: [
          _ex('Yoga flow / mobility (15 min)', 1, mult),
          _ex('Band pull-apart', 2, mult),
        ],
      ),
      _rest(),
    ];
  }

  // —— Lose weight: more conditioning, full-body circuits ——
  static List<PlanDaySlot> _loseWeightPlan(UserProfile p, double mult) {
    final legFocus = p.sex == Sex.female;
    return [
      PlanDaySlot(
        isRest: false,
        title: legFocus ? 'Glutes & legs circuit' : 'Strength circuit',
        exercises: [
          _ex('Leg press', 3, mult),
          _ex(legFocus ? 'Hip thrust machine' : 'Chest press machine', 2, mult),
          _ex('Lat pulldown', 2, mult),
          _ex('Farmer carry / sled push', 2, mult),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Cardio intervals',
        exercises: [
          _ex('Incline walk / elliptical (25 min)', 1, mult),
          _ex('Battle ropes or rower sprints', 2, mult),
        ],
      ),
      _rest(),
      PlanDaySlot(
        isRest: false,
        title: legFocus ? 'Lower body tone' : 'Upper + core',
        exercises: legFocus
            ? [
                _ex('Glute bridge machine', 3, mult),
                _ex('Seated leg curl', 2, mult),
                _ex('Step-ups', 2, mult),
                _ex('Cable crunch', 2, mult),
              ]
            : [
                _ex('Shoulder press machine', 2, mult),
                _ex('Pec deck', 2, mult),
                _ex('Assisted pull-up', 2, mult),
                _ex('Plank', 2, mult),
              ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Zone 2 cardio',
        exercises: [
          _ex('Bike / walk (35 min, steady)', 1, mult),
        ],
      ),
      _rest(),
      PlanDaySlot(
        isRest: false,
        title: 'Full body finisher',
        exercises: [
          _ex('Kettlebell swing or leg press', 3, mult),
          _ex('Cable row', 2, mult),
          _ex('Pallof press', 2, mult),
        ],
      ),
    ];
  }

  // —— Bodybuilding: machine / cable focus (no barbell bench or free-weight compounds) ——
  static List<PlanDaySlot> _bodybuildingPlan(UserProfile p, double mult) {
    if (p.sex == Sex.female) {
      return [
        PlanDaySlot(
          isRest: false,
          title: 'Glutes & hamstrings',
          exercises: [
            _ex('Hip thrust machine', 4, mult),
            _ex('Romanian deadlift (Smith machine)', 3, mult),
            _ex('Seated leg curl', 3, mult),
            _ex('Glute kickback machine', 3, mult),
            _ex('Cable pull-through', 2, mult),
          ],
        ),
        PlanDaySlot(
          isRest: false,
          title: 'Quads & calves',
          exercises: [
            _ex('Leg press', 4, mult),
            _ex('Leg extension', 3, mult),
            _ex('Hack squat machine', 3, mult),
            _ex('Standing calf raise machine', 3, mult),
          ],
        ),
        _rest(),
        PlanDaySlot(
          isRest: false,
          title: 'Back & shoulders (machines)',
          exercises: [
            _ex('Wide grip lat pulldown', 3, mult),
            _ex('Machine row', 3, mult),
            _ex('Machine shoulder press', 3, mult),
            _ex('Cable lateral raise', 3, mult),
            _ex('Face pull', 2, mult),
          ],
        ),
        PlanDaySlot(
          isRest: false,
          title: 'Chest & arms (machines)',
          exercises: [
            _ex('Machine chest press', 3, mult),
            _ex('Pec deck fly', 3, mult),
            _ex('Cable tricep pushdown', 3, mult),
            _ex('Machine preacher curl', 2, mult),
          ],
        ),
        PlanDaySlot(
          isRest: false,
          title: 'Glutes & legs B',
          exercises: [
            _ex('Hip thrust machine', 3, mult),
            _ex('Leg press (high foot placement)', 3, mult),
            _ex('Seated leg curl', 3, mult),
            _ex('Abductor machine', 2, mult),
            _ex('Cable crunch', 2, mult),
          ],
        ),
        _rest(),
      ];
    }
    return [
      PlanDaySlot(
        isRest: false,
        title: 'Chest & shoulders (machines)',
        exercises: [
          _ex('Machine incline press', 3, mult),
          _ex('Pec deck fly', 3, mult),
          _ex('Machine shoulder press', 3, mult),
          _ex('Cable lateral raise', 3, mult),
          _ex('Cable tricep extension', 3, mult),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Back (machines)',
        exercises: [
          _ex('Wide grip lat pulldown', 3, mult),
          _ex('Close grip row machine', 3, mult),
          _ex('Straight-arm pulldown', 2, mult),
          _ex('Machine preacher curl', 3, mult),
          _ex('Hammer curl machine', 2, mult),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Legs A',
        exercises: [
          _ex('Leg press', 4, mult),
          _ex('Hack squat machine', 3, mult),
          _ex('Leg extension', 3, mult),
          _ex('Seated leg curl', 3, mult),
          _ex('Calf raise machine', 3, mult),
        ],
      ),
      _rest(),
      PlanDaySlot(
        isRest: false,
        title: 'Arms & delts',
        exercises: [
          _ex('Cable curl', 3, mult),
          _ex('Rope tricep pushdown', 3, mult),
          _ex('Reverse pec deck', 3, mult),
          _ex('Cable crunch', 2, mult),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Legs B',
        exercises: [
          _ex('Romanian deadlift (Smith machine)', 3, mult),
          _ex('Leg press', 3, mult),
          _ex('Leg extension', 2, mult),
          _ex('Seated leg curl', 3, mult),
          _ex('Hip thrust machine', 3, mult),
        ],
      ),
      _rest(),
    ];
  }

  // —— Powerlifting: squat / bench / deadlift focus ——
  static List<PlanDaySlot> _powerliftingPlan(UserProfile p, double mult) {
    final vol = p.age >= 50 ? 0.85 : 1.0;
    final m = mult * vol;
    return [
      PlanDaySlot(
        isRest: false,
        title: 'Squat day',
        exercises: [
          _ex('Back squat', 4, m),
          _ex('Pause squat', 3, m),
          _ex('Leg press', 3, m),
          _ex('Leg curl', 2, m),
          _ex('Ab wheel', 2, m),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Bench day',
        exercises: [
          _ex('Competition bench press', 4, m),
          _ex('Close-grip bench', 3, m),
          _ex('Chest-supported row', 3, m),
          _ex('Tricep pressdown', 2, m),
        ],
      ),
      _rest(),
      PlanDaySlot(
        isRest: false,
        title: 'Deadlift day',
        exercises: [
          _ex('Conventional deadlift', 4, m),
          _ex('Romanian deadlift', 3, m),
          _ex('Barbell row', 3, m),
          _ex('Lat pulldown', 2, m),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Accessory / technique',
        exercises: [
          _ex('Front squat (light)', 3, m),
          _ex('Overhead press', 3, m),
          _ex('Pull-up or pulldown', 3, m),
          _ex('Face pull', 2, m),
        ],
      ),
      _rest(),
      _rest(),
    ];
  }

  // —— Powerbuilding: heavy compounds + machine accessories ——
  static List<PlanDaySlot> _powerBuildingPlan(UserProfile p, double mult) {
    final legFocus = p.sex == Sex.female;
    return [
      PlanDaySlot(
        isRest: false,
        title: 'Squat + legs',
        exercises: [
          _ex('Back squat', 4, mult),
          _ex(legFocus ? 'Hip thrust machine' : 'Leg press', 3, mult),
          _ex('Leg curl', 3, mult),
          _ex('Calf raise', 2, mult),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: 'Bench + push',
        exercises: [
          _ex('Bench press', 4, mult),
          _ex('Machine incline press', 3, mult),
          _ex('Cable tricep work', 3, mult),
          _ex('Lateral raise machine', 2, mult),
        ],
      ),
      _rest(),
      PlanDaySlot(
        isRest: false,
        title: 'Deadlift + pull',
        exercises: [
          _ex('Deadlift', 4, mult),
          _ex('Barbell row', 3, mult),
          _ex('Lat pulldown', 3, mult),
          _ex('Face pull', 2, mult),
        ],
      ),
      PlanDaySlot(
        isRest: false,
        title: legFocus ? 'Glutes & hamstrings' : 'Upper hypertrophy',
        exercises: legFocus
            ? [
                _ex('Hip thrust machine', 4, mult),
                _ex('Romanian deadlift', 3, mult),
                _ex('Leg extension', 2, mult),
                _ex('Cable curl', 2, mult),
              ]
            : [
                _ex('Overhead press', 3, mult),
                _ex('Pec deck', 3, mult),
                _ex('Machine row', 3, mult),
                _ex('Hammer curl', 2, mult),
              ],
      ),
      _rest(),
      _rest(),
    ];
  }
}
