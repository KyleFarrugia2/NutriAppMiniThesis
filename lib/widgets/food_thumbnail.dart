import 'package:flutter/material.dart';

import '../services/food_image_resolver.dart';

/// Minimal cartoon food tile (pastel box + per-item emoji or icon).
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
    String? imageCategory,
    double size = 40,
  }) {
    final baseName = mealName.replaceAll(RegExp(r'\s*\(\d+\s*g\)\s*$'), '');
    return FoodThumbnail(
      name: baseName,
      sourceNote: imageNote,
      imageCategory: imageCategory,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = FoodImageResolver.visualFor(
      name,
      sourceNote: sourceNote,
      imageCategory: imageCategory,
    );
    final radius = size * 0.24;
    final emojiSize = size * 0.58;
    final iconSize = size * 0.44;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: v.background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: v.foreground.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: v.usesEmoji
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(size * 0.06),
                  child: Text(
                    v.emoji!,
                    style: TextStyle(fontSize: emojiSize, height: 1),
                  ),
                ),
              )
            : Icon(
                v.icon ?? Icons.restaurant_rounded,
                size: iconSize,
                color: v.foreground,
              ),
      ),
    );
  }
}
