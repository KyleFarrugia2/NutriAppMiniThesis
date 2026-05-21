import 'package:flutter/material.dart';

import '../services/level_icons.dart';
import '../services/progression_service.dart';

/// Minimal always-on level indicator (tooltip shows rank + XP).
class LevelHudChip extends StatelessWidget {
  const LevelHudChip({super.key, required this.snapshot});

  final ProgressionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final level = snapshot.level;
    final accent = LevelIcons.colorForLevel(level, cs);
    final emblem = LevelIcons.iconForLevel(level);
    final emblemSize = LevelIcons.iconSizeForLevel(level);

    return Tooltip(
      message:
          '${snapshot.rankTitle}\n${snapshot.xpIntoLevel} / ${snapshot.xpForCurrentLevelSpan} XP · ${snapshot.totalXp} total',
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minWidth: 68, maxWidth: 76),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.82),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(emblem, size: emblemSize, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lv.$level',
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        height: 1.0,
                        letterSpacing: -0.2,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: snapshot.progressFraction,
                        minHeight: 3,
                        backgroundColor: cs.surfaceContainerHighest,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
