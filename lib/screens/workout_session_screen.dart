import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../app_state.dart';
import '../models/weekly_workout_program.dart';
import '../utils/week_utils.dart';

class _SetEditors {
  _SetEditors({
    required this.weight,
    required this.reps,
    this.lastWeekHint,
  });

  final TextEditingController weight;
  final TextEditingController reps;
  final String? lastWeekHint;

  void dispose() {
    weight.dispose();
    reps.dispose();
  }
}

/// Log sets (weight × reps). **New logs start empty**; last week is hint-only.
/// Editing the same day again pre-fills from [seedSession].
class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.app,
    required this.workoutDate,
    required this.dayIndex,
    required this.planSlot,
    this.seedSession,
    this.lastWeekSession,
  });

  final AppState app;
  final DateTime workoutDate;
  final int dayIndex;
  final PlanDaySlot planSlot;
  final ProgramWorkoutSession? seedSession;
  final ProgramWorkoutSession? lastWeekSession;

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  static final _uuid = Uuid();
  late DateTime _startedAt;
  late List<List<_SetEditors>> _grid;

  LoggedExercise? _findExercise(ProgramWorkoutSession? session, String name) {
    if (session == null) return null;
    for (final e in session.exercises) {
      if (e.name == name) return e;
    }
    return null;
  }

  LoggedSet? _setAt(LoggedExercise? ex, int setNumber) {
    if (ex == null) return null;
    final i = setNumber - 1;
    if (i < 0 || i >= ex.sets.length) return null;
    return ex.sets[i];
  }

  String _weightInitial(LoggedSet? s) {
    if (s?.weightKg == null) return '';
    final v = s!.weightKg!;
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toString();
  }

  String _repsInitial(LoggedSet? s) {
    if (s?.reps == null) return '';
    return s!.reps.toString();
  }

  String _lastWeekLine(LoggedSet? s) {
    if (s == null) return '';
    if (s.weightKg == null && s.reps == null) return '';
    final w = s.weightKg != null ? '${s.weightKg} kg' : '—';
    final r = s.reps != null ? '${s.reps} reps' : '—';
    return 'Last week: $w × $r';
  }

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _grid = [];
    for (final ex in widget.planSlot.exercises) {
      final row = <_SetEditors>[];
      for (var i = 0; i < ex.targetSets; i++) {
        final setNumber = i + 1;
        final seedEx = _findExercise(widget.seedSession, ex.name);
        final lastEx = _findExercise(widget.lastWeekSession, ex.name);
        final seedSet = _setAt(seedEx, setNumber);
        final lastSet = _setAt(lastEx, setNumber);
        // Fresh week / new log: empty fields. Same-day edit: keep seed values only.
        final initial = seedSet;
        row.add(
          _SetEditors(
            weight: TextEditingController(text: _weightInitial(initial)),
            reps: TextEditingController(text: _repsInitial(initial)),
            lastWeekHint: _lastWeekLine(lastSet).isEmpty ? null : _lastWeekLine(lastSet),
          ),
        );
      }
      _grid.add(row);
    }
  }

  @override
  void dispose() {
    for (final row in _grid) {
      for (final e in row) {
        e.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _save() async {
    final exercises = <LoggedExercise>[];
    for (var ei = 0; ei < widget.planSlot.exercises.length; ei++) {
      final ex = widget.planSlot.exercises[ei];
      final sets = <LoggedSet>[];
      for (var si = 0; si < ex.targetSets; si++) {
        final editors = _grid[ei][si];
        final w = double.tryParse(editors.weight.text.trim().replaceAll(',', '.'));
        final r = int.tryParse(editors.reps.text.trim());
        sets.add(
          LoggedSet(
            setIndex: si + 1,
            weightKg: w,
            reps: r,
          ),
        );
      }
      exercises.add(LoggedExercise(name: ex.name, sets: sets));
    }
    final done = DateTime.now();
    final session = ProgramWorkoutSession(
      id: widget.seedSession?.id ?? _uuid.v4(),
      performedOn: dateOnly(widget.workoutDate),
      weekdayIndex: widget.dayIndex,
      planDayTitle: widget.planSlot.title,
      exercises: exercises,
      completedAt: done,
      durationMinutes: done.difference(_startedAt).inMinutes.clamp(1, 600),
    );
    await widget.app.saveProgramWorkoutSession(session);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, true);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Saved ${widget.planSlot.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planSlot.title),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Each week starts with empty weight and reps. Last week\'s numbers appear under each set as a reference only.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 16),
          for (var ei = 0; ei < widget.planSlot.exercises.length; ei++) ...[
            _ExerciseCard(
              exercise: widget.planSlot.exercises[ei],
              editors: _grid[ei],
              cs: cs,
              tt: tt,
              accentIndex: ei,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save workout'),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.editors,
    required this.cs,
    required this.tt,
    required this.accentIndex,
  });

  final PlanExercise exercise;
  final List<_SetEditors> editors;
  final ColorScheme cs;
  final TextTheme tt;
  final int accentIndex;

  Color get _accent {
    switch (accentIndex % 3) {
      case 1:
        return cs.secondary;
      case 2:
        return cs.tertiary;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: _accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < editors.length; i++) ...[
                      if (i > 0) const Divider(height: 20),
                      Text(
                        'Set ${i + 1}',
                        style: tt.labelMedium?.copyWith(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (editors[i].lastWeekHint != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          editors[i].lastWeekHint!,
                          style: tt.labelSmall?.copyWith(
                            color: cs.tertiary,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: editors[i].weight,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: editors[i].reps,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
