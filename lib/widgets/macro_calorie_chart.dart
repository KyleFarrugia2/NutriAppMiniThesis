import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/macro_colors.dart';

/// Kcal from each macro (Atwater: 4 / 4 / 9 per gram).
@immutable
class MacroKcalSplit {
  const MacroKcalSplit._(this.proteinKcal, this.carbsKcal, this.fatKcal);

  factory MacroKcalSplit.fromGrams({
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    final p = (4 * proteinG).clamp(0.0, 1e9);
    final c = (4 * carbsG).clamp(0.0, 1e9);
    final f = (9 * fatG).clamp(0.0, 1e9);
    return MacroKcalSplit._(p, c, f);
  }

  final double proteinKcal;
  final double carbsKcal;
  final double fatKcal;

  double get totalKcal => proteinKcal + carbsKcal + fatKcal;

  /// Fractions of total macro-derived kcal (sum ≈ 1). If total is 0, returns (0,0,0).
  (double p, double c, double f) get fractions {
    final t = totalKcal;
    if (t <= 1e-6) return (0.0, 0.0, 0.0);
    return (
      proteinKcal / t,
      carbsKcal / t,
      fatKcal / t,
    );
  }
}

/// Donut chart + stacked bar + legend for P/C/F by **% of calories from each macro**.
class MacroCalorieVisuals extends StatelessWidget {
  const MacroCalorieVisuals({
    super.key,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.size = 168,
  });

  final double proteinG;
  final double carbsG;
  final double fatG;
  final double size;

  @override
  Widget build(BuildContext context) {
    final split = MacroKcalSplit.fromGrams(
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    );
    final (pF, cF, fF) = split.fractions;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (split.totalKcal <= 1e-6) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No macro data to chart.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final pPct = (100 * pF).round();
    final cPct = (100 * cF).round();
    final fPct = (100 * fF).round();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Macro mix (% of kcal from each)',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Based on 4 kcal/g protein & carbs, 9 kcal/g fat.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _MacroDonutPainter(
                      pSweep: pF * 2 * math.pi,
                      cSweep: cF * 2 * math.pi,
                      fSweep: fF * 2 * math.pi,
                      holeColor: Theme.of(context).cardColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${split.totalKcal.round()}',
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'kcal\nfrom macros',
                            textAlign: TextAlign.center,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                        color: MacroColors.protein,
                        label: 'Protein',
                        pct: pPct,
                        grams: proteinG,
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: MacroColors.carbs,
                        label: 'Carbs',
                        pct: cPct,
                        grams: carbsG,
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: MacroColors.fat,
                        label: 'Fat',
                        pct: fPct,
                        grams: fatG,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Share of calories',
              style: tt.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _MacroStackedBar(pFrac: pF, cFrac: cF, fFrac: fF),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.pct,
    required this.grams,
  });

  final Color color;
  final String label;
  final int pct;
  final double grams;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final gStr = grams >= 10
        ? grams.round().toString()
        : grams.toStringAsFixed(1);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: '  $pct%  ($gStr g)',
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MacroStackedBar extends StatelessWidget {
  const _MacroStackedBar({
    required this.pFrac,
    required this.cFrac,
    required this.fFrac,
  });

  final double pFrac;
  final double cFrac;
  final double fFrac;

  @override
  Widget build(BuildContext context) {
    const h = 14.0;
    final t = pFrac + cFrac + fFrac;
    if (t <= 1e-9) {
      return SizedBox(
        height: h,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
    }
    int flex(double f) => math.max(1, (f / t * 2000).round());

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: h,
        child: Row(
          children: [
            if (pFrac > 1e-6)
              Expanded(
                flex: flex(pFrac),
                child: const ColoredBox(color: MacroColors.protein),
              ),
            if (cFrac > 1e-6)
              Expanded(
                flex: flex(cFrac),
                child: const ColoredBox(color: MacroColors.carbs),
              ),
            if (fFrac > 1e-6)
              Expanded(
                flex: flex(fFrac),
                child: const ColoredBox(color: MacroColors.fat),
              ),
          ],
        ),
      ),
    );
  }
}

class _MacroDonutPainter extends CustomPainter {
  _MacroDonutPainter({
    required this.pSweep,
    required this.cSweep,
    required this.fSweep,
    required this.holeColor,
  });

  final double pSweep;
  final double cSweep;
  final double fSweep;
  final Color holeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final outer = math.min(size.width, size.height) / 2 * 0.88;
    final stroke = outer * 0.38;
    final arcRadius = outer - stroke / 2;
    final rect = Rect.fromCircle(center: c, radius: arcRadius);

    var start = -math.pi / 2;

    void drawSweep(double sweep, Color color) {
      if (sweep <= 1e-6) return;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }

    drawSweep(pSweep, MacroColors.protein);
    drawSweep(cSweep, MacroColors.carbs);
    drawSweep(fSweep, MacroColors.fat);

    final innerR = (outer - stroke * 1.05).clamp(0.0, outer);
    canvas.drawCircle(c, innerR, Paint()..color = holeColor);
  }

  @override
  bool shouldRepaint(covariant _MacroDonutPainter oldDelegate) {
    return oldDelegate.pSweep != pSweep ||
        oldDelegate.cSweep != cSweep ||
        oldDelegate.fSweep != fSweep ||
        oldDelegate.holeColor != holeColor;
  }
}
