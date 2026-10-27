import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BijbelQuiz 2.0 design tokens.
///
/// Calm and professional: a warm grey background, white cards with a 1px
/// border, lapis as the one primary colour and small tinted accents for life
/// (gold = XP and rewards, coral = streak and duels, green = correct and done).
/// Titles and quiz questions use Fredoka, everything else Nunito.
///
/// The legacy names (paper, ink, rule, vermilion...) are kept as aliases so
/// every screen keeps compiling; they now map onto the new palette.
class AppTheme {
  // ---------------------------------------------------------------------
  // Typefaces
  // ---------------------------------------------------------------------

  /// UI face.
  static const String sansFontName = 'Nunito';

  /// Display face: page titles, card titles, quiz questions.
  static const String displayFontName = 'Fredoka';

  /// Kept for older call sites that wanted tabular figures.
  static const String monoFontName = 'Nunito';

  // ---------------------------------------------------------------------
  // Palette
  // ---------------------------------------------------------------------

  /// Page background.
  static const Color paper = Color(0xFFECEAE4);

  /// Cards, sheets, the tab bar.
  static const Color paperRaised = Color(0xFFFFFFFF);

  /// Inset fields and empty tracks inside cards.
  static const Color paperSunken = Color(0xFFF4F3EF);

  static const Color ink = Color(0xFF1B1A18);
  static const Color inkSoft = Color(0xFF45433E);
  static const Color inkMuted = Color(0xFF6B6860);
  static const Color inkFaint = Color(0xFF9A978F);
  static const Color inkInverted = Color(0xFFFFFFFF);

  /// Card border.
  static const Color rule = Color(0xFFDEDBD3);

  /// Pressed edge of white buttons and answer tiles.
  static const Color ruleStrong = Color(0xFFCFCBC1);

  /// Dividers inside cards, empty progress tracks.
  static const Color ruleSoft = Color(0xFFEEECE7);

  // Primary - lapis.
  static const Color lapis = Color(0xFF35548C);
  static const Color lapisStrong = Color(0xFF263E69);
  static const Color lapisTint = Color(0xFFEAEEF7);
  static const Color lapisSoft = Color(0xFFDFE5F2);
  static const Color lapisMutedText = Color(0xFF4F5F82);

  // Gold - XP, levels, rewards, quiz of the day.
  static const Color gold = Color(0xFFE9B12E);
  static const Color goldDeep = Color(0xFFA87C14);
  static const Color goldTint = Color(0xFFFBF1D6);
  static const Color goldText = Color(0xFF8A6410);
  static const Color goldInk = Color(0xFF3D2C05);

  // Coral - streak and duels.
  static const Color coral = Color(0xFFD9734F);
  static const Color coralDeep = Color(0xFFB4502B);
  static const Color coralEdge = Color(0xFF84391D);
  static const Color coralTint = Color(0xFFF8ECE6);
  static const Color coralLine = Color(0xFFEDCBBC);

  /// Coral text on a coral tint (also used for "wrong").
  static const Color vermilion = Color(0xFFA04A2F);
  static const Color vermilionStrong = Color(0xFF84391D);
  static const Color vermilionTint = coralTint;

  // Green - correct, completed, Old Testament.
  static const Color positive = Color(0xFF3F6B4F);
  static const Color positiveDeep = Color(0xFF2C4D38);
  static const Color positiveText = Color(0xFF2E5A3E);
  static const Color positiveTint = Color(0xFFE9F0EA);
  static const Color positiveMutedText = Color(0xFF4E6B57);

  static const Color destructive = Color(0xFFA04A2F);

  // The app is light-only for now; the dark aliases stay so older call sites
  // that referenced them still compile, and they resolve to the light look.
  static const Color darkPaper = paper;
  static const Color darkPaperRaised = paperRaised;
  static const Color darkPaperSunken = paperSunken;
  static const Color darkInk = ink;
  static const Color darkInkSoft = inkSoft;
  static const Color darkInkMuted = inkMuted;
  static const Color darkInkInverted = inkInverted;
  static const Color darkRule = rule;
  static const Color darkRuleStrong = ruleStrong;
  static const Color darkLapis = lapis;
  static const Color darkLapisStrong = lapisStrong;
  static const Color darkLapisTint = lapisTint;
  static const Color darkVermilion = vermilion;
  static const Color darkPositive = positive;
  static const Color darkDestructive = destructive;

  // ---------------------------------------------------------------------
  // Semantic aliases
  // ---------------------------------------------------------------------

  static const Color canvas = paper;
  static const Color surface = paperRaised;
  static const Color muted = inkMuted;
  static const Color border = rule;
  static const Color accent = lapis;
  static const Color accentSoft = lapisTint;
  static const Color filterActive = lapis;
  static const Color success = positive;
  static const Color warning = coral;
  static const Color error = destructive;
  static const Color brand = lapis;
  static const Color brandDeep = lapisStrong;
  static const Color brandLight = lapisMutedText;

  // ---------------------------------------------------------------------
  // Radii
  // ---------------------------------------------------------------------

  /// Cards and panels.
  static const double radiusLg = 16;

  /// Buttons, inputs, tiles.
  static const double radiusMd = 12;

  /// Small tiles and chips that are not pills.
  static const double radiusSm = 8;

  static const double radiusPill = 999;

  // ---------------------------------------------------------------------
  // Gradients - the design is flat; kept as solid lapis for old call sites.
  // ---------------------------------------------------------------------

  static const LinearGradient brandGradient = LinearGradient(
    colors: [lapis, lapis],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [lapis, lapis],
  );

  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: paperRaised,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static TextStyle monoTextStyle([TextStyle? baseStyle]) {
    return (baseStyle ?? const TextStyle()).copyWith(
      fontFamily: sansFontName,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // ---------------------------------------------------------------------
  // Type scale
  // ---------------------------------------------------------------------

  /// Page title - Fredoka 600 26/32.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFontName,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 32 / 26,
    color: ink,
  );

  /// Quiz question / hero title - Fredoka 600 24.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFontName,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 30 / 24,
    color: ink,
  );

  /// Section title - Nunito 800 17.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: sansFontName,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    height: 1.3,
    color: ink,
  );

  /// Card title - Fredoka 600 18.
  static const TextStyle displayTitle = TextStyle(
    fontFamily: displayFontName,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 23 / 18,
    color: ink,
  );

  /// Small card title - Fredoka 600 16.
  static const TextStyle displayBase = TextStyle(
    fontFamily: displayFontName,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: ink,
  );

  /// Numbers in stat tiles.
  static const TextStyle statNumber = TextStyle(
    fontFamily: sansFontName,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 22 / 18,
    color: ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Small uppercase label - use at most once per card.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: sansFontName,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: inkMuted,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: sansFontName,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: inkMuted,
  );

  static const TextStyle metaLabel = TextStyle(
    fontFamily: sansFontName,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: inkMuted,
  );

  /// Lead paragraph.
  static const TextStyle bodyLead = TextStyle(
    fontFamily: sansFontName,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 22 / 15,
    color: inkSoft,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: sansFontName,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: inkMuted,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: sansFontName,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 20 / 15,
    color: ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sansFontName,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    color: inkMuted,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: sansFontName,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  // ---------------------------------------------------------------------
  // ThemeData
  // ---------------------------------------------------------------------

  static ThemeData get lightTheme => _build();

  /// Light-only for now: the redesign was approved in light, and a dark
  /// variant needs its own review. Kept so `darkTheme:` call sites compile.
  static ThemeData get darkTheme => _build();

  static ThemeData _build() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lapis,
      onPrimary: inkInverted,
      secondary: lapis,
      onSecondary: inkInverted,
      tertiary: gold,
      onTertiary: goldInk,
      surface: paperRaised,
      onSurface: ink,
      surfaceContainerHighest: paperSunken,
      surfaceContainerHigh: paperSunken,
      surfaceContainer: paperRaised,
      surfaceContainerLow: paper,
      surfaceContainerLowest: paper,
      onSurfaceVariant: inkMuted,
      error: destructive,
      onError: inkInverted,
      outline: rule,
      outlineVariant: ruleSoft,
      shadow: Colors.transparent,
      scrim: Color(0x80000000),
      inverseSurface: ink,
      onInverseSurface: inkInverted,
      inversePrimary: lapisTint,
    );

    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: paper,
      canvasColor: paper,
      fontFamily: sansFontName,
      colorScheme: colorScheme,
      splashFactory: InkRipple.splashFactory,
      // Screens opened on top: the native slide on iOS (with swipe back), the
      // current Android fade elsewhere, instead of the older zoom.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFontName,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        iconTheme: IconThemeData(color: inkSoft, size: 22),
        systemOverlayStyle: overlayStyle,
      ),
      cardTheme: CardThemeData(
        color: paperRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: rule, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lapis,
          foregroundColor: inkInverted,
          disabledBackgroundColor: lapis.withValues(alpha: 0.45),
          disabledForegroundColor: inkInverted.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonLabel,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lapis,
          foregroundColor: inkInverted,
          disabledBackgroundColor: lapis.withValues(alpha: 0.45),
          disabledForegroundColor: inkInverted.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonLabel,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: paperRaised,
          foregroundColor: ink,
          side: const BorderSide(color: rule),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonLabel,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lapis,
          textStyle: const TextStyle(
            fontFamily: sansFontName,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: inkSoft,
          shape: const CircleBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperRaised,
        hintStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: inkMuted,
        ),
        labelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: inkMuted,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: lapis,
        ),
        prefixIconColor: inkFaint,
        suffixIconColor: inkFaint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: rule),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: lapis, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: destructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: destructive, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ruleSoft,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: paperRaised,
        selectedColor: lapis,
        side: const BorderSide(color: rule),
        labelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: inkSoft,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: inkInverted,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        showCheckmark: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: paperRaised,
        selectedItemColor: lapis,
        unselectedItemColor: inkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: paperRaised,
        surfaceTintColor: Colors.transparent,
        indicatorColor: lapisTint,
        elevation: 0,
        height: 64,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paperRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: rule),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: displayFontName,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 22 / 15,
          color: inkSoft,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: paperRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: inkInverted,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: lapis,
        linearTrackColor: ruleSoft,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 6,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(paperRaised),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? lapis : ruleStrong,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? lapis : paperRaised,
        ),
        side: const BorderSide(color: ruleStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? lapis : ruleStrong,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: lapis,
        unselectedLabelColor: inkMuted,
        indicatorColor: lapis,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: inkSoft,
        textColor: ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ink,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: inkInverted,
        ),
      ),
    );
  }

  static TextTheme _textTheme() {
    TextStyle display(double size, double lh) => TextStyle(
      fontFamily: displayFontName,
      fontSize: size,
      height: lh / size,
      fontWeight: FontWeight.w600,
      color: ink,
    );

    TextStyle sans(double size, double lh, FontWeight w, [Color c = ink]) =>
        TextStyle(
          fontFamily: sansFontName,
          fontSize: size,
          height: lh / size,
          fontWeight: w,
          color: c,
        );

    return TextTheme(
      displayLarge: display(34, 40),
      displayMedium: display(30, 36),
      displaySmall: display(26, 32),
      headlineLarge: display(24, 30),
      headlineMedium: display(22, 28),
      headlineSmall: display(20, 25),
      titleLarge: display(18, 23),
      titleMedium: sans(16, 21, FontWeight.w800),
      titleSmall: sans(15, 20, FontWeight.w700),
      bodyLarge: sans(16, 23, FontWeight.w600, inkSoft),
      bodyMedium: sans(15, 21, FontWeight.w600, inkSoft),
      bodySmall: sans(13, 18, FontWeight.w600, inkMuted),
      labelLarge: sans(15, 20, FontWeight.w800),
      labelMedium: sans(13, 17, FontWeight.w700, inkMuted),
      labelSmall: sans(12, 16, FontWeight.w800, inkMuted),
    );
  }
}
