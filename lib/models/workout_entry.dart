enum WorkoutType { strength, cardio, mobility, sports }

extension WorkoutTypeX on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.strength:
        return 'Strength';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.mobility:
        return 'Mobility / recovery';
      case WorkoutType.sports:
        return 'Sports';
    }
  }
}

class WorkoutEntry {
  WorkoutEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.completedAt,
    this.rpe,
    this.notes,
    this.logSource,
  });

  final String id;
  final String title;
  final WorkoutType type;
  final int durationMinutes;
  final DateTime completedAt;

  /// Rate of perceived exertion 1–10 for adaptive load hints.
  final int? rpe;
  final String? notes;

  /// e.g. `weekly_program` when mirrored from [ProgramWorkoutSession].
  final String? logSource;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'durationMinutes': durationMinutes,
        'completedAt': completedAt.toIso8601String(),
        'rpe': rpe,
        'notes': notes,
        'logSource': logSource,
      };

  static WorkoutEntry fromJson(Map<String, dynamic> j) {
    return WorkoutEntry(
      id: j['id'] as String,
      title: j['title'] as String,
      type: WorkoutType.values.firstWhere(
        (e) => e.name == j['type'],
        orElse: () => WorkoutType.strength,
      ),
      durationMinutes: (j['durationMinutes'] as num).toInt(),
      completedAt: DateTime.parse(j['completedAt'] as String),
      rpe: (j['rpe'] as num?)?.toInt(),
      notes: j['notes'] as String?,
      logSource: j['logSource'] as String?,
    );
  }
}
