import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NutriWorkApp());
}

final AppState _appState = AppState();

class NutriWorkApp extends StatefulWidget {
  const NutriWorkApp({super.key});

  @override
  State<NutriWorkApp> createState() => _NutriWorkAppState();
}

class _NutriWorkAppState extends State<NutriWorkApp> {
  @override
  void initState() {
    super.initState();
    _appState.addListener(_onApp);
    _appState.bootstrap();
  }

  void _onApp() => setState(() {});

  @override
  void dispose() {
    _appState.removeListener(_onApp);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutri & Workout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _Root(app: _appState),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root({required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    if (!app.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (app.profile == null) {
      return OnboardingScreen(app: app);
    }
    return HomeShell(app: app);
  }
}
