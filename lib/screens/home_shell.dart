import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/user_profile.dart';
import '../widgets/hud_bottom_nav.dart';
import '../widgets/level_hud_chip.dart';
import 'dashboard_tab.dart';
import 'nutrition_tab.dart';
import 'profile_tab.dart';
import 'workout_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.app});

  final AppState app;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowStepsNudge());
  }

  Future<void> _maybeShowStepsNudge() async {
    final app = widget.app;
    if (!app.loaded || app.profile == null) return;
    if (!await app.shouldOfferStepsNudge()) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily steps recommendation'),
        content: Text(
          'Whether your goal is losing weight, maintaining weight, or gaining muscle, '
          'we recommend averaging at least $kRecommendedMinDailySteps steps per day '
          '(unless your clinician tells you otherwise). '
          'Add your typical daily steps under Profile if you have not already.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) await app.dismissStepsNudgeForToday();
  }

  /// Keeps the chip clear of each tab’s AppBar trailing actions.
  double _levelChipRightInset(BuildContext context) {
    final mq = MediaQuery.of(context);
    switch (_index) {
      case 1:
        return mq.padding.right + 64;
      case 2:
        return mq.padding.right + 120;
      default:
        return mq.padding.right + 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(app: widget.app),
      NutritionTab(app: widget.app),
      WorkoutTab(app: widget.app),
      ProfileTab(app: widget.app),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              Theme.of(context).colorScheme.primary,
              Theme.of(context).scaffoldBackgroundColor,
              0.88,
            )!,
            Theme.of(context).scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.42],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            IndexedStack(index: _index, children: pages),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 4,
              right: _levelChipRightInset(context),
              child: ListenableBuilder(
                listenable: widget.app,
                builder: (_, __) => LevelHudChip(
                  snapshot: widget.app.progressionSnapshot,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: HudBottomNav(
          currentIndex: _index,
          onSelect: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
