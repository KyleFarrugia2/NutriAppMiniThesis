import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/weekly_workout_program.dart';

/// Edit Mon–Sun template: titles, rest flags, exercises + set counts.
class EditWeeklyPlanScreen extends StatefulWidget {
  const EditWeeklyPlanScreen({super.key, required this.app});

  final AppState app;

  @override
  State<EditWeeklyPlanScreen> createState() => _EditWeeklyPlanScreenState();
}

class _EditWeeklyPlanScreenState extends State<EditWeeklyPlanScreen> {
  late List<PlanDaySlot> _days;
  late List<TextEditingController> _titleCtrls;

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _days = widget.app.weeklyPlan.days
        .map((d) => d.copyWith(exercises: List<PlanExercise>.from(d.exercises)))
        .toList();
    _titleCtrls = List.generate(
      WeeklyWorkoutPlan.slotCount,
      (i) => TextEditingController(text: _days[i].title),
    );
  }

  @override
  void dispose() {
    for (final c in _titleCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    for (var i = 0; i < _days.length; i++) {
      if (!_days[i].isRest) {
        final t = _titleCtrls[i].text.trim();
        if (t.isNotEmpty) {
          _days[i] = _days[i].copyWith(title: t);
        }
      }
    }
    await widget.app.setWeeklyWorkoutPlan(WeeklyWorkoutPlan(days: _days));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _editExercise(int dayIndex, int exIndex) async {
    final d = _days[dayIndex];
    final ex = d.exercises[exIndex];
    final nameCtrl = TextEditingController(text: ex.name);
    final setsCtrl = TextEditingController(text: '${ex.targetSets}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: setsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target sets'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
    final name = nameCtrl.text.trim();
    final setsParsed = int.tryParse(setsCtrl.text.trim()) ?? ex.targetSets;
    nameCtrl.dispose();
    setsCtrl.dispose();
    if (ok != true) return;
    setState(() {
      final list = List<PlanExercise>.from(d.exercises);
      list[exIndex] = PlanExercise(
        name: name.isEmpty ? ex.name : name,
        targetSets: setsParsed.clamp(1, 20),
      );
      _days[dayIndex] = d.copyWith(exercises: list);
    });
  }

  void _addExercise(int dayIndex) {
    setState(() {
      final d = _days[dayIndex];
      final next = List<PlanExercise>.from(d.exercises)
        ..add(const PlanExercise(name: 'New exercise', targetSets: 3));
      _days[dayIndex] = d.copyWith(isRest: false, exercises: next);
    });
  }

  void _removeExercise(int dayIndex, int exIndex) {
    setState(() {
      final d = _days[dayIndex];
      final next = List<PlanExercise>.from(d.exercises)..removeAt(exIndex);
      _days[dayIndex] = d.copyWith(exercises: next);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly split'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: WeeklyWorkoutPlan.slotCount,
        itemBuilder: (context, di) {
          final d = _days[di];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              initiallyExpanded: di == 0,
              title: Text(
                '${_dayNames[di]} · ${d.title}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(d.isRest ? 'Rest' : '${d.exercises.length} exercises'),
              children: [
                SwitchListTile(
                  title: const Text('Rest day'),
                  value: d.isRest,
                  onChanged: (v) {
                    setState(() {
                      _days[di] = d.copyWith(
                        isRest: v,
                        exercises: v ? [] : d.exercises,
                        title: v ? 'Rest' : (d.title == 'Rest' ? 'Workout' : d.title),
                      );
                      if (v) {
                        _titleCtrls[di].text = 'Rest';
                      }
                    });
                  },
                ),
                if (!d.isRest) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _titleCtrls[di],
                      decoration: const InputDecoration(
                        labelText: 'Day label (e.g. Push A)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {
                        _days[di] = _days[di].copyWith(title: _titleCtrls[di].text);
                      }),
                    ),
                  ),
                  ...List.generate(d.exercises.length, (ei) {
                    final ex = d.exercises[ei];
                    return ListTile(
                      title: Text(ex.name),
                      subtitle: Text('${ex.targetSets} sets'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editExercise(di, ei),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeExercise(di, ei),
                          ),
                        ],
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _addExercise(di),
                      icon: const Icon(Icons.add),
                      label: const Text('Add exercise'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _save,
            child: const Text('Save weekly plan'),
          ),
        ),
      ),
    );
  }
}
