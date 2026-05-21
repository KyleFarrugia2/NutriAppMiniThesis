import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Distinct [IconData] for every level: large fixed pool + coprime step so nearby
/// levels never share the same icon until the pool has been exhausted once.
abstract final class LevelIcons {
  static const int _primeStep = 73;

  /// 128 icons; gcd(73, 128) = 1 ⇒ multiplying by 73 permutes all indices mod 128.
  /// Adding [level ~/ 128] shifts the mapping each time you pass another full pool,
  /// so very high levels keep changing emblem instead of repeating every 128 levels.
  static const List<IconData> _pool = <IconData>[
    Icons.eco_outlined,
    Icons.spa_outlined,
    Icons.water_drop_outlined,
    Icons.local_florist_outlined,
    Icons.grass_outlined,
    Icons.park_outlined,
    Icons.pets_outlined,
    Icons.egg_outlined,
    Icons.restaurant_menu_outlined,
    Icons.ramen_dining_outlined,
    Icons.breakfast_dining_outlined,
    Icons.lunch_dining_outlined,
    Icons.dinner_dining_outlined,
    Icons.local_cafe_outlined,
    Icons.local_bar_outlined,
    Icons.cake_outlined,
    Icons.icecream_outlined,
    Icons.emoji_food_beverage_outlined,
    Icons.volunteer_activism_outlined,
    Icons.favorite_outline,
    Icons.healing_outlined,
    Icons.health_and_safety_outlined,
    Icons.monitor_heart_outlined,
    Icons.self_improvement_outlined,
    Icons.accessibility_new_outlined,
    Icons.directions_walk_outlined,
    Icons.directions_run_outlined,
    Icons.directions_bike_outlined,
    Icons.hiking_outlined,
    Icons.pool_outlined,
    Icons.surfing_outlined,
    Icons.skateboarding_outlined,
    Icons.kayaking_outlined,
    Icons.paragliding_outlined,
    Icons.rowing_outlined,
    Icons.snowboarding_outlined,
    Icons.ice_skating_outlined,
    Icons.sledding_outlined,
    Icons.nordic_walking_outlined,
    Icons.pedal_bike_outlined,
    Icons.two_wheeler_outlined,
    Icons.fitness_center_outlined,
    Icons.sports_gymnastics_outlined,
    Icons.sports_handball_outlined,
    Icons.sports_martial_arts_outlined,
    Icons.sports_mma_outlined,
    Icons.sports_kabaddi_outlined,
    Icons.sports_tennis_outlined,
    Icons.sports_soccer_outlined,
    Icons.sports_basketball_outlined,
    Icons.sports_volleyball_outlined,
    Icons.sports_football_outlined,
    Icons.sports_baseball_outlined,
    Icons.sports_cricket_outlined,
    Icons.sports_esports_outlined,
    Icons.sports_score_outlined,
    Icons.emoji_events_outlined,
    Icons.workspace_premium_outlined,
    Icons.military_tech_outlined,
    Icons.shield_outlined,
    Icons.verified_user_outlined,
    Icons.security_outlined,
    Icons.bolt_outlined,
    Icons.flash_on_outlined,
    Icons.local_fire_department_outlined,
    Icons.whatshot_outlined,
    Icons.trending_up_outlined,
    Icons.show_chart_outlined,
    Icons.insights_outlined,
    Icons.speed_outlined,
    Icons.timer_outlined,
    Icons.schedule_outlined,
    Icons.event_outlined,
    Icons.today_outlined,
    Icons.calendar_today_outlined,
    Icons.alarm_outlined,
    Icons.notifications_outlined,
    Icons.star_border_outlined,
    Icons.star_outline_outlined,
    Icons.star_half_outlined,
    Icons.star_outlined,
    Icons.stars_outlined,
    Icons.grade_outlined,
    Icons.emoji_objects_outlined,
    Icons.lightbulb_outline,
    Icons.psychology_outlined,
    Icons.school_outlined,
    Icons.menu_book_outlined,
    Icons.science_outlined,
    Icons.biotech_outlined,
    Icons.explore_outlined,
    Icons.map_outlined,
    Icons.public_outlined,
    Icons.rocket_launch_outlined,
    Icons.flight_outlined,
    Icons.airplanemode_active_outlined,
    Icons.train_outlined,
    Icons.directions_boat_outlined,
    Icons.local_taxi_outlined,
    Icons.music_note_outlined,
    Icons.palette_outlined,
    Icons.brush_outlined,
    Icons.camera_outlined,
    Icons.videocam_outlined,
    Icons.mic_outlined,
    Icons.headphones_outlined,
    Icons.cast_outlined,
    Icons.wifi_outlined,
    Icons.bluetooth_outlined,
    Icons.key_outlined,
    Icons.lock_open_outlined,
    Icons.diamond_outlined,
    Icons.auto_awesome_outlined,
    Icons.auto_fix_high_outlined,
    Icons.celebration_outlined,
    Icons.card_giftcard_outlined,
    Icons.redeem_outlined,
    Icons.emoji_nature_outlined,
    Icons.emoji_people_outlined,
    Icons.emoji_symbols_outlined,
    Icons.emoji_transportation_outlined,
    Icons.recycling_outlined,
    Icons.energy_savings_leaf_outlined,
    Icons.wb_sunny_outlined,
    Icons.nightlight_outlined,
    Icons.cloud_outlined,
    Icons.thunderstorm_outlined,
    Icons.ac_unit_outlined,
  ];

  static IconData iconForLevel(int level) {
    final L = level < 1 ? 1 : level;
    final band = L ~/ _pool.length;
    final idx = ((L - 1) * _primeStep + band) % _pool.length;
    return _pool[idx];
  }

  /// Saturated accent that still reads on dark HUD chips.
  static Color colorForLevel(int level, ColorScheme cs) {
    final L = level < 1 ? 1 : level;
    final hue = ((L * 47 + L ~/ 3) % 360).toDouble();
    final orbit = HSLColor.fromAHSL(1, hue, 0.62, 0.58).toColor();
    return Color.lerp(cs.primary, orbit, 0.42)!;
  }

  /// Icon scale for HUD (14–16 logical px).
  static double iconSizeForLevel(int level) {
    final L = level < 1 ? 1 : level;
    return lerpDouble(14, 16, ((L - 1) % 7) / 6)!;
  }
}
