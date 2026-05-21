import 'package:flutter/material.dart';

import '../services/food_image_resolver.dart';

/// Circular food image for search rows, portion screen, and meal log.
class FoodThumbnail extends StatelessWidget {
  const FoodThumbnail({
    super.key,
    required this.name,
    this.sourceNote,
    this.imageCategory,
    this.size = 48,
  });

  final String name;
  final String? sourceNote;
  final String? imageCategory;
  final double size;

  factory FoodThumbnail.fromMeal({
    required String mealName,
    String? imageNote,
    double size = 40,
  }) {
    final baseName = mealName.replaceAll(RegExp(r'\s*\(\d+\s*g\)\s*$'), '');
    return FoodThumbnail(
      name: baseName,
      sourceNote: imageNote,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = FoodImageResolver.photoUrlFor(
      name,
      sourceNote: sourceNote,
      imageCategory: imageCategory,
    );
    final emoji = FoodImageResolver.emojiFor(
      name,
      sourceNote: sourceNote,
      imageCategory: imageCategory,
    );
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _EmojiTile(emoji: emoji, size: size, cs: cs);
          },
          errorBuilder: (_, __, ___) => _EmojiTile(emoji: emoji, size: size, cs: cs),
        ),
      ),
    );
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({
    required this.emoji,
    required this.size,
    required this.cs,
  });

  final String emoji;
  final double size;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.48),
        ),
      ),
    );
  }
}
