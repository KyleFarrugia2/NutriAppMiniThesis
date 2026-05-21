import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark “premium HUD” theme: deep space surfaces, neon accents, crisp type.
class AppTheme {
  static ThemeData dark() {
    const cyan = Color(0xFF2EE6D6);
    const violet = Color(0xFFC084FC);
    const amber = Color(0xFFFFD54F);

    const bg = Color(0xFF050810);
    const surface = Color(0xFF0F1624);
    const surfaceHigh = Color(0xFF151D2E);

    var scheme = ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: Brightness.dark,
    );

    scheme = scheme.copyWith(
      primary: cyan,
      onPrimary: const Color(0xFF031A18),
      primaryContainer: const Color(0xFF004D47),
      onPrimaryContainer: const Color(0xFFB8FFF7),
      secondary: violet,
      onSecondary: const Color(0xFF1A0B2E),
      secondaryContainer: const Color(0xFF3D2A5C),
      onSecondaryContainer: const Color(0xFFEAD4FF),
      tertiary: amber,
      onTertiary: const Color(0xFF2B2100),
      tertiaryContainer: const Color(0xFF5C4A00),
      onTertiaryContainer: const Color(0xFFFFEEB5),
      surface: surface,
      onSurface: const Color(0xFFE8EDF7),
      onSurfaceVariant: const Color(0xFF9AA5BC),
      surfaceContainerLowest: bg,
      surfaceContainerLow: surfaceHigh,
      surfaceContainer: const Color(0xFF1A2334),
      surfaceContainerHigh: const Color(0xFF222C40),
      surfaceContainerHighest: const Color(0xFF2C3750),
      inverseSurface: const Color(0xFFE8EDF7),
      onInverseSurface: const Color(0xFF0B0F18),
      outline: const Color(0xFF3D4A63),
      outlineVariant: const Color(0xFF2A3447),
      error: const Color(0xFFFF6B6B),
      errorContainer: const Color(0xFF5C1A1A),
      onError: const Color(0xFF1A0505),
    );

    final baseDark = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final sans = GoogleFonts.plusJakartaSansTextTheme(baseDark.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final textTheme = sans.copyWith(
      displayLarge: GoogleFonts.exo2(
        textStyle: sans.displayLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.exo2(
        textStyle: sans.displayMedium,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      displaySmall: GoogleFonts.exo2(
        textStyle: sans.displaySmall,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      headlineLarge: GoogleFonts.exo2(
        textStyle: sans.headlineLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.exo2(
        textStyle: sans.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.exo2(
        textStyle: sans.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.exo2(
        textStyle: sans.titleLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      titleMedium: sans.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: sans.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: sans.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      labelMedium: sans.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      labelSmall: sans.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      splashColor: scheme.primary.withOpacity(0.18),
      highlightColor: scheme.secondary.withOpacity(0.12),
      canvasColor: bg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer.withOpacity(0.55),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          final base = textTheme.labelMedium ?? const TextStyle();
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            );
          }
          return base.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 26);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outline.withOpacity(0.35)),
        ),
        shadowColor: scheme.primary.withOpacity(0.12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh.withOpacity(0.85),
        selectedColor: scheme.primaryContainer.withOpacity(0.55),
        disabledColor: scheme.surfaceContainerHighest.withOpacity(0.5),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.outline.withOpacity(0.35)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withOpacity(0.55)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer.withOpacity(0.45);
            }
            return scheme.surfaceContainerHigh;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurfaceVariant;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: scheme.outline.withOpacity(0.45)),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        elevation: 6,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withOpacity(0.65),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.secondary,
        textColor: scheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withOpacity(0.35),
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.primary.withOpacity(0.25)),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// Previous light palette (kept for reference or future toggle).
  static ThemeData light() {
    const indigo = Color(0xFF4F46E5);
    const teal = Color(0xFF0D9488);
    const rose = Color(0xFFE11D48);

    var scheme = ColorScheme.fromSeed(
      seedColor: indigo,
      brightness: Brightness.light,
    );

    scheme = scheme.copyWith(
      primary: indigo,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE0E7FF),
      onPrimaryContainer: const Color(0xFF1E1B4B),
      secondary: teal,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF99F6E4),
      onSecondaryContainer: const Color(0xFF042F2E),
      tertiary: rose,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFE4E6),
      onTertiaryContainer: const Color(0xFF881337),
      surface: const Color(0xFFF8FAFF),
      surfaceContainerLow: const Color(0xFFF0F4FF),
      surfaceContainer: const Color(0xFFE8EEF9),
      surfaceContainerHigh: const Color(0xFFDBE2F0),
      surfaceContainerHighest: const Color(0xFFC8D2E5),
      error: const Color(0xFFDC2626),
      errorContainer: const Color(0xFFFFE4E6),
      outline: const Color(0xFF94A3B8),
      outlineVariant: const Color(0xFFCBD5E1),
    );

    final textTheme = GoogleFonts.dmSansTextTheme().apply(
      bodyColor: const Color(0xFF1E293B),
      displayColor: const Color(0xFF0F172A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FF),
      textTheme: textTheme,
      splashColor: scheme.primary.withOpacity(0.12),
      highlightColor: scheme.secondary.withOpacity(0.08),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: scheme.primary.withOpacity(0.35),
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 12,
        shadowColor: scheme.primary.withOpacity(0.18),
        backgroundColor: scheme.surface,
        indicatorColor: scheme.tertiaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          final base = textTheme.labelMedium ?? const TextStyle();
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            );
          }
          return base.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 26);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shadowColor: scheme.primary.withOpacity(0.12),
        color: scheme.surface,
        surfaceTintColor: scheme.primary.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withOpacity(0.65)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer.withOpacity(0.65),
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return scheme.surfaceContainerHigh;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurfaceVariant;
          }),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.secondary,
        textColor: scheme.onSurface,
      ),
    );
  }
}
