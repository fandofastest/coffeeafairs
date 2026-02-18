import 'package:flutter/material.dart';

ThemeData buildCoffeeTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  const seed = Color(0xFF6F4E37);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
  );

  final surface = isDark ? const Color(0xFF14110F) : const Color(0xFFFFF7EF);
  final card = isDark ? const Color(0xFF1F1916) : const Color(0xFFFFFFFF);
  final muted = isDark ? const Color(0xFF2A221E) : const Color(0xFFF3E8DE);

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
  );

  return base.copyWith(
    scaffoldBackgroundColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      elevation: 0,
      indicatorColor: scheme.primary.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.all(
        base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.45)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide.none,
      selectedColor: scheme.primary,
      checkmarkColor: scheme.onPrimary,
      labelStyle: base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      secondaryLabelStyle:
          base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
