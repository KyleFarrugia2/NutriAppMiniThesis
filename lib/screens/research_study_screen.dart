import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:uuid/uuid.dart';

import '../app_state.dart';
import '../models/meal_entry.dart';
import '../models/user_profile.dart';
import '../utils/meal_log_time.dart';
import 'food_search_screen.dart';

/// Guided informal session to collect evidence for RQ1 and RQ2.
class ResearchStudyScreen extends StatefulWidget {
  const ResearchStudyScreen({super.key, required this.app});

  final AppState app;

  @override
  State<ResearchStudyScreen> createState() => _ResearchStudyScreenState();
}

class _ResearchStudyScreenState extends State<ResearchStudyScreen> {
  static final _uuid = Uuid();
  final _comment = TextEditingController();
  int _ease = 3;
  int _clarity = 3;
  int _wouldUse = 3;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _setMode(WorkoutGuidanceMode mode) async {
    final p = widget.app.profile;
    if (p == null) return;
    await widget.app.updateProfile(p.copyWith(workoutGuidanceMode: mode));
  }

  void _startTimedTask(String taskId) {
    widget.app.startResearchTimedTask(taskId);
  }

  Future<void> _openMealSearch() async {
    _startTimedTask('meal_search');
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FoodSearchScreen(app: widget.app),
      ),
    );
    setState(() {});
  }

  Future<void> _openManualMeal() async {
    _startTimedTask('manual_meal');
    if (!mounted) return;

    final name = TextEditingController(text: 'Test meal');
    final cal = TextEditingController(text: '400');
    final p = TextEditingController(text: '30');
    final c = TextEditingController(text: '40');
    final f = TextEditingController(text: '12');
    String? dialogError;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Custom meal (timed task)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dialogError != null)
                  Text(dialogError!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Meal name')),
                TextField(controller: cal, decoration: const InputDecoration(labelText: 'Calories')),
                TextField(controller: p, decoration: const InputDecoration(labelText: 'Protein (g)')),
                TextField(controller: c, decoration: const InputDecoration(labelText: 'Carbs (g)')),
                TextField(controller: f, decoration: const InputDecoration(labelText: 'Fat (g)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty || int.tryParse(cal.text.trim()) == null) {
                  setModal(() => dialogError = 'Enter name and calories.');
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await widget.app.addMeal(MealEntry(
        id: _uuid.v4(),
        name: name.text.trim(),
        calories: int.parse(cal.text.trim()),
        proteinG: double.tryParse(p.text.trim()) ?? 0,
        carbsG: double.tryParse(c.text.trim()) ?? 0,
        fatG: double.tryParse(f.text.trim()) ?? 0,
        loggedAt: MealLogTime.onCalendarDay(DateTime.now()),
        imageNote: 'manual',
      ));
    }
    if (mounted) setState(() {});
  }

  Future<void> _markChecklist({
    bool? rq1Adaptive,
    bool? rq1Fixed,
    bool? rq2,
  }) async {
    var r = widget.app.researchStudy;
    if (rq1Adaptive != null) {
      r = r.copyWith(rq1AdaptiveChecklist: rq1Adaptive);
    }
    if (rq1Fixed != null) r = r.copyWith(rq1FixedChecklist: rq1Fixed);
    if (rq2 != null) r = r.copyWith(rq2UsabilityChecklist: rq2);
    await widget.app.saveResearchStudy(r);
  }

  Future<void> _saveQuestionnaire() async {
    await widget.app.saveResearchStudy(
      widget.app.researchStudy.copyWith(
        usabilityEase: _ease,
        usabilityClarity: _clarity,
        usabilityWouldUseAgain: _wouldUse,
        usabilityComment: _comment.text.trim(),
        rq2UsabilityChecklist: true,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questionnaire saved.')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.app,
      builder: (context, _) {
        final r = widget.app.researchStudy;
        final mode = widget.app.profile?.workoutGuidanceMode;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Research study session')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Use this once to gather informal evidence for your thesis research '
                    'questions. Counts update automatically when you log meals and workouts. '
                    'This is not a clinical trial—compare descriptive numbers only.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle(context, 'Research Question 1'),
              Text(
                'Does adaptive guidance improve task completion vs a fixed rule-based version?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _statsTable(
                context,
                rows: [
                  ('Adaptive meals', '${r.adaptiveMealsLogged}'),
                  ('Adaptive workouts', '${r.adaptiveWorkoutsLogged}'),
                  ('Adaptive suggestions accepted', '${r.adaptiveSuggestionsAccepted}'),
                  ('Fixed meals', '${r.fixedMealsLogged}'),
                  ('Fixed workouts', '${r.fixedWorkoutsLogged}'),
                  ('Fixed suggestions accepted', '${r.fixedSuggestionsAccepted}'),
                ],
              ),
              const SizedBox(height: 8),
              _statusChip(
                context,
                ok: r.rq1Answerable,
                label: r.rq1Answerable
                    ? 'RQ1: enough data to compare'
                    : 'RQ1: log meals & workouts in BOTH modes',
              ),
              const SizedBox(height: 12),
              Text('Step A — Adaptive mode', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              FilledButton.tonal(
                onPressed: () => _setMode(WorkoutGuidanceMode.adaptive),
                child: Text(
                  mode == WorkoutGuidanceMode.adaptive
                      ? 'Adaptive mode active'
                      : 'Switch to adaptive mode',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _openMealSearch,
                    child: const Text('Log meal (search)'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _startTimedTask('workout_log');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Workouts tab → log a session to record time.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Log workout'),
                  ),
                ],
              ),
              CheckboxListTile(
                value: r.rq1AdaptiveChecklist,
                onChanged: (v) => _markChecklist(rq1Adaptive: v ?? false),
                title: const Text('I finished the adaptive phase'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Text('Step B — Fixed rotation mode', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              FilledButton.tonal(
                onPressed: () => _setMode(WorkoutGuidanceMode.fixedRotation),
                child: Text(
                  mode == WorkoutGuidanceMode.fixedRotation
                      ? 'Fixed mode active'
                      : 'Switch to fixed rotation',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _openMealSearch,
                    child: const Text('Log meal (search)'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _startTimedTask('workout_log');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Workouts tab → log a session.'),
                        ),
                      );
                    },
                    child: const Text('Log workout'),
                  ),
                ],
              ),
              CheckboxListTile(
                value: r.rq1FixedChecklist,
                onChanged: (v) => _markChecklist(rq1Fixed: v ?? false),
                title: const Text('I finished the fixed phase'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Research Question 2'),
              Text(
                'Image-assisted vs manual logging; sequence-aware vs non-sequential recommender; '
                'timed tasks and short questionnaire. Offline accuracy/ranking metrics use public '
                'datasets (Food-101, fitness logs) in the thesis write-up.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _statsTable(
                context,
                rows: [
                  ('Image-assisted / catalog meals', '${r.imageAssistedMealsLogged}'),
                  ('Manual meals', '${r.manualMealsLogged}'),
                  ('Sequential (adaptive) workouts', '${r.sequentialWorkoutsLogged}'),
                  ('Non-sequential workouts', '${r.nonSequentialWorkoutsLogged}'),
                  ('Timed meal search', _fmtMs(r.mealSearchTaskMs)),
                  ('Timed manual meal', _fmtMs(r.manualMealTaskMs)),
                  ('Timed workout log', _fmtMs(r.workoutLogTaskMs)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Timed usability tasks', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: _openMealSearch,
                icon: const Icon(Icons.timer_outlined),
                label: Text(
                  r.mealSearchTaskMs == null
                      ? 'Task 1: Search & log a food (timer)'
                      : 'Task 1 done: ${_fmtMs(r.mealSearchTaskMs)}',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _openManualMeal,
                icon: const Icon(Icons.edit_note_outlined),
                label: Text(
                  r.manualMealTaskMs == null
                      ? 'Task 2: Custom manual meal (timer)'
                      : 'Task 2 done: ${_fmtMs(r.manualMealTaskMs)}',
                ),
              ),
              const SizedBox(height: 16),
              Text('Non-sequential baseline', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              FilledButton.tonal(
                onPressed: () => _setMode(WorkoutGuidanceMode.nonSequential),
                child: Text(
                  mode == WorkoutGuidanceMode.nonSequential
                      ? 'Non-sequential mode active — check Workouts tab'
                      : 'Switch to non-sequential & log a workout',
                ),
              ),
              const SizedBox(height: 16),
              Text('Optional questionnaire (1–5)', style: Theme.of(context).textTheme.titleSmall),
              _likert('Ease of use', _ease, (v) => setState(() => _ease = v)),
              _likert('Clarity of guidance', _clarity, (v) => setState(() => _clarity = v)),
              _likert('Would use again', _wouldUse, (v) => setState(() => _wouldUse = v)),
              TextField(
                controller: _comment,
                decoration: const InputDecoration(
                  labelText: 'Short comment (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saveQuestionnaire,
                child: const Text('Save questionnaire'),
              ),
              _statusChip(
                context,
                ok: r.rq2Answerable,
                label: r.rq2Answerable
                    ? 'RQ2: usability evidence captured'
                    : 'RQ2: complete timed tasks + questionnaire',
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Export for your write-up'),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: r.exportSummary()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Summary copied to clipboard.')),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy session summary'),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _fmtMs(int? ms) =>
      ms == null ? '—' : '${(ms / 1000).toStringAsFixed(1)} s';

  static Widget _sectionTitle(BuildContext context, String t) {
    return Text(
      t,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  static Widget _statsTable(
    BuildContext context, {
    required List<(String, String)> rows,
  }) {
    return Card(
      child: Column(
        children: rows
            .map(
              (row) => ListTile(
                dense: true,
                title: Text(row.$1),
                trailing: Text(
                  row.$2,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static Widget _statusChip(
    BuildContext context, {
    required bool ok,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        ok ? Icons.check_circle : Icons.pending_outlined,
        size: 18,
        color: ok ? cs.primary : cs.onSurfaceVariant,
      ),
      label: Text(label),
    );
  }

  Widget _likert(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
