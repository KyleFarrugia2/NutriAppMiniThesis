import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../app_state.dart';
import '../models/meal_entry.dart';
import '../services/meal_plan_layout.dart';
import '../services/meal_suggestion_service.dart';
import '../services/personalization_engine.dart';
import '../theme/macro_colors.dart';
import '../utils/meal_log_time.dart';
import '../widgets/food_thumbnail.dart';
import 'food_search_screen.dart';

class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key, required this.app});

  final AppState app;

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  final _uuid = Uuid();
  late DateTime _selectedDay;

  /// First day of the month shown in the horizontal day strip.
  late DateTime _visibleMonth;

  static const double _dayChipHeight = 76;
  static const double _dayChipWidth = 50;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _selectedDay = _dateOnly(n);
    _visibleMonth = DateTime(n.year, n.month, 1);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daysInMonth(DateTime monthStart) =>
      DateTime(monthStart.year, monthStart.month + 1, 0).day;

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  String? _slotTitle(String? id, bool training) {
    if (id == null) return null;
    if (id == 'extra') return 'Extra';
    final defs = training ? MealSlotDef.training() : MealSlotDef.rest();
    for (final d in defs) {
      if (d.id == id) return d.title;
    }
    return id;
  }

  void _showAddSheet(
    BuildContext context, {
    required DateTime logDay,
    String? slotKey,
  }) {
    final app = widget.app;
    final cs = Theme.of(context).colorScheme;
    final training = app.isTrainingDay(logDay);
    final slotHint = _slotTitle(slotKey, training);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Add to log',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (slotHint != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Slot: $slotHint · ${DateFormat.yMMMd().format(logDay)}',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.search, color: cs.onPrimaryContainer),
                  ),
                  title: const Text('Search foods'),
                  subtitle: Text(
                    app.hasUsdaApiKey
                        ? 'USDA FoodData Central + built‑in staples'
                        : 'Built‑in staples (add USDA key in Profile for live search)',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => FoodSearchScreen(
                          app: app,
                          logDay: logDay,
                          slotKey: slotKey,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.secondaryContainer,
                    child: Icon(Icons.edit_note, color: cs.onSecondaryContainer),
                  ),
                  title: const Text('Custom meal'),
                  subtitle: const Text('Enter name and macros manually'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openCustomMealDialog(
                      context,
                      logDay: logDay,
                      slotKey: slotKey,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCustomMealDialog(
    BuildContext context, {
    required DateTime logDay,
    String? slotKey,
  }) async {
    final app = widget.app;
    final name = TextEditingController();
    final cal = TextEditingController();
    final p = TextEditingController();
    final c = TextEditingController();
    final f = TextEditingController();

    String? dialogError;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final errColor = Theme.of(ctx).colorScheme.error;
          return AlertDialog(
            title: const Text('Custom meal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (dialogError != null) ...[
                    Text(
                      dialogError!,
                      style: Theme.of(ctx)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: errColor, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Meal name'),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) {
                      if (dialogError != null) {
                        setModal(() => dialogError = null);
                      }
                    },
                  ),
                  TextField(
                    controller: cal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal)',
                    ),
                    onChanged: (_) {
                      if (dialogError != null) {
                        setModal(() => dialogError = null);
                      }
                    },
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
                onPressed: () {
                  if (name.text.trim().isEmpty) {
                    setModal(() => dialogError = 'Enter a meal name.');
                    return;
                  }
                  final calVal = int.tryParse(cal.text.trim());
                  if (calVal == null || calVal <= 0) {
                    setModal(
                      () => dialogError = 'Enter a valid calorie amount (> 0).',
                    );
                    return;
                  }
                  Navigator.pop(ctx, true);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true) return;
    final meal = MealEntry(
      id: _uuid.v4(),
      name: name.text.trim(),
      calories: int.parse(cal.text.trim()),
      proteinG: double.tryParse(p.text.trim()) ?? 0,
      carbsG: double.tryParse(c.text.trim()) ?? 0,
      fatG: double.tryParse(f.text.trim()) ?? 0,
      loggedAt: MealLogTime.onCalendarDay(logDay),
      imageNote: 'manual',
      slotKey: slotKey,
    );
    await app.addMeal(meal);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged “${meal.name}” (${meal.calories} kcal)'),
        ),
      );
    }
  }

  Future<bool> _confirmDeleteMeal(BuildContext context, MealEntry m) async {
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Delete meal?'),
            content: Text('Remove “${m.name}” from this day?'),
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
  }

  Widget _mealDismissible({
    required BuildContext context,
    required AppState app,
    required MealEntry m,
    required ColorScheme cs,
  }) {
    return Dismissible(
      key: ValueKey(m.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDeleteMeal(context, m),
      onDismissed: (_) => app.removeMeal(m.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: cs.errorContainer,
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: FoodThumbnail.fromMeal(
          mealName: m.name,
          imageNote: m.imageNote,
          imageCategory: m.imageCategory,
          size: 44,
        ),
        title: Text(m.name),
        subtitle: Text(
          '${m.calories} kcal · P${m.proteinG.round()} '
          'C${m.carbsG.round()} F${m.fatG.round()} · '
          '${DateFormat.jm().format(m.loggedAt)}',
        ),
        trailing: _mealSourceIcon(m.imageNote),
        dense: true,
      ),
    );
  }

  Widget _slotCard({
    required BuildContext context,
    required AppState app,
    required MealSlotDef slot,
    required List<MealEntry> inSlot,
    required DailyNutritionSummary? targets,
    required DateTime logDay,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sug = targets == null
        ? null
        : MealSlotDef.suggestedMacros(slot: slot, targets: targets);
    final mealSug = app.mealSuggestionForSlot(logDay, slot.id);
    final slotEmpty = inSlot.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.title,
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slot.hint,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Add food to this slot',
                  onPressed: () => _showAddSheet(
                    context,
                    logDay: logDay,
                    slotKey: slot.id,
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            if (sug != null && !app.mealSlotMacroSuggestionsHidden) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, right: 4),
                      child: Text(
                        'Suggested ~${sug.kcal} kcal · P${sug.p} · C${sug.c} · F${sug.f}',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Hide suggested targets for all slots',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () => app.dismissMealSlotMacroSuggestions(),
                    icon: Icon(Icons.close_rounded, size: 20, color: cs.primary),
                  ),
                ],
              ),
            ] else if (sug == null) ...[
              const SizedBox(height: 4),
              Text(
                'Complete your profile for per-slot targets.',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            if (mealSug != null && slotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu, size: 18, color: cs.tertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mealSug.title,
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mealSug.summaryLine,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onTertiaryContainer,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '~${mealSug.totalCalories} kcal · P${mealSug.totalProteinG.round()} · '
                      'C${mealSug.totalCarbsG.round()} · F${mealSug.totalFatG.round()}',
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await app.acceptSuggestedMeal(
                          logDay: logDay,
                          suggestion: mealSug,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logged ${slot.title}')),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text('Accept & log meal'),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 20),
            if (inSlot.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  'Nothing logged in this slot yet.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              )
            else
              ...inSlot.map(
                (m) => _mealDismissible(
                  context: context,
                  app: app,
                  m: m,
                  cs: cs,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _extraOrUnassignedSection({
    required BuildContext context,
    required AppState app,
    required String title,
    required String subtitle,
    required List<MealEntry> meals,
    required ColorScheme cs,
    required DateTime logDay,
    String? addSlotKey,
  }) {
    final tt = Theme.of(context).textTheme;
    if (meals.isEmpty && addSlotKey == null) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (addSlotKey != null)
                  IconButton(
                    tooltip: 'Add extra meal',
                    onPressed: () => _showAddSheet(
                      context,
                      logDay: logDay,
                      slotKey: addSlotKey,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
              ],
            ),
            const Divider(height: 20),
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  addSlotKey != null
                      ? 'Tap + to log an extra meal.'
                      : 'No unassigned items.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              )
            else
              ...meals.map(
                (m) => _mealDismissible(
                  context: context,
                  app: app,
                  m: m,
                  cs: cs,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dayStrip(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final today = _dateOnly(DateTime.now());
    final days = _daysInMonth(_visibleMonth);

    Widget navArrow({required IconData icon, required VoidCallback onPressed, required String tooltip}) {
      return IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        style: IconButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          navArrow(
            icon: Icons.chevron_left,
            tooltip: 'Previous month',
            onPressed: () => _shiftMonth(-1),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.yMMMM().format(_visibleMonth),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: _dayChipHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemCount: days,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final day = DateTime(_visibleMonth.year, _visibleMonth.month, i + 1);
                      final selected = _sameDate(day, _selectedDay);
                      final isToday = _sameDate(day, today);
                      return InkWell(
                        onTap: () => setState(() => _selectedDay = day),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: _dayChipWidth,
                          height: _dayChipHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected
                                ? cs.primaryContainer
                                : cs.surfaceContainerHighest.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isToday
                                  ? cs.primary
                                  : cs.outlineVariant.withOpacity(0.5),
                              width: isToday ? 2 : 1,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat.E().format(day),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: tt.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                    color: selected
                                        ? cs.onPrimaryContainer
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${day.day}',
                                  maxLines: 1,
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                    color: selected
                                        ? cs.onPrimaryContainer
                                        : cs.onSurface,
                                  ),
                                ),
                                Text(
                                  DateFormat.MMM().format(day),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: tt.labelSmall?.copyWith(
                                    fontSize: 10,
                                    height: 1.1,
                                    color: selected
                                        ? cs.onPrimaryContainer
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          navArrow(
            icon: Icons.chevron_right,
            tooltip: 'Next month',
            onPressed: () => _shiftMonth(1),
          ),
        ],
      ),
    );
  }

  void _showUsdaInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Food search'),
        content: Text(
          'Search uses the USDA FoodData Central API when you add a free API key under Profile. '
          'Without a key, a small built‑in list of common foods (e.g. chicken breast, eggs) is still searchable. '
          'Macros scale linearly with the portion weight you choose (per 100 g basis).',
          style: TextStyle(color: cs.onSurfaceVariant, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Widget? _mealSourceIcon(String? note) {
    if (note == null) return null;
    if (note == 'manual') {
      return const Icon(Icons.edit_note_outlined, size: 22);
    }
    if (note.startsWith('suggested:')) {
      return const Icon(Icons.auto_awesome, size: 22);
    }
    if (note.startsWith('fdc:') || note.startsWith('local:')) {
      return const Icon(Icons.verified_outlined, size: 22);
    }
    return const Icon(Icons.info_outline, size: 22);
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final profile = app.profile;
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        final summary = app.daySummary(_selectedDay);
        final targets = app.dailyTargets(_selectedDay);
        final training = app.isTrainingDay(_selectedDay);
        final slots =
            training ? MealSlotDef.training() : MealSlotDef.rest();

        final dayMeals = List<MealEntry>.from(app.mealsOnDay(_selectedDay));
        dayMeals.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

        List<MealEntry> inSlot(String id) =>
            dayMeals.where((m) => m.slotKey == id).toList();

        final extraMeals = inSlot('extra');
        final unassigned =
            dayMeals.where((m) => m.slotKey == null).toList();

        final allSuggestions = profile != null
            ? app.mealSuggestionsForDay(_selectedDay)
            : <String, SuggestedMeal>{};
        final emptySlotsWithSug = slots
            .where((s) => inSlot(s.id).isEmpty && allSuggestions.containsKey(s.id))
            .toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                pinned: true,
                title: const Text('Nutrition'),
                actions: [
                  IconButton(
                    tooltip: 'About USDA search',
                    onPressed: () => _showUsdaInfo(context),
                    icon: const Icon(Icons.info_outline),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _dayStrip(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary.withOpacity(0.12),
                              cs.surface,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cs.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      color: cs.primary, size: 26),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      DateFormat.yMMMEd().format(_selectedDay),
                                      style: tt.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                summary != null
                                    ? '${summary.caloriesConsumed} / ${summary.calorieTarget} kcal · '
                                        'P${summary.proteinG.round()} / ${summary.proteinTargetG.round()}g · '
                                        'C${summary.carbsG.round()} / ${summary.carbsTargetG.round()}g · '
                                        'F${summary.fatG.round()} / ${summary.fatTargetG.round()}g'
                                    : 'Complete your profile for calorie and macro targets.',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (profile != null) ...[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: SegmentedButton<bool>(
                                    segments: const [
                                      ButtonSegment(
                                        value: false,
                                        label: Text('Rest day'),
                                        icon: Icon(Icons.hotel_outlined, size: 18),
                                      ),
                                      ButtonSegment(
                                        value: true,
                                        label: Text('Training'),
                                        icon: Icon(Icons.fitness_center_outlined,
                                            size: 18),
                                      ),
                                    ],
                                    selected: {training},
                                    onSelectionChanged: (Set<bool> next) {
                                      final v = next.isEmpty ? training : next.first;
                                      app.setTrainingDay(_selectedDay, v);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Calorie and macro targets are ~10% higher on Training days and ~10% lower on Rest days.',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.outlineVariant.withOpacity(0.4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 22, color: cs.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  training
                                      ? 'Meals 1–3 can be logged in any order. Use Pre workout before training and Post workout after, when you can.'
                                      : 'On a rest day, meals 1–5 are flexible in order. Use Extra for snacks or small add-ons.',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.list(
                  children: [
                    if (summary != null) ...[
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cs.primaryContainer,
                            child: Icon(
                              Icons.local_dining,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            'This day’s macro totals',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text.rich(
                            TextSpan(
                              style: tt.bodyMedium,
                              children: [
                                TextSpan(
                                  text:
                                      '${summary.caloriesConsumed} kcal (target ${summary.calorieTarget}) · ',
                                ),
                                TextSpan(
                                  text: 'P ${summary.proteinG.round()}g',
                                  style: const TextStyle(
                                    color: MacroColors.protein,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: ' · '),
                                TextSpan(
                                  text: 'C ${summary.carbsG.round()}g',
                                  style: const TextStyle(
                                    color: MacroColors.carbs,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: ' · '),
                                TextSpan(
                                  text: 'F ${summary.fatG.round()}g',
                                  style: const TextStyle(
                                    color: MacroColors.fat,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      training ? 'Training day slots' : 'Rest day slots',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (emptySlotsWithSug.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          for (final s in emptySlotsWithSug) {
                            final sug = allSuggestions[s.id];
                            if (sug == null) continue;
                            await app.acceptSuggestedMeal(
                              logDay: _selectedDay,
                              suggestion: sug,
                            );
                          }
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Logged ${emptySlotsWithSug.length} suggested meals',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.done_all),
                        label: Text(
                          'Accept all ${emptySlotsWithSug.length} suggested meals',
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    ...slots.map(
                      (s) => _slotCard(
                        context: context,
                        app: app,
                        slot: s,
                        inSlot: inSlot(s.id),
                        targets: targets,
                        logDay: _selectedDay,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _extraOrUnassignedSection(
                      context: context,
                      app: app,
                      title: 'Extra meals',
                      subtitle: 'Snacks, desserts, or anything outside the main slots.',
                      meals: extraMeals,
                      cs: cs,
                      logDay: _selectedDay,
                      addSlotKey: 'extra',
                    ),
                    _extraOrUnassignedSection(
                      context: context,
                      app: app,
                      title: 'Unassigned',
                      subtitle:
                          'Items logged before slots were added, or without a slot.',
                      meals: unassigned,
                      cs: cs,
                      logDay: _selectedDay,
                      addSlotKey: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSheet(
              context,
              logDay: _selectedDay,
              slotKey: 'extra',
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add food'),
          ),
        );
      },
    );
  }
}
