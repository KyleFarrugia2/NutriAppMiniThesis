import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/food_reference.dart';

/// USDA FoodData Central (FDC) API client.
///
/// Sign up: https://fdc.nal.usda.gov/api-key-signup.html  
/// Or pass `--dart-define=USDA_API_KEY=your_key` for dev builds.
class UsdaFdcService {
  UsdaFdcService([String? apiKey])
      : _apiKey = (apiKey != null && apiKey.trim().isNotEmpty)
            ? apiKey.trim()
            : const String.fromEnvironment('USDA_API_KEY', defaultValue: '');

  final String _apiKey;

  bool get hasApiKey => _apiKey.isNotEmpty;

  static const _host = 'api.nal.usda.gov';

  Future<List<FoodSearchHit>> searchFoods(String query) async {
    if (!hasApiKey) return [];
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.https(_host, '/fdc/v1/foods/search', {
      'api_key': _apiKey,
      'query': q,
      'pageSize': '25',
      'dataType': 'Foundation,SR Legacy,Branded',
    });

    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw UsdaFdcException(
        'Search failed (${res.statusCode}). Check your API key.',
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final foods = body['foods'] as List<dynamic>? ?? [];
    final hits = <FoodSearchHit>[];
    for (final raw in foods) {
      if (raw is! Map<String, dynamic>) continue;
      final id = (raw['fdcId'] as num?)?.toInt();
      final desc = (raw['description'] as String?)?.trim() ?? '';
      if (id == null || desc.isEmpty) continue;
      hits.add(FoodSearchHit(fdcId: id, description: desc));
    }
    return hits;
  }

  Future<FoodReference> fetchFoodDetail(int fdcId) async {
    if (!hasApiKey) {
      throw UsdaFdcException('No USDA API key configured.');
    }
    final uri = Uri.https(_host, '/fdc/v1/food/$fdcId', {
      'api_key': _apiKey,
      'format': 'full',
    });
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw UsdaFdcException(
        'Food detail failed (${res.statusCode}) for FDC ID $fdcId.',
      );
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = _parseFoodDetail(json);
    if (parsed == null) {
      throw UsdaFdcException(
        'Could not read macros for this item. Try another result.',
      );
    }
    return parsed;
  }

  FoodReference? _parseFoodDetail(Map<String, dynamic> json) {
    final id = (json['fdcId'] as num?)?.toInt();
    final name =
        (json['description'] as String?)?.trim() ?? 'Selected food';

    final label = json['labelNutrients'] as Map<String, dynamic>?;
    final servingG = _servingGramsFromFood(json);

    if (label != null && servingG != null && servingG > 0) {
      final cal = _labelNum(label['calories']);
      final p = _labelNum(label['protein']);
      final c = _labelNum(label['carbohydrates']);
      final f = _labelNum(label['fat']);
      if (cal != null || p != null || c != null || f != null) {
        final kcal = cal ?? _estimateKcal(p, c, f);
        return FoodReference(
          fdcId: id,
          name: name,
          kcalPer100g: (kcal * 100 / servingG).clamp(0, 9000),
          proteinPer100g: ((p ?? 0) * 100 / servingG).clamp(0, 100),
          carbsPer100g: ((c ?? 0) * 100 / servingG).clamp(0, 100),
          fatPer100g: ((f ?? 0) * 100 / servingG).clamp(0, 100),
          sourceNote: id != null ? 'fdc:$id' : null,
        );
      }
    }

    final list = json['foodNutrients'] as List<dynamic>?;
    var kcal = _nutAmountByIds(list, {1008, 208});
    final p = _nutAmountByIds(list, {1003});
    final c = _nutAmountByIds(list, {1005});
    final f = _nutAmountByIds(list, {1004});

    if (kcal == null && (p != null || c != null || f != null)) {
      kcal = _estimateKcal(p, c, f);
    }
    if (kcal == null && p == null && c == null && f == null) {
      return null;
    }

    return FoodReference(
      fdcId: id,
      name: name,
      kcalPer100g: (kcal ?? _estimateKcal(p, c, f)).clamp(0, 9000),
      proteinPer100g: (p ?? 0).clamp(0, 100),
      carbsPer100g: (c ?? 0).clamp(0, 100),
      fatPer100g: (f ?? 0).clamp(0, 100),
      sourceNote: id != null ? 'fdc:$id' : null,
    );
  }

  static double? _labelNum(dynamic node) {
    if (node == null) return null;
    if (node is num) return node.toDouble();
    if (node is Map<String, dynamic>) {
      final v = node['value'];
      if (v is num) return v.toDouble();
    }
    return null;
  }

  static double? _servingGramsFromFood(Map<String, dynamic> json) {
    final w = (json['servingWeightGrams'] as num?)?.toDouble();
    if (w != null && w > 0) return w;

    final size = (json['servingSize'] as num?)?.toDouble();
    final unit =
        (json['servingSizeUnit'] as String?)?.toLowerCase().trim() ?? '';
    if (size != null && size > 0) {
      if (unit == 'g' || unit == 'grm' || unit == 'gm') return size;
      if (unit == 'ml' ||
          unit == 'milliliter' ||
          unit == 'milliliters') {
        return size;
      }
      if (unit == 'oz' || unit == 'ounce' || unit == 'ounces') {
        return size * 28.3495;
      }
    }
    return null;
  }

  static double? _nutAmountByIds(List<dynamic>? list, Set<int> ids) {
    if (list == null) return null;
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) continue;
      int? nid;
      final nutrient = raw['nutrient'];
      if (nutrient is Map<String, dynamic>) {
        nid = (nutrient['id'] as num?)?.toInt();
      }
      nid ??= (raw['nutrientId'] as num?)?.toInt();
      if (nid != null && ids.contains(nid)) {
        final amt = (raw['amount'] as num?)?.toDouble();
        if (amt != null) return amt;
      }
    }
    return null;
  }

  static double _estimateKcal(double? p, double? c, double? f) {
    return 4 * (p ?? 0) + 4 * (c ?? 0) + 9 * (f ?? 0);
  }
}

class UsdaFdcException implements Exception {
  UsdaFdcException(this.message);
  final String message;

  @override
  String toString() => message;
}
