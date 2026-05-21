import 'package:flutter/material.dart';

/// Minimal cartoon-style icon per food category (no random photos).
class FoodCategoryVisual {
  const FoodCategoryVisual({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

class FoodImageResolver {
  FoodImageResolver._();

  static const _visuals = <String, FoodCategoryVisual>{
    'chicken': FoodCategoryVisual(
      icon: Icons.egg_alt_rounded,
      background: Color(0xFFFFF3E0),
      foreground: Color(0xFFE65100),
    ),
    'turkey': FoodCategoryVisual(
      icon: Icons.egg_alt_rounded,
      background: Color(0xFFFFECB3),
      foreground: Color(0xFFF57F17),
    ),
    'beef': FoodCategoryVisual(
      icon: Icons.set_meal_rounded,
      background: Color(0xFFFFEBEE),
      foreground: Color(0xFFC62828),
    ),
    'pork': FoodCategoryVisual(
      icon: Icons.set_meal_rounded,
      background: Color(0xFFFCE4EC),
      foreground: Color(0xFFAD1457),
    ),
    'ham': FoodCategoryVisual(
      icon: Icons.lunch_dining_rounded,
      background: Color(0xFFFFE0B2),
      foreground: Color(0xFFEF6C00),
    ),
    'fish': FoodCategoryVisual(
      icon: Icons.set_meal_rounded,
      background: Color(0xFFE3F2FD),
      foreground: Color(0xFF1565C0),
    ),
    'seafood': FoodCategoryVisual(
      icon: Icons.set_meal_rounded,
      background: Color(0xFFE0F7FA),
      foreground: Color(0xFF00838F),
    ),
    'egg': FoodCategoryVisual(
      icon: Icons.egg_rounded,
      background: Color(0xFFFFFDE7),
      foreground: Color(0xFFF9A825),
    ),
    'tofu': FoodCategoryVisual(
      icon: Icons.grass_rounded,
      background: Color(0xFFE8F5E9),
      foreground: Color(0xFF2E7D32),
    ),
    'dairy': FoodCategoryVisual(
      icon: Icons.water_drop_rounded,
      background: Color(0xFFE3F2FD),
      foreground: Color(0xFF1976D2),
    ),
    'cheese': FoodCategoryVisual(
      icon: Icons.breakfast_dining_rounded,
      background: Color(0xFFFFF9C4),
      foreground: Color(0xFFFBC02D),
    ),
    'yogurt': FoodCategoryVisual(
      icon: Icons.icecream_rounded,
      background: Color(0xFFF3E5F5),
      foreground: Color(0xFF7B1FA2),
    ),
    'milk': FoodCategoryVisual(
      icon: Icons.local_drink_rounded,
      background: Color(0xFFE8EAF6),
      foreground: Color(0xFF3949AB),
    ),
    'pasta': FoodCategoryVisual(
      icon: Icons.ramen_dining_rounded,
      background: Color(0xFFFFE0B2),
      foreground: Color(0xFFE65100),
    ),
    'rice': FoodCategoryVisual(
      icon: Icons.rice_bowl_rounded,
      background: Color(0xFFF1F8E9),
      foreground: Color(0xFF558B2F),
    ),
    'bread': FoodCategoryVisual(
      icon: Icons.bakery_dining_rounded,
      background: Color(0xFFEFEBE9),
      foreground: Color(0xFF5D4037),
    ),
    'pizza': FoodCategoryVisual(
      icon: Icons.local_pizza_rounded,
      background: Color(0xFFFFCCBC),
      foreground: Color(0xFFD84315),
    ),
    'grain': FoodCategoryVisual(
      icon: Icons.grain_rounded,
      background: Color(0xFFFFF8E1),
      foreground: Color(0xFFFF8F00),
    ),
    'oat': FoodCategoryVisual(
      icon: Icons.breakfast_dining_rounded,
      background: Color(0xFFD7CCC8),
      foreground: Color(0xFF4E342E),
    ),
    'fruit': FoodCategoryVisual(
      icon: Icons.apple_rounded,
      background: Color(0xFFFFCDD2),
      foreground: Color(0xFFC62828),
    ),
    'berry': FoodCategoryVisual(
      icon: Icons.local_florist_rounded,
      background: Color(0xFFF8BBD9),
      foreground: Color(0xFFC2185B),
    ),
    'vegetable': FoodCategoryVisual(
      icon: Icons.eco_rounded,
      background: Color(0xFFC8E6C9),
      foreground: Color(0xFF388E3C),
    ),
    'salad': FoodCategoryVisual(
      icon: Icons.spa_rounded,
      background: Color(0xFFDCEDC8),
      foreground: Color(0xFF689F38),
    ),
    'bean': FoodCategoryVisual(
      icon: Icons.grass_rounded,
      background: Color(0xFFDCE775),
      foreground: Color(0xFF827717),
    ),
    'nut': FoodCategoryVisual(
      icon: Icons.circle_rounded,
      background: Color(0xFFD7CCC8),
      foreground: Color(0xFF6D4C41),
    ),
    'oil': FoodCategoryVisual(
      icon: Icons.opacity_rounded,
      background: Color(0xFFFFF9C4),
      foreground: Color(0xFFF9A825),
    ),
    'snack': FoodCategoryVisual(
      icon: Icons.cookie_rounded,
      background: Color(0xFFBCAAA4),
      foreground: Color(0xFF4E342E),
    ),
    'protein_powder': FoodCategoryVisual(
      icon: Icons.fitness_center_rounded,
      background: Color(0xFFE1BEE7),
      foreground: Color(0xFF6A1B9A),
    ),
    'default': FoodCategoryVisual(
      icon: Icons.restaurant_rounded,
      background: Color(0xFFECEFF1),
      foreground: Color(0xFF546E7A),
    ),
  };

  static String categoryFor(String name, {String? sourceNote, String? imageCategory}) {
    if (imageCategory != null && imageCategory.isNotEmpty) {
      return imageCategory;
    }
    final id = sourceNote?.toLowerCase() ?? '';
    final n = name.toLowerCase();
    final blob = '$id $n';

    if (blob.contains('strawberr') ||
        blob.contains('blueberr') ||
        blob.contains('raspberr') ||
        blob.contains('blackberr')) {
      return 'berry';
    }
    if (blob.contains('chicken')) return 'chicken';
    if (blob.contains('turkey')) return 'turkey';
    if (blob.contains('pasta') ||
        blob.contains('spaghetti') ||
        blob.contains('noodle') ||
        blob.contains('macaroni') ||
        blob.contains('lasagna')) {
      return 'pasta';
    }
    if (blob.contains('pizza')) return 'pizza';
    if (blob.contains('rice') ||
        blob.contains('biryani') ||
        blob.contains('quinoa') ||
        blob.contains('couscous')) {
      return 'rice';
    }
    if (blob.contains('bread') ||
        blob.contains('bagel') ||
        blob.contains('tortilla') ||
        blob.contains('croissant') ||
        blob.contains('muffin')) {
      return 'bread';
    }
    if (blob.contains('oat')) return 'oat';
    if (blob.contains('beef') ||
        blob.contains('steak') ||
        blob.contains('sirloin') ||
        blob.contains('flank')) {
      return 'beef';
    }
    if (blob.contains('pork') ||
        blob.contains('bacon') ||
        blob.contains('sausage')) {
      return 'pork';
    }
    if (blob.contains('ham')) return 'ham';
    if (blob.contains('salmon') ||
        blob.contains('tuna') ||
        blob.contains('cod') ||
        blob.contains('fish') ||
        blob.contains('sardine')) {
      return 'fish';
    }
    if (blob.contains('shrimp') ||
        blob.contains('prawn') ||
        blob.contains('crab') ||
        blob.contains('lobster') ||
        blob.contains('seafood')) {
      return 'seafood';
    }
    if (blob.contains('egg')) return 'egg';
    if (blob.contains('tofu') ||
        blob.contains('tempeh') ||
        blob.contains('soy')) {
      return 'tofu';
    }
    if (blob.contains('yogurt') || blob.contains('yoghurt')) return 'yogurt';
    if (blob.contains('cheese') ||
        blob.contains('mozzarella') ||
        blob.contains('cheddar') ||
        blob.contains('feta') ||
        blob.contains('parmesan')) {
      return 'cheese';
    }
    if (blob.contains('cottage')) return 'dairy';
    if (blob.contains('milk')) return 'milk';
    if (blob.contains('butter') && !blob.contains('chicken')) return 'dairy';
    if (blob.contains('banana') ||
        blob.contains('apple') ||
        blob.contains('orange') ||
        blob.contains('grape') ||
        blob.contains('melon') ||
        blob.contains('mango') ||
        blob.contains('peach') ||
        blob.contains('fruit')) {
      return 'fruit';
    }
    if (blob.contains('avocado')) return 'fruit';
    if (blob.contains('lettuce') || blob.contains('salad')) return 'salad';
    if (blob.contains('broccoli') ||
        blob.contains('spinach') ||
        blob.contains('kale') ||
        blob.contains('carrot') ||
        blob.contains('pepper') ||
        blob.contains('tomato') ||
        blob.contains('onion') ||
        blob.contains('potato') ||
        blob.contains('cucumber') ||
        blob.contains('mushroom') ||
        blob.contains('zucchini') ||
        blob.contains('cauliflower') ||
        blob.contains('vegetable')) {
      return 'vegetable';
    }
    if (blob.contains('bean') ||
        blob.contains('lentil') ||
        blob.contains('chickpea') ||
        blob.contains('hummus')) {
      return 'bean';
    }
    if (blob.contains('almond') ||
        blob.contains('peanut') ||
        blob.contains('walnut') ||
        blob.contains('cashew') ||
        blob.contains('nut')) {
      return 'nut';
    }
    if (blob.contains('olive oil') || blob.contains('oil')) return 'oil';
    if (blob.contains('honey') ||
        blob.contains('chocolate') ||
        blob.contains('granola') ||
        blob.contains('cookie') ||
        blob.contains('chip')) {
      return 'snack';
    }
    if (blob.contains('protein') && blob.contains('powder')) {
      return 'protein_powder';
    }
    if (blob.contains('whey')) return 'protein_powder';
    if (blob.contains('burger')) return 'beef';
    if (blob.contains('sandwich') || blob.contains('wrap')) return 'bread';

    return 'default';
  }

  static FoodCategoryVisual visualFor(
    String name, {
    String? sourceNote,
    String? imageCategory,
  }) {
    final cat = categoryFor(
      name,
      sourceNote: sourceNote,
      imageCategory: imageCategory,
    );
    return _visuals[cat] ?? _visuals['default']!;
  }
}
