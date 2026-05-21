import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../models/weekly_workout_program.dart';
import 'workout_session_screen.dart';

/// One calendar day: template preview + start / edit log.
class WorkoutDayScreen extends StatelessWidget {
  const WorkoutDayScreen({
    super.key,
    required this.app,
    required this.day,
    required this.dayIndex,
  });

  final AppState app;
  final DateTime day;
  /// 0 = Monday … 6 = Sunday
  final int dayIndex;

  @override
  Widget build(BuildContext context) {
    final slot = app.weeklyPlan.days[dayIndex];
    final existing = app.programSessionForCalendarDay(day);
    final lastWeek = app.programSessionOneWeekBefore(day);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMEd().format(day)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Text(
            slot.title,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            slot.isRest
                ? 'Recovery day in your template. Walk, stretch, or take the day off.'
                : '${slot.exercises.length} exercises · new week = empty fields; last week is reference only.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (!slot.isRest && lastWeek != null) ...[
            const SizedBox(height: 12),
            Card(
              color: cs.tertiaryContainer.withOpacity(0.5),
              child: ListTile(
                leading: Icon(Icons.history, color: cs.onTertiaryContainer),
                title: Text(
                  'Last week (${DateFormat.MMMd().format(lastWeek.performedOn)})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${lastWeek.planDayTitle} · ${lastWeek.exercises.length} lifts logged',
                  style: tt.bodySmall,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (slot.isRest)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.spa_outlined, size: 64, color: cs.outline),
                    const SizedBox(height: 16),
                    Text('Rest day', style: tt.titleLarge),
                  ],
                ),
              ),
            )
          else ...[
            Text('Plan', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...slot.exercises.map(
              (e) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  title: Text(e.name),
                  trailing: Text(
                    '${e.targetSets} sets',
                    style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            if (existing != null) ...[
              const SizedBox(height: 20),
              Text(
                'Logged today',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                color: cs.primaryContainer.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final ex in existing.exercises) ...[
                        Text(
                          ex.name,
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ex.sets
                              .map((s) {
                                final w = s.weightKg != null ? '${s.weightKg} kg' : '—';
                                final r = s.reps != null ? '${s.reps} reps' : '—';
                                return 'Set ${s.setIndex}: $w × $r';
                              })
                              .join(' · '),
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: slot.isRest
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: FilledButton.icon(
                  onPressed: () async {
                    final ok = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (_) => WorkoutSessionScreen(
                          app: app,
                          workoutDate: day,
                          dayIndex: dayIndex,
                          planSlot: slot,
                          seedSession: existing,
                          lastWeekSession: lastWeek,
                        ),
                      ),
                    );
                    if (ok == true && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(existing != null ? Icons.edit : Icons.play_arrow),
                  label: Text(existing != null ? 'Update log' : 'Start workout'),
                ),
              ),
            ),
    );
  }
}
