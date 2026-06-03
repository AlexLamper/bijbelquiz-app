import 'package:flutter/material.dart';

class AppTheme {
  static const String sansFontName = 'Geist';
  static const String monoFontName = 'Geist Mono';

  static const Color canvas = Color(0xFFF4F6FB);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF131D2B);
  static const Color muted = Color(0xFF7B8494);
  static const Color border = Color(0xFFE2E7F1);
  static const Color accent = Color(0xFF6D86DB);
  static const Color accentSoft = Color(0xFFE8EEFF);
  static const Color filterActive = Color(0xFF718DD5);
  static const Color success = Color(0xFF22A06B);
  static const Color warning = Color(0xFFF6A64D);

  // Brand navy used on bijbelquiz.com (logo / hero / app icon background).
  static const Color brand = Color(0xFF1A2B5F);
  static const Color brandDeep = Color(0xFF131D2B);
  static const Color brandLight = Color(0xFF3A57A8);

  /// Diagonal navy gradient for hero surfaces (splash, onboarding).
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandDeep, brand, brandLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient for multiplayer / call-to-action surfaces.
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6D86DB), Color(0xFF89A4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextStyle monoTextStyle([TextStyle? baseStyle]) {
    return (baseStyle ?? const TextStyle()).copyWith(fontFamily: monoFontName);
  }

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accent,
        surface: surface,
        onSurface: ink,
        outline: border,
      ),
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: canvas,
      fontFamily: sansFontName,
      colorScheme: base.colorScheme,
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
        fontFamily: sansFontName,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        bodyColor: ink,
        displayColor: ink,
        fontFamily: sansFontName,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: roundedShape.copyWith(
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme;
  }
}
