import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Lose vs gain weight for bodybuilding, powerlifting, and powerbuilding.
class WeightPhasePicker extends StatelessWidget {
  const WeightPhasePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final NutritionGoal value;
  final ValueChanged<NutritionGoal> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Right now, do you want to lose or gain weight?',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Macros and meal suggestions update from this. You can change it anytime in your profile.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        SegmentedButton<NutritionGoal>(
          segments: const [
            ButtonSegment(
              value: NutritionGoal.loseWeight,
              label: Text('Lose weight'),
              icon: Icon(Icons.trending_down, size: 18),
            ),
            ButtonSegment(
              value: NutritionGoal.gainMuscle,
              label: Text('Gain weight'),
              icon: Icon(Icons.trending_up, size: 18),
            ),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}
