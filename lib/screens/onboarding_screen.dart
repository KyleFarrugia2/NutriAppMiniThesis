import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/user_profile.dart';
import '../widgets/weight_phase_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.app});

  final AppState app;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _steps = TextEditingController();

  Sex _sex = Sex.other;
  ActivityLevel _activity = ActivityLevel.moderate;
  FitnessGoal _fitnessGoal = FitnessGoal.stayFit;
  NutritionGoal _weightPhase = NutritionGoal.gainMuscle;
  bool _saving = false;

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
    final form = _form.currentState;
    if (form == null) return;
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the highlighted fields above.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
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
      );
      await widget.app.completeOnboarding(profile);
      if (!mounted) return;
      if (widget.app.profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your profile. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                  'We build your weekly workout plan, macro targets, and ready-made meal suggestions from your profile.',
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
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Enter your age';
                          final n = int.tryParse(t);
                          if (n == null || n < 14 || n > 100) {
                            return 'Age must be 14–100';
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
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Enter height';
                          final n = double.tryParse(t);
                          if (n == null || n < 120 || n > 230) {
                            return 'Height 120–230 cm';
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
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Enter your weight';
                    final n = double.tryParse(t);
                    if (n == null || n < 35 || n > 250) {
                      return 'Weight 35–250 kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text('Sex (for BMR & training focus)',
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
                if (_sex == Sex.female) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Female plans emphasize legs & glutes with age-adjusted volume.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                        ),
                  ),
                ],
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
                const SizedBox(height: 24),
                Text(
                  'What is your goal?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This shapes your weekly workouts and meal suggestions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                ...FitnessGoal.values.map((g) {
                  final selected = _fitnessGoal == g;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: selected
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() {
                          _fitnessGoal = g;
                          if (g.asksWeightPhase &&
                              !_weightPhase.isWeightPhaseChoice) {
                            _weightPhase = NutritionGoal.gainMuscle;
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected ? cs.primary : cs.outline,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: selected
                                                ? cs.onPrimaryContainer
                                                : cs.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      g.subtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: selected
                                                ? cs.onPrimaryContainer
                                                : cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (_fitnessGoal.asksWeightPhase) ...[
                  const SizedBox(height: 20),
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
                    hintText: 'e.g. 8500',
                    helperText:
                        'For any goal we suggest averaging at least $kRecommendedMinDailySteps steps/day.',
                    prefixIcon: const Icon(Icons.directions_walk_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Build my plan & continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
