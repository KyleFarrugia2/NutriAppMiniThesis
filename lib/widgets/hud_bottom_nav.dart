import 'package:flutter/material.dart';

/// Bottom dock with “ability slot” style icons — chunky tiles, glow, and accent gradients.
class HudBottomNav extends StatelessWidget {
  const HudBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _items = <_HudItem>[
    _HudItem(
      label: 'Home',
      icon: Icons.rocket_launch_rounded,
      gradient: [Color(0xFF22D3EE), Color(0xFF06B6D4)],
    ),
    _HudItem(
      label: 'Nutrition',
      icon: Icons.local_fire_department_rounded,
      gradient: [Color(0xFFFF8A65), Color(0xFFFFB74D)],
    ),
    _HudItem(
      label: 'Workouts',
      icon: Icons.bolt_rounded,
      gradient: [Color(0xFFA78BFA), Color(0xFFEC4899)],
    ),
    _HudItem(
      label: 'Profile',
      icon: Icons.emoji_events_rounded,
      gradient: [Color(0xFFFFD54F), Color(0xFFFFB300)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      elevation: 16,
      shadowColor: cs.primary.withOpacity(0.35),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.surfaceContainerLowest.withOpacity(0.94),
              cs.surface,
            ],
          ),
          border: Border(
            top: BorderSide(color: cs.primary.withOpacity(0.22), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _HudSlot(
                    item: _items[i],
                    selected: i == currentIndex,
                    onTap: () => onSelect(i),
                    labelStyle: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudItem {
  const _HudItem({
    required this.label,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
}

class _HudSlot extends StatelessWidget {
  const _HudSlot({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.labelStyle,
  });

  final _HudItem item;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inactive = cs.onSurfaceVariant.withOpacity(0.75);
    final labelColor = selected ? item.gradient.first : inactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: item.gradient.first.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: item.gradient,
                      )
                    : null,
                color: selected ? null : cs.surfaceContainerHigh,
                border: Border.all(
                  width: selected ? 2 : 1.2,
                  color: selected
                      ? item.gradient.first.withOpacity(0.95)
                      : cs.outline.withOpacity(0.45),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: item.gradient.first.withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Icon(
                item.icon,
                size: 28,
                color: selected ? Colors.white : inactive,
                shadows: selected
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle?.copyWith(
                color: labelColor,
                fontSize: (labelStyle?.fontSize ?? 11) * (selected ? 1.02 : 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
