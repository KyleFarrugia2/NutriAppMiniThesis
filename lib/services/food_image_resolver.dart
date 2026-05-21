import 'package:flutter/material.dart';

/// Minimal cartoon tile: pastel background + emoji and/or icon.
class FoodCategoryVisual {
  const FoodCategoryVisual({
    this.icon,
    this.emoji,
    required this.background,
    this.foreground = const Color(0xFF455A64),
  });

  final IconData? icon;
  final String? emoji;
  final Color background;
  final Color foreground;

  bool get usesEmoji => emoji != null && emoji!.isNotEmpty;
}

class FoodImageResolver {
  FoodImageResolver._();

  static const _visuals = <String, FoodCategoryVisual>{
    // —— Fruits (emoji = distinct cartoon per item) ——
    'apple': FoodCategoryVisual(
      emoji: '🍎',
      background: Color(0xFFFFEBEE),
    ),
    'banana': FoodCategoryVisual(
      emoji: '🍌',
      background: Color(0xFFFFF9C4),
    ),
    'orange': FoodCategoryVisual(
      emoji: '🍊',
      background: Color(0xFFFFE0B2),
    ),
    'blueberry': FoodCategoryVisual(
      emoji: '🫐',
      background: Color(0xFFE8EAF6),
    ),
    'strawberry': FoodCategoryVisual(
      emoji: '🍓',
      background: Color(0xFFFCE4EC),
    ),
    'grape': FoodCategoryVisual(
      emoji: '🍇',
      background: Color(0xFFF3E5F5),
    ),
    'watermelon': FoodCategoryVisual(
      emoji: '🍉',
      background: Color(0xFFE8F5E9),
    ),
    'avocado': FoodCategoryVisual(
      emoji: '🥑',
      background: Color(0xFFE8F5E9),
    ),
    'mango': FoodCategoryVisual(
      emoji: '🥭',
      background: Color(0xFFFFF3E0),
    ),
    'peach': FoodCategoryVisual(
      emoji: '🍑',
      background: Color(0xFFFFE0B2),
    ),
    'lemon': FoodCategoryVisual(
      emoji: '🍋',
      background: Color(0xFFFFFDE7),
    ),
    'cherry': FoodCategoryVisual(
      emoji: '🍒',
      background: Color(0xFFFFCDD2),
    ),
    'pineapple': FoodCategoryVisual(
      emoji: '🍍',
      background: Color(0xFFFFF8E1),
    ),
    'fruit': FoodCategoryVisual(
      emoji: '🍏',
      background: Color(0xFFC8E6C9),
    ),

    // —— Vegetables ——
    'tomato': FoodCategoryVisual(
      emoji: '🍅',
      background: Color(0xFFFFEBEE),
    ),
    'carrot': FoodCategoryVisual(
      emoji: '🥕',
      background: Color(0xFFFFE0B2),
    ),
    'broccoli': FoodCategoryVisual(
      emoji: '🥦',
      background: Color(0xFFE8F5E9),
    ),
    'pepper_veg': FoodCategoryVisual(
      emoji: '🫑',
      background: Color(0xFFE8F5E9),
    ),
    'potato': FoodCategoryVisual(
      emoji: '🥔',
      background: Color(0xFFEFEBE9),
    ),
    'lettuce': FoodCategoryVisual(
      emoji: '🥬',
      background: Color(0xFFDCEDC8),
    ),
    'mushroom': FoodCategoryVisual(
      emoji: '🍄',
      background: Color(0xFFD7CCC8),
    ),
    'vegetable': FoodCategoryVisual(
      emoji: '🥗',
      background: Color(0xFFC8E6C9),
    ),
    'salad': FoodCategoryVisual(
      emoji: '🥗',
      background: Color(0xFFDCEDC8),
    ),

    // —— Protein & meat ——
    'chicken': FoodCategoryVisual(
      emoji: '🍗',
      background: Color(0xFFFFF3E0),
    ),
    'turkey': FoodCategoryVisual(
      emoji: '🦃',
      background: Color(0xFFFFECB3),
    ),
    'beef': FoodCategoryVisual(
      emoji: '🥩',
      background: Color(0xFFFFEBEE),
    ),
    'pork': FoodCategoryVisual(
      emoji: '🥓',
      background: Color(0xFFFCE4EC),
    ),
    'ham': FoodCategoryVisual(
      emoji: '🍖',
      background: Color(0xFFFFE0B2),
    ),
    'fish': FoodCategoryVisual(
      emoji: '🐟',
      background: Color(0xFFE3F2FD),
    ),
    'seafood': FoodCategoryVisual(
      emoji: '🦐',
      background: Color(0xFFE0F7FA),
    ),
    'egg': FoodCategoryVisual(
      emoji: '🥚',
      background: Color(0xFFFFFDE7),
    ),
    'tofu': FoodCategoryVisual(
      emoji: '🫘',
      background: Color(0xFFE8F5E9),
    ),

    // —— Dairy ——
    'dairy': FoodCategoryVisual(
      emoji: '🥛',
      background: Color(0xFFE3F2FD),
    ),
    'cheese': FoodCategoryVisual(
      emoji: '🧀',
      background: Color(0xFFFFF9C4),
    ),
    'yogurt': FoodCategoryVisual(
      emoji: '🥣',
      background: Color(0xFFF3E5F5),
    ),
    'milk': FoodCategoryVisual(
      emoji: '🥛',
      background: Color(0xFFE8EAF6),
    ),

    // —— Grains & carbs ——
    'pasta': FoodCategoryVisual(
      emoji: '🍝',
      background: Color(0xFFFFE0B2),
    ),
    'rice': FoodCategoryVisual(
      emoji: '🍚',
      background: Color(0xFFF1F8E9),
    ),
    'bread': FoodCategoryVisual(
      emoji: '🍞',
      background: Color(0xFFEFEBE9),
    ),
    'pizza': FoodCategoryVisual(
      emoji: '🍕',
      background: Color(0xFFFFCCBC),
    ),
    'oat': FoodCategoryVisual(
      emoji: '🥣',
      background: Color(0xFFD7CCC8),
    ),
    'grain': FoodCategoryVisual(
      emoji: '🌾',
      background: Color(0xFFFFF8E1),
    ),

    // —— Other ——
    'bean': FoodCategoryVisual(
      emoji: '🫘',
      background: Color(0xFFDCE775),
    ),
    'nut': FoodCategoryVisual(
      emoji: '🥜',
      background: Color(0xFFD7CCC8),
    ),
    'oil': FoodCategoryVisual(
      emoji: '🫒',
      background: Color(0xFFFFF9C4),
    ),
    'snack': FoodCategoryVisual(
      emoji: '🍫',
      background: Color(0xFFBCAAA4),
    ),
    'protein_powder': FoodCategoryVisual(
      emoji: '💪',
      icon: Icons.fitness_center_rounded,
      background: Color(0xFFE1BEE7),
    ),
    'honey': FoodCategoryVisual(
      emoji: '🍯',
      background: Color(0xFFFFF8E1),
    ),
    'default': FoodCategoryVisual(
      emoji: '🍽️',
      background: Color(0xFFECEFF1),
    ),
  };

  static String categoryFor(String name, {String? sourceNote, String? imageCategory}) {
    if (imageCategory != null && imageCategory.isNotEmpty) {
      return imageCategory;
    }
    final n = name.toLowerCase();
    final id = sourceNote?.toLowerCase() ?? '';
    final blob = '$n $id';

    // Fruits — specific before generic
    if (blob.contains('strawberr')) return 'strawberry';
    if (blob.contains('blueberr')) return 'blueberry';
    if (blob.contains('raspberr') || blob.contains('blackberr')) {
      return 'strawberry';
    }
    if (blob.contains('banana')) return 'banana';
    if (blob.contains('apple') && !blob.contains('pineapple')) return 'apple';
    if (blob.contains('orange') && !blob.contains('pepper')) return 'orange';
    if (blob.contains('grape')) return 'grape';
    if (blob.contains('watermelon')) return 'watermelon';
    if (blob.contains('avocado')) return 'avocado';
    if (blob.contains('mango')) return 'mango';
    if (blob.contains('peach')) return 'peach';
    if (blob.contains('lemon') || blob.contains('lime')) return 'lemon';
    if (blob.contains('cherry')) return 'cherry';
    if (blob.contains('pineapple')) return 'pineapple';

    // Protein powder before generic protein
    if (blob.contains('protein') && blob.contains('powder')) {
      return 'protein_powder';
    }
    if (blob.contains('whey')) return 'protein_powder';

    if (blob.contains('chicken')) return 'chicken';
    if (blob.contains('turkey')) return 'turkey';
    if (blob.contains('salmon') ||
        blob.contains('tuna') ||
        blob.contains('cod') ||
        blob.contains('sardine')) {
      return 'fish';
    }
    if (blob.contains('shrimp') ||
        blob.contains('prawn') ||
        blob.contains('crab') ||
        blob.contains('lobster')) {
      return 'seafood';
    }
    if (blob.contains('fish')) return 'fish';
    if (blob.contains('beef') ||
        blob.contains('steak') ||
        blob.contains('sirloin') ||
        blob.contains('flank') ||
        blob.contains('burger')) {
      return 'beef';
    }
    if (blob.contains('pork') ||
        blob.contains('bacon') ||
        blob.contains('sausage')) {
      return 'pork';
    }
    if (blob.contains('ham')) return 'ham';
    if (blob.contains('egg')) return 'egg';
    if (blob.contains('tofu') || blob.contains('tempeh')) return 'tofu';

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
        blob.contains('muffin') ||
        blob.contains('sandwich') ||
        blob.contains('wrap')) {
      return 'bread';
    }
    if (blob.contains('oat') || blob.contains('oatmeal')) return 'oat';

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

    // Vegetables — specific
    if (blob.contains('tomato')) return 'tomato';
    if (blob.contains('carrot')) return 'carrot';
    if (blob.contains('broccoli')) return 'broccoli';
    if (blob.contains('mushroom')) return 'mushroom';
    if (blob.contains('potato') || blob.contains('sweet potato')) {
      return 'potato';
    }
    if (blob.contains('lettuce') || blob.contains('romaine')) return 'lettuce';
    if (blob.contains('spinach') || blob.contains('kale')) return 'lettuce';
    if (blob.contains('pepper') && blob.contains('bell')) return 'pepper_veg';
    if (blob.contains('green bell') ||
        blob.contains('red bell') ||
        blob.contains('sweet pepper')) {
      return 'pepper_veg';
    }
    if (blob.contains('cucumber') ||
        blob.contains('zucchini') ||
        blob.contains('cauliflower') ||
        blob.contains('onion') ||
        blob.contains('vegetable')) {
      return 'vegetable';
    }
    if (blob.contains('salad')) return 'salad';

    if (blob.contains('bean') ||
        blob.contains('lentil') ||
        blob.contains('chickpea') ||
        blob.contains('hummus')) {
      return 'bean';
    }
    if (blob.contains('almond') ||
        blob.contains('peanut') ||
        blob.contains('walnut') ||
        blob.contains('cashew')) {
      return 'nut';
    }
    if (blob.contains('honey')) return 'honey';
    if (blob.contains('chocolate') ||
        blob.contains('granola') ||
        blob.contains('cookie')) {
      return 'snack';
    }
    if (blob.contains('olive oil') ||
        (blob.contains('oil') && !blob.contains('broil'))) {
      return 'oil';
    }

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
