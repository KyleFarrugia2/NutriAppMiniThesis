import 'dart:math';

import 'package:flutter/foundation.dart';

/// XP curve and rank titles. Level-ups are intentionally slow at higher levels.
@immutable
class ProgressionSnapshot {
  const ProgressionSnapshot({
    required this.totalXp,
    required this.level,
    required this.rankTitle,
    required this.xpIntoLevel,
    required this.xpForCurrentLevelSpan,
    required this.progressFraction,
  });

  final int totalXp;
  final int level;
  final String rankTitle;
  final int xpIntoLevel;
  final int xpForCurrentLevelSpan;
  /// 0–1 toward next level (1.0 when at band max before level-up edge).
  final double progressFraction;
}

/// Awards and formulas for player level (separate from nutrition “activity level”).
abstract final class ProgressionService {
  /// First meal logged on a calendar day (one grant per day, ever, for that date key).
  static const int mealDayXp = 22;

  /// First workout XP grant on a calendar day (any source).
  static const int workoutFirstDailyXp = 52;

  /// Second workout XP grant same calendar day (diminishing returns).
  static const int workoutSecondDailyXp = 16;

  /// Extra XP when the first workout of the day is a completed weekly-program session.
  static const int programSessionFirstDailyBonus = 30;

  static const int maxTrackedLevel = 5000;

  static List<int>? _xpAtStartOfLevel;

  static void _ensureCache() {
    if (_xpAtStartOfLevel != null) return;
    final starts = <int>[0];
    var sum = 0;
    for (var L = 1; L < maxTrackedLevel; L++) {
      sum += xpDelta(L);
      starts.add(sum);
    }
    _xpAtStartOfLevel = starts;
  }

  /// XP required to go from level [level] → [level] + 1.
  static int xpDelta(int level) {
    final i = level.toDouble();
    // Rising curve: gentle early grind, very long tail toward 800–1000+.
    final raw = 12.0 +
        5.75 * pow(i, 1.14) +
        0.0215 * i * i +
        0.000048 * i * i * i;
    return max(6, min(320000, raw.round()));
  }

  /// Minimum total XP to **be** this level (level 1 starts at 0).
  static int totalXpAtStartOfLevel(int level) {
    _ensureCache();
    final starts = _xpAtStartOfLevel!;
    if (level <= 1) return 0;
    if (level - 1 >= starts.length) return starts.last;
    return starts[level - 1];
  }

  static int levelFromTotalXp(int totalXp) {
    _ensureCache();
    final starts = _xpAtStartOfLevel!;
    final xp = max(0, totalXp);
    if (xp >= starts.last) return starts.length;
    var lo = 0;
    var hi = starts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (starts[mid] <= xp) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo + 1;
  }

  static String rankTitleForLevel(int level) {
    final l = max(1, level);
    if (l >= 1000) return 'Mr Olympia';
    if (l >= 900) return 'Top 5 Olympian';
    if (l >= 800) return 'Top 10 Olympian';
    if (l >= 600) return 'IFBB Pro';
    if (l >= 500) return 'Advanced Bodybuilder';
    if (l >= 400) return 'Sith Lord';
    if (l >= 300) return 'Sith Apprentice';
    if (l >= 200) return 'Jedi Master';
    if (l >= 150) return 'Jedi Knight';
    if (l >= 100) return 'Veteran';
    if (l >= 50) return 'Intermediate';
    return 'Beginner';
  }

  static ProgressionSnapshot snapshot(int totalXp) {
    final xp = max(0, totalXp);
    final level = levelFromTotalXp(xp);
    final start = totalXpAtStartOfLevel(level);
    final span = level >= maxTrackedLevel
        ? max(1, xpDelta(maxTrackedLevel - 1))
        : max(1, totalXpAtStartOfLevel(level + 1) - start);
    final into = (xp - start).clamp(0, span);
    final frac = into / span;
    return ProgressionSnapshot(
      totalXp: xp,
      level: level,
      rankTitle: rankTitleForLevel(level),
      xpIntoLevel: into,
      xpForCurrentLevelSpan: span,
      progressFraction: frac.isNaN ? 0.0 : frac.clamp(0.0, 1.0),
    );
  }
}