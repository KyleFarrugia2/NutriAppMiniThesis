import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';

class UsdaApiSettingsScreen extends StatefulWidget {
  const UsdaApiSettingsScreen({super.key, required this.app});

  final AppState app;

  @override
  State<UsdaApiSettingsScreen> createState() => _UsdaApiSettingsScreenState();
}

class _UsdaApiSettingsScreenState extends State<UsdaApiSettingsScreen> {
  late final TextEditingController _key;

  @override
  void initState() {
    super.initState();
    _key = TextEditingController(text: widget.app.usdaFdcApiKey ?? '');
  }

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = _key.text.trim();
    await widget.app.setUsdaFdcApiKey(t.isEmpty ? null : t);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _clear() async {
    _key.clear();
    await widget.app.setUsdaFdcApiKey(null);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('USDA API key')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'FoodData Central',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'A free key unlocks live search across USDA Foundation, SR Legacy, and branded foods. '
            'Without it, the app still offers a built‑in list of common staples.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(
                  text: 'https://fdc.nal.usda.gov/api-key-signup.html',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign‑up link copied')),
              );
            },
            icon: const Icon(Icons.link),
            label: const Text('Open USDA sign‑up page (copy URL)'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _key,
            decoration: const InputDecoration(
              labelText: 'API key',
              hintText: 'Paste your key here',
            ),
            autocorrect: false,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Save key on this device'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _clear,
            child: const Text('Remove key'),
          ),
        ],
      ),
    );
  }
}
