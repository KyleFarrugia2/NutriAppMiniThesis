import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/user_profile.dart';
import '../widgets/weight_phase_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.app});

  final AppState app;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _steps;
  late Sex _sex;
  late ActivityLevel _activity;
  late FitnessGoal _fitnessGoal;
  late NutritionGoal _weightPhase;
  late WorkoutGuidanceMode _guidanceMode;

  @override
  void initState() {
    super.initState();
    final p = widget.app.profile!;
    _name = TextEditingController(text: p.displayName);
    _age = TextEditingController(text: '${p.age}');
    _height = TextEditingController(text: '${p.heightCm}');
    _weight = TextEditingController(text: '${p.weightKg}');
    _steps = TextEditingController(
      text: p.wearableStepsAvg?.toString() ?? '',
    );
    _sex = p.sex;
    _activity = p.activityLevel;
    _fitnessGoal = p.fitnessGoal;
    _weightPhase = p.fitnessGoal.asksWeightPhase && p.goal.isWeightPhaseChoice
        ? p.goal
        : NutritionGoal.gainMuscle;
    _guidanceMode = p.workoutGuidanceMode;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _steps.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final stepsText = _steps.text.trim();
    final profile = UserProfile(
      displayName: _name.text.trim(),
      age: int.parse(_age.text.trim()),
      heightCm: double.parse(_height.text.trim()),
      weightKg: double.parse(_weight.text.trim()),
      sex: _sex,
      activityLevel: _activity,
      fitnessGoal: _fitnessGoal,
      goal: UserProfile.resolveNutritionGoal(
        _fitnessGoal,
        _fitnessGoal.asksWeightPhase ? _weightPhase : null,
      ),
      wearableStepsAvg: stepsText.isEmpty ? null : int.tryParse(stepsText),
      workoutGuidanceMode: _guidanceMode,
    );
    await widget.app.updateProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile saved — goals and meal targets updated. Workout plan refreshes when training goal or body changes.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _age,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 14 || n > 100) return '14–100';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _height,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Height cm'),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 120 || n > 230) return 'cm';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Weight kg'),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 35 || n > 250) return 'kg';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SegmentedButton<Sex>(
                  segments: const [
                    ButtonSegment(value: Sex.male, label: Text('Male')),
                    ButtonSegment(value: Sex.female, label: Text('Female')),
                    ButtonSegment(value: Sex.other, label: Text('Other')),
                  ],
                  selected: {_sex},
                  onSelectionChanged: (s) => setState(() => _sex = s.first),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ActivityLevel>(
                  value: _activity,
                  decoration: const InputDecoration(labelText: 'Activity'),
                  items: ActivityLevel.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.label, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _activity = v);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Training goal',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<FitnessGoal>(
                  value: _fitnessGoal,
                  decoration: const InputDecoration(
                    labelText: 'What is your goal?',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: FitnessGoal.values
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _fitnessGoal = v;
                      if (!v.asksWeightPhase) return;
                      if (!_weightPhase.isWeightPhaseChoice) {
                        _weightPhase = NutritionGoal.gainMuscle;
                      }
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _fitnessGoal.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (_fitnessGoal.asksWeightPhase) ...[
                  const SizedBox(height: 16),
                  WeightPhasePicker(
                    value: _weightPhase,
                    onChanged: (v) => setState(() => _weightPhase = v),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _steps,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Avg daily steps (optional)',
                    helperText:
                        'For any goal we suggest averaging at least $kRecommendedMinDailySteps steps/day.',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Workout suggestions',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...WorkoutGuidanceMode.values.map(
                  (m) => RadioListTile<WorkoutGuidanceMode>(
                    value: m,
                    groupValue: _guidanceMode,
                    title: Text(m.label, style: Theme.of(context).textTheme.bodyMedium),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) {
                      if (v != null) setState(() => _guidanceMode = v);
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  switch (_guidanceMode) {
                    WorkoutGuidanceMode.adaptive =>
                      'Sequence-aware: uses your last 7 days of logs (RQ1 & RQ2).',
                    WorkoutGuidanceMode.fixedRotation =>
                      'Fixed weekday template; ignores logs (RQ1 baseline).',
                    WorkoutGuidanceMode.nonSequential =>
                      'Static template from goal only; ignores history (RQ2 baseline).',
                  },
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
