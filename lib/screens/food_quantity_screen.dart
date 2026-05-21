import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../app_state.dart';
import '../models/food_reference.dart';
import '../models/meal_entry.dart';
import '../theme/macro_colors.dart';
import '../utils/egg_portions.dart';
import '../utils/meal_log_time.dart';
import '../widgets/food_thumbnail.dart';
import '../widgets/macro_calorie_chart.dart';

class FoodQuantityScreen extends StatefulWidget {
  const FoodQuantityScreen({
    super.key,
    required this.app,
    required this.food,
    this.popsAfterSave = 1,
    this.logDay,
    this.slotKey,
  });

  final AppState app;
  final FoodReference food;

  /// How many routes to pop after logging (search screen + this screen = 2).
  final int popsAfterSave;

  /// Calendar day this log belongs to (defaults to today).
  final DateTime? logDay;

  /// Plan slot: `m1`…`m5`, `pre`, `post`, `extra`, or null.
  final String? slotKey;

  @override
  State<FoodQuantityScreen> createState() => _FoodQuantityScreenState();
}

class _FoodQuantityScreenState extends State<FoodQuantityScreen> {
  static final _uuid = Uuid();
  late final bool _byPieceCount;
  late int _pieceCount;
  late double _grams;

  @override
  void initState() {
    super.initState();
    final food = widget.food;
    _byPieceCount = EggPortions.isCountedByPiece(food);
    if (EggPortions.isWholeEgg(food)) {
      _pieceCount = 2;
      _grams = EggPortions.gramsForWholeEggCount(_pieceCount);
    } else if (EggPortions.isEggWhite(food)) {
      _pieceCount = 1;
      _grams = 120;
    } else {
      _pieceCount = 1;
      _grams = 120;
    }
  }

  void _setPieceCount(int count) {
    setState(() {
      _pieceCount = count;
      _grams = EggPortions.gramsForWholeEggCount(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final scaled = food.scaledForGrams(_grams);
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat('#0.#');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portion'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Center(
            child: FoodThumbnail(
              name: food.name,
              sourceNote: food.sourceNote,
              imageCategory: food.imageCategory,
              size: 120,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            food.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              children: [
                TextSpan(
                  text:
                      'Per 100 g: ${food.kcalPer100g.round()} kcal · ',
                ),
                TextSpan(
                  text: 'P${fmt.format(food.proteinPer100g)}',
                  style: const TextStyle(
                    color: MacroColors.protein,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'C${fmt.format(food.carbsPer100g)}',
                  style: const TextStyle(
                    color: MacroColors.carbs,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'F${fmt.format(food.fatPer100g)} g',
                  style: const TextStyle(
                    color: MacroColors.fat,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (_byPieceCount) ...[
            Text(
              EggPortions.formatWholeEggs(_pieceCount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Count whole eggs (≈ ${EggPortions.gramsPerWholeEgg.round()} g each).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _pieceCount.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              label: EggPortions.formatWholeEggs(_pieceCount),
              onChanged: (v) => _setPieceCount(v.round()),
            ),
            Row(
              children: [
                for (final n in [1, 2, 3, 4])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: OutlinedButton(
                        onPressed: () => _setPieceCount(n),
                        child: Text(EggPortions.formatWholeEggs(n)),
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            Text(
              'Amount (${_grams.round()} g)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Slider(
              value: _grams.clamp(10, 800),
              min: 10,
              max: 800,
              divisions: 158,
              label: '${_grams.round()} g',
              onChanged: (v) => setState(() => _grams = v),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _grams = 100),
                    child: const Text('100 g'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _grams = 150),
                    child: const Text('150 g'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _grams = 200),
                    child: const Text('200 g'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 28),
          Text(
            'This portion',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroCol(
                    label: 'Calories',
                    value: '${scaled.calories}',
                    unit: 'kcal',
                    valueColor: cs.primary,
                  ),
                  _MacroCol(
                    label: 'Protein',
                    value: fmt.format(scaled.proteinG),
                    unit: 'g',
                    valueColor: MacroColors.protein,
                  ),
                  _MacroCol(
                    label: 'Carbs',
                    value: fmt.format(scaled.carbsG),
                    unit: 'g',
                    valueColor: MacroColors.carbs,
                  ),
                  _MacroCol(
                    label: 'Fat',
                    value: fmt.format(scaled.fatG),
                    unit: 'g',
                    valueColor: MacroColors.fat,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          MacroCalorieVisuals(
            proteinG: scaled.proteinG,
            carbsG: scaled.carbsG,
            fatG: scaled.fatG,
            size: 156,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () async {
              final day = widget.logDay ?? DateTime.now();
              final meal = MealEntry(
                id: _uuid.v4(),
                name: _byPieceCount
                    ? EggPortions.mealNameForWholeEggs(_pieceCount)
                    : '${food.name} (${_grams.round()} g)',
                calories: scaled.calories,
                proteinG: scaled.proteinG,
                carbsG: scaled.carbsG,
                fatG: scaled.fatG,
                loggedAt: MealLogTime.onCalendarDay(day),
                imageNote: food.sourceNote,
                imageCategory: food.imageCategory,
                slotKey: widget.slotKey,
              );
              await widget.app.addMeal(meal);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged ${meal.name}'),
                ),
              );
              final n = widget.popsAfterSave.clamp(1, 4);
              for (var i = 0; i < n; i++) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.check_rounded),
            label: Text(
              widget.logDay != null &&
                      (widget.logDay!.year != DateTime.now().year ||
                          widget.logDay!.month != DateTime.now().month ||
                          widget.logDay!.day != DateTime.now().day)
                  ? 'Add to this day’s log'
                  : 'Add to today’s log',
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCol extends StatelessWidget {
  const _MacroCol({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
        Text(unit, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
