import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../app_state.dart';
import '../models/workout_entry.dart';

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key, required this.app});

  final AppState app;

  static final _uuid = Uuid();

  Future<void> _openLogSheet(BuildContext context) async {
    final title = TextEditingController(text: 'Training session');
    final minutes = TextEditingController(text: '45');
    final rpe = TextEditingController(text: '7');
    WorkoutType type = WorkoutType.strength;

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
                    'Log workout',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: minutes,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rpe,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'RPE 1–10 (optional, for adaptation)',
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
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Save workout'),
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
      durationMinutes: int.tryParse(minutes.text.trim()) ?? 0,
      completedAt: DateTime.now(),
      rpe: int.tryParse(rpe.text.trim()),
    );
    await app.addWorkout(entry);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final sug = app.workoutSuggestion();
        return Scaffold(
          appBar: AppBar(title: const Text('Workouts')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openLogSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Log workout'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              if (sug != null)
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adaptive suggestion',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(sug.title),
                        const SizedBox(height: 4),
                        Text(
                          sug.rationale,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (app.workouts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No workouts yet.\nLogging builds the sequence-aware recommender context.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                ...app.workouts.map(
                  (w) => Card(
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
            ],
          ),
        );
      },
    );
  }
}
