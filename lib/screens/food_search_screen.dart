import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/food_reference.dart';
import '../services/local_food_catalog.dart';
import '../services/usda_fdc_service.dart';
import '../theme/macro_colors.dart';
import '../widgets/food_thumbnail.dart';
import 'food_quantity_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({
    super.key,
    required this.app,
    this.logDay,
    this.slotKey,
  });

  final AppState app;

  /// Calendar day the logged meal should roll up under (defaults to today).
  final DateTime? logDay;

  /// Plan slot id (`m1`…`m5`, `pre`, `post`, `extra`) or null.
  final String? slotKey;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _query = TextEditingController();
  Timer? _debounce;

  bool _loading = false;
  List<FoodSearchHit> _remote = [];
  List<FoodReference> _local = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _local = LocalFoodCatalog.search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _query.text.trim();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = UsdaFdcService(widget.app.usdaFdcApiKey);
      final local = LocalFoodCatalog.search(q);
      List<FoodSearchHit> remote = [];
      if (svc.hasApiKey && q.isNotEmpty) {
        remote = await svc.searchFoods(q);
      }
      if (!mounted) return;
      setState(() {
        _local = local;
        _remote = remote;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openRemoteHit(FoodSearchHit hit) async {
    final svc = UsdaFdcService(widget.app.usdaFdcApiKey);
    if (!svc.hasApiKey) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final food = await svc.fetchFoodDetail(hit.fdcId);
      if (!mounted) return;
      Navigator.pop(context);
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => FoodQuantityScreen(
            app: widget.app,
            food: food,
            popsAfterSave: 2,
            logDay: widget.logDay,
            slotKey: widget.slotKey,
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _openLocalFood(FoodReference food) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FoodQuantityScreen(
          app: widget.app,
          food: food,
          popsAfterSave: 2,
          logDay: widget.logDay,
          slotKey: widget.slotKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasRemote = UsdaFdcService(widget.app.usdaFdcApiKey).hasApiKey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search foods'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _query,
              onChanged: (_) => _scheduleSearch(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hasRemote
                    ? 'Try “chicken breast”, “egg white”…'
                    : 'Search built‑in foods (add USDA key in Profile for full DB)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _query.clear();
                          _runSearch();
                        },
                      ),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _error!,
                style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (hasRemote && _remote.isNotEmpty) ...[
                  Text(
                    'USDA FoodData Central',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._remote.map(
                    (h) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: FoodThumbnail(
                          name: h.description,
                          sourceNote: 'fdc:${h.fdcId}',
                          size: 44,
                        ),
                        title: Text(
                          h.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('FDC ID ${h.fdcId}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openRemoteHit(h),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Built‑in staples',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.secondary,
                      ),
                ),
                const SizedBox(height: 8),
                if (_local.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No matches. Try a shorter search.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                else
                  ..._local.map(
                    (f) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: FoodThumbnail(
                          name: f.name,
                          sourceNote: f.sourceNote,
                          imageCategory: f.imageCategory,
                          size: 44,
                        ),
                        title: Text(
                          f.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text:
                                    '${f.kcalPer100g.round()} kcal / 100 g · ',
                              ),
                              TextSpan(
                                text: 'P${f.proteinPer100g.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: MacroColors.protein,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: 'C${f.carbsPer100g.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: MacroColors.carbs,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: 'F${f.fatPer100g.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: MacroColors.fat,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openLocalFood(f),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
