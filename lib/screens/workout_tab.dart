import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../app_state.dart';
import '../models/user_profile.dart';
import '../models/weekly_workout_program.dart';
import '../models/workout_entry.dart';
import '../models/workout_split_style.dart';
import '../utils/week_utils.dart';
import 'edit_weekly_plan_screen.dart';
import 'regenerate_workout_plan_screen.dart';
import 'workout_day_screen.dart';

class WorkoutTab extends StatefulWidget {
  const WorkoutTab({super.key, required this.app});

  final AppState app;

  @override
  State<WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<WorkoutTab> {
  final _uuid = Uuid();
  late DateTime _weekMonday;

  @override
  void initState() {
    super.initState();
    _weekMonday = mondayOfWeekContaining(DateTime.now());
  }

  void _shiftWeek(int delta) {
    setState(() => _weekMonday = addDays(_weekMonday, delta * 7));
  }

  DateTime _dayInWeek(int index) => addDays(_weekMonday, index);

  bool _inSelectedWeek(DateTime d) {
    final x = dateOnly(d);
    final start = dateOnly(_weekMonday);
    final end = addDays(start, 6);
    return !x.isBefore(start) && !x.isAfter(end);
  }

  Future<void> _legacyLogSheet(BuildContext context) async {
    final app = widget.app;
    final title = TextEditingController(text: 'Training session');
    final minutes = TextEditingController(text: '45');
    final rpe = TextEditingController(text: '7');
    WorkoutType type = WorkoutType.strength;
    String? sheetError;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Quick log (legacy)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (sheetError != null) ...[
                    Text(
                      sheetError!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (_) => setModal(() => sheetError = null),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: minutes,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                    onChanged: (_) => setModal(() => sheetError = null),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rpe,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'RPE 1–10 (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WorkoutType>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: WorkoutType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModal(() => type = v);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          final dur = int.tryParse(minutes.text.trim());
                          if (title.text.trim().isEmpty) {
                            setModal(() => sheetError = 'Add a session title.');
                            return;
                          }
                          if (dur == null || dur <= 0) {
                            setModal(
                              () => sheetError = 'Duration must be greater than 0.',
                            );
                            return;
                          }
                          Navigator.pop(ctx, true);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (ok != true) return;
    final entry = WorkoutEntry(
      id: _uuid.v4(),
      title: title.text.trim(),
      type: type,
      durationMinutes: int.parse(minutes.text.trim()),
      completedAt: DateTime.now(),
      rpe: int.tryParse(rpe.text.trim()),
    );
    await app.addWorkout(entry);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved “${entry.title}” (${entry.durationMinutes} min)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static const _abbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final profile = app.profile;
        final sug = app.workoutSuggestion();
        final mode = profile?.workoutGuidanceMode;
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        final weekEnd = addDays(_weekMonday, 6);
        final weekSessions = app.programSessions
            .where((s) => _inSelectedWeek(s.performedOn))
            .toList()
          ..sort((a, b) => b.performedOn.compareTo(a.performedOn));
        final legacy = app.workouts
            .where((w) => w.logSource != kWeeklyProgramLogSource)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Workouts'),
            actions: [
              IconButton(
                tooltip: 'Generate a different split',
                icon: const Icon(Icons.autorenew),
                onPressed: profile == null
                    ? null
                    : () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                RegenerateWorkoutPlanScreen(app: app),
                          ),
                        );
                      },
              ),
              IconButton(
                tooltip: 'Edit weekly split',
                icon: const Icon(Icons.edit_calendar_outlined),
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => EditWeeklyPlanScreen(app: app),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                itemBuilder: (c) => const [
                  PopupMenuItem(
                    value: 'legacy',
                    child: Text('Quick log (legacy)'),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'legacy') _legacyLogSheet(context);
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (!app.workoutSuggestedNoteDismissed) ...[
                Card(
                  color: cs.secondaryContainer.withOpacity(0.65),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Icon(
                            Icons.info_outline,
                            color: cs.onSecondaryContainer,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              '${kRecoveryRestDaysMessage} '
                              'Tap the regenerate icon to switch splits (PPL, upper/lower, full body, …) as often as you like, '
                              'or use the calendar button to edit days. Tap close to hide.',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSecondaryContainer,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Dismiss',
                          onPressed: () => app.dismissWorkoutSuggestedNote(),
                          icon: Icon(Icons.close, color: cs.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: () => _shiftWeek(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${DateFormat.MMMd().format(_weekMonday)} – ${DateFormat.yMMMd().format(weekEnd)}',
                      textAlign: TextAlign.center,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next week',
                    onPressed: () => _shiftWeek(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tap a day to train. Each new week: empty weight/reps fields — last week shows as hints only.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
              ),
              if (profile != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => RegenerateWorkoutPlanScreen(app: app),
                      ),
                    );
                  },
                  icon: const Icon(Icons.autorenew, size: 20),
                  label: Text(
                    'Not for you? Try another split (${profile.workoutSplitStyle.label})',
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: WeeklyWorkoutPlan.slotCount,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final day = _dayInWeek(i);
                    final slot = app.weeklyPlan.days[i];
                    final logged = app.programSessionForCalendarDay(day) != null;
                    Color chipFill() {
                      if (slot.isRest) {
                        return cs.surfaceContainerHighest.withOpacity(0.45);
                      }
                      switch (i % 3) {
                        case 0:
                          return cs.primaryContainer.withOpacity(0.75);
                        case 1:
                          return cs.secondaryContainer.withOpacity(0.75);
                        default:
                          return cs.tertiaryContainer.withOpacity(0.85);
                      }
                    }

                    Color weekdayColor() {
                      if (slot.isRest) return cs.onSurfaceVariant;
                      switch (i % 3) {
                        case 0:
                          return cs.primary;
                        case 1:
                          return cs.secondary;
                        default:
                          return cs.tertiary;
                      }
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => WorkoutDayScreen(
                              app: app,
                              day: day,
                              dayIndex: i,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: chipFill(),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: logged ? cs.primary : cs.outlineVariant,
                            width: logged ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _abbr[i],
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: weekdayColor(),
                              ),
                            ),
                            Text(
                              '${day.month}/${day.day}',
                              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const Spacer(),
                            Text(
                              slot.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                            if (logged)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Icon(Icons.check_circle,
                                    size: 16, color: cs.primary),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (sug != null && !app.workoutCoachSuggestionDismissed) ...[
                Card(
                  color: cs.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coach suggestion',
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (mode != null) ...[
                                    const SizedBox(height: 8),
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(
                                        mode?.shortLabel ?? '—',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Dismiss',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => app.dismissWorkoutCoachSuggestion(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: cs.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(sug.title, style: tt.titleMedium),
                        const SizedBox(height: 6),
                        Text(sug.rationale, style: tt.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Intensity: ${sug.intensityHint}',
                          style: tt.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: () async {
                              await app.recordSuggestionAccepted();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Recorded: suggestion accepted (research metric).',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 20),
                            label: const Text('I followed this suggestion'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Program logs · this week',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (weekSessions.isEmpty)
                Text(
                  'No program sessions logged for this week yet.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                )
              else
                ...weekSessions.map(
                  (s) => Dismissible(
                    key: ValueKey(s.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Delete session?'),
                              content: Text('Remove ${s.planDayTitle} on ${DateFormat.yMMMd().format(s.performedOn)}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) => app.removeProgramWorkoutSession(s.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: cs.errorContainer,
                      child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
                    ),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.fitness_center, color: cs.onPrimaryContainer),
                        ),
                        title: Text(s.planDayTitle),
                        subtitle: Text(
                          '${DateFormat.yMMMd().format(s.performedOn)} · '
                          '${s.durationMinutes ?? '—'} min · ${s.exercises.length} exercises',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          final di = s.weekdayIndex.clamp(0, 6);
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => WorkoutDayScreen(
                                app: app,
                                day: s.performedOn,
                                dayIndex: di,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Quick logs (legacy)',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (legacy.isEmpty)
                Text(
                  'None — use the menu (⋯) to add a simple session without the program.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                )
              else
                ...legacy.map(
                  (w) => Dismissible(
                    key: ValueKey(w.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Delete workout?'),
                              content: Text('Remove “${w.title}”?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) => app.removeWorkout(w.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: cs.errorContainer,
                      child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
                    ),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(w.title),
                        subtitle: Text(
                          '${w.type.label} · ${w.durationMinutes} min'
                          '${w.rpe != null ? ' · RPE ${w.rpe}' : ''}\n'
                          '${DateFormat.yMMMd().add_jm().format(w.completedAt)}',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
