/// Maps food names to a visual category (network photo + emoji fallback).
class FoodImageResolver {
  FoodImageResolver._();

  /// Stable Foodish API sample images (category / file fixed for consistent UI).
  static const _photo = <String, String>{
    'chicken': 'https://foodish-api.com/images/butter-chicken/butter-chicken1.jpg',
    'turkey': 'https://foodish-api.com/images/butter-chicken/butter-chicken2.jpg',
    'beef': 'https://foodish-api.com/images/burger/burger1.jpg',
    'pork': 'https://foodish-api.com/images/burger/burger2.jpg',
    'ham': 'https://foodish-api.com/images/burger/burger3.jpg',
    'fish': 'https://foodish-api.com/images/biryani/biryani1.jpg',
    'seafood': 'https://foodish-api.com/images/biryani/biryani2.jpg',
    'egg': 'https://foodish-api.com/images/idly/idly1.jpg',
    'tofu': 'https://foodish-api.com/images/samosa/samosa1.jpg',
    'dairy': 'https://foodish-api.com/images/dessert/dessert1.jpg',
    'cheese': 'https://foodish-api.com/images/dessert/dessert2.jpg',
    'yogurt': 'https://foodish-api.com/images/dessert/dessert3.jpg',
    'milk': 'https://foodish-api.com/images/dessert/dessert4.jpg',
    'pasta': 'https://foodish-api.com/images/pasta/pasta1.jpg',
    'rice': 'https://foodish-api.com/images/biryani/biryani3.jpg',
    'bread': 'https://foodish-api.com/images/pizza/pizza1.jpg',
    'pizza': 'https://foodish-api.com/images/pizza/pizza2.jpg',
    'grain': 'https://foodish-api.com/images/biryani/biryani4.jpg',
    'oat': 'https://foodish-api.com/images/idly/idly2.jpg',
    'fruit': 'https://foodish-api.com/images/dessert/dessert5.jpg',
    'vegetable': 'https://foodish-api.com/images/samosa/samosa2.jpg',
    'salad': 'https://foodish-api.com/images/samosa/samosa3.jpg',
    'bean': 'https://foodish-api.com/images/rajma/rajma1.jpg',
    'nut': 'https://foodish-api.com/images/dessert/dessert6.jpg',
    'oil': 'https://foodish-api.com/images/samosa/samosa4.jpg',
    'snack': 'https://foodish-api.com/images/samosa/samosa5.jpg',
    'protein_powder': 'https://foodish-api.com/images/burger/burger4.jpg',
    'default': 'https://foodish-api.com/images/pizza/pizza3.jpg',
  };

  static const _emoji = <String, String>{
    'chicken': '🍗',
    'turkey': '🦃',
    'beef': '🥩',
    'pork': '🥓',
    'ham': '🍖',
    'fish': '🐟',
    'seafood': '🦐',
    'egg': '🥚',
    'tofu': '🫘',
    'dairy': '🥛',
    'cheese': '🧀',
    'yogurt': '🥣',
    'milk': '🥛',
    'pasta': '🍝',
    'rice': '🍚',
    'bread': '🍞',
    'pizza': '🍕',
    'grain': '🌾',
    'oat': '🥣',
    'fruit': '🍎',
    'vegetable': '🥦',
    'salad': '🥗',
    'bean': '🫘',
    'nut': '🥜',
    'oil': '🫒',
    'snack': '🍫',
    'protein_powder': '💪',
    'default': '🍽️',
  };

  static String categoryFor(String name, {String? sourceNote, String? imageCategory}) {
    if (imageCategory != null && imageCategory.isNotEmpty) {
      return imageCategory;
    }
    final id = sourceNote?.toLowerCase() ?? '';
    final n = name.toLowerCase();
    final blob = '$id $n';

    if (blob.contains('chicken') || blob.contains('turkey')) {
      return blob.contains('turkey') ? 'turkey' : 'chicken';
    }
    if (blob.contains('pasta') ||
        blob.contains('spaghetti') ||
        blob.contains('noodle') ||
        blob.contains('macaroni') ||
        blob.contains('lasagna')) {
      return 'pasta';
    }
    if (blob.contains('pizza')) return 'pizza';
    if (blob.contains('rice') || blob.contains('biryani') || blob.contains('quinoa') ||
        blob.contains('couscous')) {
      return 'rice';
    }
    if (blob.contains('bread') || blob.contains('bagel') || blob.contains('tortilla') ||
        blob.contains('croissant') || blob.contains('muffin')) {
      return 'bread';
    }
    if (blob.contains('oat')) return 'oat';
    if (blob.contains('beef') || blob.contains('steak') || blob.contains('sirloin') ||
        blob.contains('flank')) {
      return 'beef';
    }
    if (blob.contains('pork') || blob.contains('bacon') || blob.contains('sausage')) {
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
    if (blob.contains('tofu') || blob.contains('tempeh') || blob.contains('soy')) {
      return 'tofu';
    }
    if (blob.contains('yogurt') || blob.contains('yoghurt')) return 'yogurt';
    if (blob.contains('cheese') || blob.contains('mozzarella') || blob.contains('cheddar') ||
        blob.contains('feta') || blob.contains('parmesan')) {
      return 'cheese';
    }
    if (blob.contains('milk') || blob.contains('cream') || blob.contains('butter')) {
      return blob.contains('butter') && !blob.contains('chicken') ? 'dairy' : 'milk';
    }
    if (blob.contains('cottage')) return 'dairy';
    if (blob.contains('banana') ||
        blob.contains('apple') ||
        blob.contains('orange') ||
        blob.contains('berry') ||
        blob.contains('grape') ||
        blob.contains('melon') ||
        blob.contains('mango') ||
        blob.contains('peach') ||
        blob.contains('fruit')) {
      return 'fruit';
    }
    if (blob.contains('avocado')) return 'fruit';
    if (blob.contains('broccoli') ||
        blob.contains('spinach') ||
        blob.contains('lettuce') ||
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
        blob.contains('vegetable') ||
        blob.contains('salad')) {
      return blob.contains('lettuce') || blob.contains('salad') ? 'salad' : 'vegetable';
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
    if (blob.contains('honey') || blob.contains('chocolate') || blob.contains('granola') ||
        blob.contains('cookie') || blob.contains('chip')) {
      return 'snack';
    }
    if (blob.contains('protein') && blob.contains('powder')) return 'protein_powder';
    if (blob.contains('burger')) return 'beef';
    if (blob.contains('sandwich') || blob.contains('wrap')) return 'bread';

    return 'default';
  }

  static String? photoUrlFor(String name, {String? sourceNote, String? imageCategory}) {
    final cat = categoryFor(name, sourceNote: sourceNote, imageCategory: imageCategory);
    return _photo[cat] ?? _photo['default'];
  }

  static String emojiFor(String name, {String? sourceNote, String? imageCategory}) {
    final cat = categoryFor(name, sourceNote: sourceNote, imageCategory: imageCategory);
    return _emoji[cat] ?? _emoji['default']!;
  }
}
