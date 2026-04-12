import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode Colors
  static const Color _lightBg = Color(0xFFE9EFFB);
  static const Color _lightFg = Color(0xFF1A2333);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static final Color _lightPrimary = HSLColor.fromAHSL(
    1.0,
    223,
    0.60,
    0.48,
  ).toColor();
  static final Color _lightSecondary = HSLColor.fromAHSL(
    1.0,
    220,
    0.20,
    0.90,
  ).toColor();
  static final Color _lightMuted = HSLColor.fromAHSL(
    1.0,
    218,
    0.16,
    0.40,
  ).toColor();
  static final Color _lightBorder = HSLColor.fromAHSL(
    1.0,
    220,
    0.20,
    0.88,
  ).toColor();

  // Dark Mode Colors
  static final Color _darkBg = HSLColor.fromAHSL(
    1.0,
    218,
    0.32,
    0.10,
  ).toColor();
  static final Color _darkFg = HSLColor.fromAHSL(
    1.0,
    220,
    0.30,
    0.95,
  ).toColor();
  static final Color _darkCard = HSLColor.fromAHSL(
    1.0,
    218,
    0.32,
    0.13,
  ).toColor();
  static final Color _darkPrimary = HSLColor.fromAHSL(
    1.0,
    223,
    0.77,
    0.62,
  ).toColor();
  static final Color _darkMuted = HSLColor.fromAHSL(
    1.0,
    218,
    0.20,
    0.70,
  ).toColor();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      primaryColor: _lightPrimary,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        surface: _lightCard,
        onSurface: _lightFg,
        outline: _lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        foregroundColor: _lightFg,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightBorder),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      primaryColor: _darkPrimary,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.dark(
        primary: _darkPrimary,
        surface: _darkCard,
        onSurface: _darkFg,
        outline: _darkMuted, // Using muted for outline in dark mode roughly
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        foregroundColor: _darkFg,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _darkBg,
            width: 2,
          ), // Gives a slight inset look
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
