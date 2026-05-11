import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../services/personalization_engine.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final p = app.profile;
        final summary = app.todaySummary();
        final insight = app.nutritionInsight();
        final wo = app.workoutSuggestion();
        final cs = Theme.of(context).colorScheme;

        if (p == null) {
          return const Center(child: Text('Complete your profile first.'));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(
                'Today · ${DateFormat('EEE, MMM d').format(DateTime.now())}',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.list(
                children: [
                  if (summary != null) ...[
                    _CalorieCard(summary: summary, cs: cs),
                    const SizedBox(height: 16),
                    _MacroRow(summary: summary),
                  ],
                  if (insight != null) ...[
                    const SizedBox(height: 8),
                    _InsightCard(
                      title: 'Personalized nutrition insight',
                      body: insight,
                      icon: Icons.psychology_alt_outlined,
                      color: cs.primaryContainer,
                      onColor: cs.onPrimaryContainer,
                    ),
                  ],
                  if (wo != null) ...[
                    const SizedBox(height: 16),
                    _InsightCard(
                      title: 'Suggested next workout',
                      body:
                          '${wo.title} (${wo.type.label})\n\n${wo.rationale}\n\nIntensity: ${wo.intensityHint}',
                      icon: Icons.auto_awesome_motion_outlined,
                      color: cs.secondaryContainer,
                      onColor: cs.onSecondaryContainer,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Research hooks',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This build uses explainable rules (BMR/TDEE, macro heuristics, recency-aware workout mix). Swap in ML modules for food images, ranking, and wearable fusion without changing the UI shell.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CalorieCard extends StatelessWidget {
  const _CalorieCard({required this.summary, required this.cs});

  final DailyNutritionSummary summary;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final pct = summary.calorieProgress.clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${summary.caloriesConsumed}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Text(
                    '/ ${summary.calorieTarget} kcal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.summary});

  final DailyNutritionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniMacro(
            label: 'Protein',
            value: summary.proteinG,
            target: summary.proteinTargetG,
            unit: 'g',
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniMacro(
            label: 'Carbs',
            value: summary.carbsG,
            target: summary.carbsTargetG,
            unit: 'g',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniMacro(
            label: 'Fat',
            value: summary.fatG,
            target: summary.fatTargetG,
            unit: 'g',
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}

class _MiniMacro extends StatelessWidget {
  const _MiniMacro({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final prog = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.2);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 6),
            Text(
              '${value.round()} / ${target.round()} $unit',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: prog > 1 ? 1 : prog,
                minHeight: 6,
                color: color,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.onColor,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onColor, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: onColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onColor.withOpacity(0.92),
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
