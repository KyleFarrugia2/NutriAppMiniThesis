import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../app_state.dart';
import '../models/meal_entry.dart';
import '../services/personalization_engine.dart';

class NutritionTab extends StatelessWidget {
  const NutritionTab({super.key, required this.app});

  final AppState app;

  static final _uuid = Uuid();

  Future<void> _openLogDialog(BuildContext context) async {
    final name = TextEditingController();
    final cal = TextEditingController();
    final p = TextEditingController(text: '25');
    final c = TextEditingController(text: '40');
    final f = TextEditingController(text: '12');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Meal name'),
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: cal,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
              ),
              TextField(
                controller: p,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Protein (g)'),
              ),
              TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
              ),
              TextField(
                controller: f,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Fat (g)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final meal = MealEntry(
      id: _uuid.v4(),
      name: name.text.trim().isEmpty ? 'Meal' : name.text.trim(),
      calories: int.tryParse(cal.text.trim()) ?? 0,
      proteinG: double.tryParse(p.text.trim()) ?? 0,
      carbsG: double.tryParse(c.text.trim()) ?? 0,
      fatG: double.tryParse(f.text.trim()) ?? 0,
      loggedAt: DateTime.now(),
    );
    await app.addMeal(meal);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal logged')),
      );
    }
  }

  void _foodImageStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Food image recognition: plug in a CNN / API here (thesis module).',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final profile = app.profile;
        final engine = app.engine;
        final today = engine.mealsForDay(app.meals, DateTime.now());
        today.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

        DailyNutritionSummary? summary;
        if (profile != null) {
          summary = engine.summarizeDay(profile, today);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nutrition'),
            actions: [
              IconButton(
                tooltip: 'Food image (CV pipeline)',
                onPressed: () => _foodImageStub(context),
                icon: const Icon(Icons.image_search_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openLogDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Log meal'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              if (summary != null)
                Card(
                  child: ListTile(
                    title: const Text('Today’s totals'),
                    subtitle: Text(
                      '${summary.caloriesConsumed} kcal · P ${summary.proteinG.round()}g · '
                      'C ${summary.carbsG.round()}g · F ${summary.fatG.round()}g',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Today’s meals',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (today.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No meals logged yet.\nAdd one or use image recognition when integrated.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                ...today.map((m) => Card(
                      child: ListTile(
                        title: Text(m.name),
                        subtitle: Text(
                          '${m.calories} kcal · P${m.proteinG.round()} '
                          'C${m.carbsG.round()} F${m.fatG.round()} · '
                          '${DateFormat.jm().format(m.loggedAt)}',
                        ),
                        trailing: m.imageNote != null
                            ? const Icon(Icons.image_outlined)
                            : null,
                      ),
                    )),
              const SizedBox(height: 24),
              Text(
                'Recent (all days)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...app.meals.take(20).map(
                    (m) => ListTile(
                      dense: true,
                      title: Text(m.name),
                      subtitle: Text(DateFormat.yMMMd().add_jm().format(m.loggedAt)),
                      trailing: Text('${m.calories}'),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
