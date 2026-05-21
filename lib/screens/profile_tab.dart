import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/user_profile.dart';
import 'profile_edit_screen.dart';
import 'feedback_screen.dart';
import 'research_study_screen.dart';
import 'usda_api_settings_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final p = app.profile;
        if (p == null) {
          return const Scaffold(
            body: Center(child: Text('No profile')),
          );
        }
        final e = app.engine;
        final bmr = e.bmr(p).round();
        final tdee = e.tdee(p).round();
        final cal = e.dailyCalorieTarget(p);
        final macros = e.macroGramTargets(p);
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.age} yrs · ${p.heightCm.round()} cm · ${p.weightKg.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(p.goal.label)),
                          Chip(label: Text(p.activityLevel.label)),
                          if (p.wearableStepsAvg != null)
                            Chip(
                              label: Text('~${p.wearableStepsAvg} steps/day'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Workout suggestion mode'),
                  subtitle: Text(
                    p.workoutGuidanceMode.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileEditScreen(app: app),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: cs.primaryContainer.withValues(alpha: 0.35),
                child: ListTile(
                  leading: Icon(Icons.science_outlined, color: cs.primary),
                  title: const Text('Research study session'),
                  subtitle: Text(
                    app.researchStudy.rq1Answerable && app.researchStudy.rq2Answerable
                        ? 'RQ1 & RQ2 data ready — tap to review or export'
                        : 'One guided pass to answer your thesis research questions',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ResearchStudyScreen(app: app),
                      ),
                    );
                  },
                ),
              ),
              if (app.hasDismissedSuggestionContent) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.replay_rounded, color: cs.primary),
                    title: const Text('Show dismissed suggestions again'),
                    subtitle: Text(
                      'Home insights, coach card, and per-slot macro hints.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    onTap: () async {
                      await app.restoreDismissedSuggestions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Suggestions are visible again.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Personalized energy & macros',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('BMR (Mifflin–St Jeor)'),
                      trailing: Text('$bmr kcal'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('TDEE (activity-adjusted)'),
                      trailing: Text('$tdee kcal'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Daily calorie target'),
                      subtitle: Text('Goal offset applied: ${p.goal.label}'),
                      trailing: Text(
                        '$cal',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Protein target'),
                      trailing: Text('${macros.proteinG.round()} g'),
                    ),
                    ListTile(
                      title: const Text('Carbs target'),
                      trailing: Text('${macros.carbsG.round()} g'),
                    ),
                    ListTile(
                      title: const Text('Fat target'),
                      trailing: Text('${macros.fatG.round()} g'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileEditScreen(app: app),
                    ),
                  );
                },
                child: const Text('Edit profile'),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(Icons.vpn_key_outlined, color: cs.primary),
                  title: const Text('USDA FoodData Central'),
                  subtitle: Text(
                    app.hasUsdaApiKey
                        ? 'API key on device — full food search enabled'
                        : 'Add a free key for live USDA search (optional)',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => UsdaApiSettingsScreen(app: app),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(Icons.rate_review_outlined, color: cs.primary),
                  title: const Text('Feedback & questions'),
                  subtitle: Text(
                    'Share tester feedback or ask about the app',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const FeedbackScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Privacy',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Data stays on this device via SharedPreferences. For studies, export and anonymize before sharing.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
