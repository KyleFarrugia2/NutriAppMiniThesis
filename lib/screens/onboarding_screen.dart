import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.app});

  final AppState app;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController(text: '28');
  final _height = TextEditingController(text: '170');
  final _weight = TextEditingController(text: '72');
  final _steps = TextEditingController();

  Sex _sex = Sex.other;
  ActivityLevel _activity = ActivityLevel.moderate;
  NutritionGoal _goal = NutritionGoal.maintain;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _steps.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final stepsText = _steps.text.trim();
    final profile = UserProfile(
      displayName: _name.text.trim(),
      age: int.parse(_age.text.trim()),
      heightCm: double.parse(_height.text.trim()),
      weightKg: double.parse(_weight.text.trim()),
      sex: _sex,
      activityLevel: _activity,
      goal: _goal,
      wearableStepsAvg: stepsText.isEmpty ? null : int.tryParse(stepsText),
    );
    await widget.app.completeOnboarding(profile);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Personalized setup',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We use your profile to estimate energy needs, macro targets, and explainable workout suggestions. You can edit this anytime.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 28),
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
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 14 || n > 100) {
                            return '14–100';
                          }
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
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          prefixIcon: Icon(Icons.height),
                        ),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 120 || n > 230) {
                            return 'cm';
                          }
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
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 35 || n > 250) return 'kg';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text('Sex (for BMR estimate)',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<Sex>(
                  segments: const [
                    ButtonSegment(value: Sex.male, label: Text('Male')),
                    ButtonSegment(value: Sex.female, label: Text('Female')),
                    ButtonSegment(value: Sex.other, label: Text('Other')),
                  ],
                  selected: {_sex},
                  onSelectionChanged: (s) => setState(() => _sex = s.first),
                ),
                const SizedBox(height: 20),
                Text('Activity level',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                DropdownButtonFormField<ActivityLevel>(
                  value: _activity,
                  decoration: const InputDecoration(
                    labelText: 'Typical week',
                    prefixIcon: Icon(Icons.local_fire_department_outlined),
                  ),
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
                const SizedBox(height: 20),
                Text('Primary goal',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<NutritionGoal>(
                  segments: NutritionGoal.values
                      .map(
                        (g) => ButtonSegment(
                          value: g,
                          label: Text(
                            g == NutritionGoal.loseWeight
                                ? 'Lose'
                                : g == NutritionGoal.maintain
                                    ? 'Maintain'
                                    : 'Gain',
                          ),
                        ),
                      )
                      .toList(),
                  selected: {_goal},
                  onSelectionChanged: (s) => setState(() => _goal = s.first),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _steps,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Avg daily steps (optional)',
                    hintText: 'Wearable signal for adaptive hints',
                    prefixIcon: Icon(Icons.directions_walk_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save profile & continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
