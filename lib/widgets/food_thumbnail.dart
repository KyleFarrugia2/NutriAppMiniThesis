import 'package:flutter/material.dart';

import '../services/food_image_resolver.dart';

/// Minimal cartoon-style food tile (category icon, no photos).
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
    final v = FoodImageResolver.visualFor(
      name,
      sourceNote: sourceNote,
      imageCategory: imageCategory,
    );
    final radius = size * 0.24;
    final iconSize = size * 0.48;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: v.background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: v.foreground.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: v.foreground.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        v.icon,
        size: iconSize,
        color: v.foreground,
      ),
    );
  }
}
