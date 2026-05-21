import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../models/user_profile.dart';
import '../models/workout_entry.dart';
import '../services/personalization_engine.dart';
import '../theme/macro_colors.dart';
import '../widgets/macro_calorie_chart.dart';

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
                    _CalorieCard(
                      summary: summary,
                      cs: cs,
                      overBudget: summary.caloriesConsumed >
                          summary.calorieTarget,
                    ),
                    const SizedBox(height: 16),
                    _MacroRow(summary: summary),
                    const SizedBox(height: 12),
                    MacroCalorieVisuals(
                      proteinG: summary.proteinG,
                      carbsG: summary.carbsG,
                      fatG: summary.fatG,
                      size: 148,
                    ),
                  ],
                  if (insight != null && !app.nutritionInsightCardDismissed) ...[
                    const SizedBox(height: 8),
                    _InsightCard(
                      title: 'Personalized nutrition insight',
                      body: insight,
                      icon: Icons.psychology_alt_outlined,
                      color: cs.primaryContainer,
                      onColor: cs.onPrimaryContainer,
                      onDismiss: () => app.dismissNutritionInsightCard(),
                    ),
                  ],
                  if (wo != null && !app.dashboardWorkoutSuggestionDismissed) ...[
                    const SizedBox(height: 16),
                    _InsightCard(
                      title: 'Suggested next workout',
                      body:
                          '${wo.title} (${wo.type.label})\n\n${wo.rationale}\n\nIntensity: ${wo.intensityHint}',
                      icon: Icons.auto_awesome_motion_outlined,
                      color: cs.secondaryContainer,
                      onColor: cs.onSecondaryContainer,
                      footer: 'Mode: ${p.workoutGuidanceMode.shortLabel} — '
                          '${p.workoutGuidanceMode.label}',
                      onDismiss: () => app.dismissDashboardWorkoutSuggestion(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Card(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: cs.primary,
                        ),
                        title: Text(
                          'How your plan works',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          16,
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• Calories and macros use Mifflin–St Jeor BMR, your activity level, and goal-based offsets.\n'
                            '• Workout suggestions follow your Profile setting: adaptive (last 7 days) or a fixed weekday rotation for baseline comparisons.\n'
                            '• We recommend averaging at least 8,000 steps per day for any goal (lose, maintain, or gain)—add your typical steps under Profile.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
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
  const _CalorieCard({
    required this.summary,
    required this.cs,
    required this.overBudget,
  });

  final DailyNutritionSummary summary;
  final ColorScheme cs;
  final bool overBudget;

  @override
  Widget build(BuildContext context) {
    final pct = summary.calorieProgress.clamp(0.0, 1.0);
    final barColor = overBudget ? cs.error : cs.primary;
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
                        color: barColor,
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
            if (overBudget) ...[
              const SizedBox(height: 8),
              Text(
                'Above today’s target—fine occasionally; watch weekly average.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct > 1 ? 1 : pct,
                minHeight: 10,
                color: barColor,
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
            color: MacroColors.protein,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniMacro(
            label: 'Carbs',
            value: summary.carbsG,
            target: summary.carbsTargetG,
            unit: 'g',
            color: MacroColors.carbs,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniMacro(
            label: 'Fat',
            value: summary.fatG,
            target: summary.fatTargetG,
            unit: 'g',
            color: MacroColors.fat,
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
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color.withOpacity(0.85),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${value.round()} / ${target.round()} $unit',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
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
    this.footer,
    this.onDismiss,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final Color onColor;
  final String? footer;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 6, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: onColor, size: 28),
            ),
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
                  if (footer != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      footer!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: onColor.withOpacity(0.85),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                tooltip: 'Dismiss',
                visualDensity: VisualDensity.compact,
                onPressed: onDismiss,
                icon: Icon(Icons.close_rounded, color: onColor.withOpacity(0.88)),
              ),
          ],
        ),
      ),
    );
  }
}
