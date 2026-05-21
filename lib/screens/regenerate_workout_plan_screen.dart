import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/user_profile.dart';
import '../models/workout_split_style.dart';

/// Pick a weekly split and rebuild the Mon–Sun program (repeat as often as needed).
class RegenerateWorkoutPlanScreen extends StatefulWidget {
  const RegenerateWorkoutPlanScreen({super.key, required this.app});

  final AppState app;

  @override
  State<RegenerateWorkoutPlanScreen> createState() =>
      _RegenerateWorkoutPlanScreenState();
}

class _RegenerateWorkoutPlanScreenState extends State<RegenerateWorkoutPlanScreen> {
  late WorkoutSplitStyle _selected;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.app.profile?.workoutSplitStyle ?? WorkoutSplitStyle.goalDefault;
  }

  Future<void> _regenerate() async {
    setState(() => _busy = true);
    try {
      await widget.app.regenerateWorkoutPlan(split: _selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New plan: ${_selected.label}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.app.profile;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final choices = profile == null
        ? WorkoutSplitStyle.values
        : workoutSplitOptionsForGoal(profile.fitnessGoal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate a new plan'),
      ),
      body: profile == null
          ? const Center(child: Text('Complete your profile first.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Card(
                  color: cs.primaryContainer.withValues(alpha: 0.35),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.self_improvement, color: cs.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            kRecoveryRestDaysMessage,
                            style: tt.bodyMedium?.copyWith(
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Not happy with this week? Pick another split and regenerate — '
                  'you can do this as many times as you want. Your goal (${profile.fitnessGoal.label}) '
                  'still controls exercise style (e.g. machines for bodybuilding).',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current: ${profile.workoutSplitStyle.label}',
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ...choices.map((style) {
                  final picked = _selected == style;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: picked
                          ? cs.secondaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _busy ? null : () => setState(() => _selected = style),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                picked
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: picked ? cs.secondary : cs.outline,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      style.label,
                                      style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      style.subtitle,
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        height: 1.35,
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
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _busy ? null : _regenerate,
                  icon: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.autorenew),
                  label: Text(
                    _busy ? 'Building…' : 'Generate this plan',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can still edit individual days with the calendar button on Workouts.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}
