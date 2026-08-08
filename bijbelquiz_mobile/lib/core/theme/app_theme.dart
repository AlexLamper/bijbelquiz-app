import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens copied 1:1 from www.bijbelquiz.com.
///
/// The site is an editorial/print inspired system: a warm paper background,
/// ink coloured type, hairline rules instead of shadows, a serif display face
/// (Newsreader) for headings and Inter for everything else.
///
/// CSS reference (`:root` of the site stylesheet):
///   --paper:#faf9f6  --paper-raised:#fff  --paper-sunken:#f1efe9
///   --ink:#1b1a18    --ink-soft:#45433e   --ink-muted:#6f6c64
///   --ink-inverted:#faf9f6
///   --rule:#e6e3db   --rule-strong:#d3cfc4
///   --lapis:#35548c  --lapis-strong:#2a4373  --lapis-tint:#eaeef7
///   --vermilion:#a04a2f --vermilion-strong:#883b23 --vermilion-tint:#f8ece6
///   --positive:#3f6b4f  --positive-tint:#e9f0ea
///   --destructive:#9b3b26
///   --radius:.5rem
class AppTheme {
  // ---------------------------------------------------------------------
  // Typefaces
  // ---------------------------------------------------------------------

  /// Body / UI face — Inter (`--font-sans`).
  static const String sansFontName = 'Inter';

  /// Display face — Newsreader (`--font-serif`, used via `.font-display`).
  static const String displayFontName = 'Newsreader';

  /// Kept for backwards compatibility with older call sites.
  static const String monoFontName = 'Inter';

  // ---------------------------------------------------------------------
  // Raw palette (light mode = the site's default)
  // ---------------------------------------------------------------------

  static const Color paper = Color(0xFFFAF9F6);
  static const Color paperRaised = Color(0xFFFFFFFF);
  static const Color paperSunken = Color(0xFFF1EFE9);

  static const Color ink = Color(0xFF1B1A18);
  static const Color inkSoft = Color(0xFF45433E);
  static const Color inkMuted = Color(0xFF6F6C64);
  static const Color inkInverted = Color(0xFFFAF9F6);

  static const Color rule = Color(0xFFE6E3DB);
  static const Color ruleStrong = Color(0xFFD3CFC4);

  static const Color lapis = Color(0xFF35548C);
  static const Color lapisStrong = Color(0xFF2A4373);
  static const Color lapisTint = Color(0xFFEAEEF7);

  static const Color vermilion = Color(0xFFA04A2F);
  static const Color vermilionStrong = Color(0xFF883B23);
  static const Color vermilionTint = Color(0xFFF8ECE6);

  static const Color positive = Color(0xFF3F6B4F);
  static const Color positiveTint = Color(0xFFE9F0EA);

  static const Color destructive = Color(0xFF9B3B26);

  // Dark palette (site `.dark`) — exposed so surfaces that must stay dark
  // (splash / onboarding) use the exact same values as the website.
  static const Color darkPaper = Color(0xFF0D0D0C);
  static const Color darkPaperRaised = Color(0xFF161513);
  static const Color darkPaperSunken = Color(0xFF1D1C19);
  static const Color darkInk = Color(0xFFF4F2EC);
  static const Color darkInkSoft = Color(0xFFCBC7BD);
  static const Color darkInkMuted = Color(0xFF918D83);
  static const Color darkInkInverted = Color(0xFF131211);
  static const Color darkRule = Color(0xFF2A2925);
  static const Color darkRuleStrong = Color(0xFF3D3B35);
  static const Color darkLapis = Color(0xFF8AA6D9);
  static const Color darkLapisStrong = Color(0xFFA4BBE6);
  static const Color darkLapisTint = Color(0xFF141A28);
  static const Color darkVermilion = Color(0xFFD98B6A);
  static const Color darkPositive = Color(0xFF7FB08D);
  static const Color darkDestructive = Color(0xFFC2604A);

  // ---------------------------------------------------------------------
  // Semantic aliases (legacy names kept so existing screens keep compiling)
  // ---------------------------------------------------------------------

  /// Page background — `bg-paper`.
  static const Color canvas = paper;

  /// Card background — `bg-paper-raised`.
  static const Color surface = paperRaised;

  /// Muted / secondary text — `text-ink-muted`.
  static const Color muted = inkMuted;

  /// Hairline — `border-rule`.
  static const Color border = rule;

  /// Accent — `text-lapis` / `bg-lapis`.
  static const Color accent = lapis;

  /// Accent wash — `bg-lapis-tint`.
  static const Color accentSoft = lapisTint;

  /// Active filter chip on the site is solid ink, not a tint.
  static const Color filterActive = ink;

  static const Color success = positive;
  static const Color warning = vermilion;
  static const Color error = destructive;

  /// The site has no navy brand colour any more; the "brand" surface is ink.
  static const Color brand = ink;
  static const Color brandDeep = Color(0xFF0D0D0C);
  static const Color brandLight = inkSoft;

  // ---------------------------------------------------------------------
  // Radii (`--radius: .5rem`)
  // ---------------------------------------------------------------------

  /// `rounded-lg` — cards, panels.
  static const double radiusLg = 8;

  /// `rounded-md` — buttons, inputs, images.
  static const double radiusMd = 6;

  /// `rounded-sm` — badges.
  static const double radiusSm = 4;

  // ---------------------------------------------------------------------
  // Gradients — the site is flat, so these are near-solid ink washes used
  // only by the full-bleed splash / onboarding surfaces.
  // ---------------------------------------------------------------------

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF0D0D0C), ink, Color(0xFF262421)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [lapisStrong, lapis],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Status bar / nav bar styling matching the paper background.
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: paper,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static TextStyle monoTextStyle([TextStyle? baseStyle]) {
    return (baseStyle ?? const TextStyle()).copyWith(
      fontFamily: sansFontName,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // ---------------------------------------------------------------------
  // Type scale — mirrors the utility classes used on the site
  // ---------------------------------------------------------------------

  /// `font-display text-[32px] font-normal leading-[1.08] tracking-[-0.025em]`
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFontName,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.08,
    letterSpacing: -0.8,
    color: ink,
  );

  /// `font-display text-[26px] font-normal leading-[1.12] tracking-[-0.025em]`
  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFontName,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 1.12,
    letterSpacing: -0.65,
    color: ink,
  );

  /// `font-display text-xl font-normal tracking-[-0.015em]` — section titles.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFontName,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.3,
    color: ink,
  );

  /// `font-display text-lg font-normal leading-snug` — card titles.
  static const TextStyle displayTitle = TextStyle(
    fontFamily: displayFontName,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.375,
    color: ink,
  );

  /// `font-display text-base leading-snug`
  static const TextStyle displayBase = TextStyle(
    fontFamily: displayFontName,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.375,
    color: ink,
  );

  /// `font-display text-[22px] font-normal leading-none tracking-[-0.015em]
  /// tabular-nums` — the stat numbers in rule-separated strips.
  static const TextStyle statNumber = TextStyle(
    fontFamily: displayFontName,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: -0.33,
    color: ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// `text-[11px] font-medium uppercase tracking-[0.18em] text-ink-muted`
  static const TextStyle eyebrow = TextStyle(
    fontFamily: sansFontName,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.98,
    color: inkMuted,
  );

  /// `text-[10px] font-medium uppercase tracking-[0.16em] text-ink-muted`
  static const TextStyle overline = TextStyle(
    fontFamily: sansFontName,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.6,
    color: inkMuted,
  );

  /// `text-[11px] font-medium uppercase tracking-[0.16em] text-ink-muted`
  static const TextStyle metaLabel = TextStyle(
    fontFamily: sansFontName,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.76,
    color: inkMuted,
  );

  /// `text-[15px] leading-relaxed text-ink-muted`
  static const TextStyle bodyLead = TextStyle(
    fontFamily: sansFontName,
    fontSize: 15,
    height: 1.625,
    color: inkMuted,
  );

  /// `text-sm leading-relaxed text-ink-muted`
  static const TextStyle bodyMuted = TextStyle(
    fontFamily: sansFontName,
    fontSize: 14,
    height: 1.625,
    color: inkMuted,
  );

  /// `text-sm font-medium text-ink`
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: sansFontName,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: ink,
  );

  /// `text-xs text-ink-muted`
  static const TextStyle caption = TextStyle(
    fontFamily: sansFontName,
    fontSize: 12,
    height: 1.45,
    color: inkMuted,
  );

  /// Button label — `text-sm font-medium`.
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: sansFontName,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  // ---------------------------------------------------------------------
  // ThemeData
  // ---------------------------------------------------------------------

  static ThemeData get lightTheme => _build(
    brightness: Brightness.light,
    bg: paper,
    card: paperRaised,
    sunken: paperSunken,
    fg: ink,
    fgSoft: inkSoft,
    fgMuted: inkMuted,
    fgInverted: inkInverted,
    line: rule,
    lineStrong: ruleStrong,
    ring: lapis,
    danger: destructive,
  );

  static ThemeData get darkTheme => _build(
    brightness: Brightness.dark,
    bg: darkPaper,
    card: darkPaperRaised,
    sunken: darkPaperSunken,
    fg: darkInk,
    fgSoft: darkInkSoft,
    fgMuted: darkInkMuted,
    fgInverted: darkInkInverted,
    line: darkRule,
    lineStrong: darkRuleStrong,
    ring: darkLapis,
    danger: darkDestructive,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color sunken,
    required Color fg,
    required Color fgSoft,
    required Color fgMuted,
    required Color fgInverted,
    required Color line,
    required Color lineStrong,
    required Color ring,
    required Color danger,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      // The site's primary action is solid ink, not the accent blue.
      primary: fg,
      onPrimary: fgInverted,
      secondary: ring,
      onSecondary: fgInverted,
      surface: card,
      onSurface: fg,
      surfaceContainerHighest: sunken,
      surfaceContainerHigh: sunken,
      surfaceContainer: card,
      surfaceContainerLow: bg,
      surfaceContainerLowest: bg,
      onSurfaceVariant: fgMuted,
      error: danger,
      onError: fgInverted,
      outline: line,
      outlineVariant: lineStrong,
      shadow: Colors.transparent,
      scrim: Color(0x80000000),
      inverseSurface: fg,
      onInverseSurface: fgInverted,
      inversePrimary: fgInverted,
    );

    final textTheme = _textTheme(fg, fgMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      fontFamily: sansFontName,
      colorScheme: colorScheme,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFontName,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: fg,
        ),
        iconTheme: IconThemeData(color: fgSoft, size: 20),
        systemOverlayStyle: brightness == Brightness.light
            ? overlayStyle
            : overlayStyle.copyWith(
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarColor: bg,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: line, width: 1),
        ),
      ),
      // `bg-ink text-ink-inverted hover:bg-ink-soft` at `h-11 rounded-md`.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: fg,
          foregroundColor: fgInverted,
          disabledBackgroundColor: fg.withValues(alpha: 0.5),
          disabledForegroundColor: fgInverted.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonLabel,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: fg,
          foregroundColor: fgInverted,
          disabledBackgroundColor: fg.withValues(alpha: 0.5),
          disabledForegroundColor: fgInverted.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonLabel,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      // `border border-rule bg-paper-raised text-ink hover:bg-paper-sunken`
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: card,
          foregroundColor: fg,
          side: BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonLabel,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: fgSoft,
          textStyle: buttonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: fgSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      // `h-12 rounded-md border border-rule bg-paper-raised px-4
      //  placeholder:text-ink-muted focus:border-lapis`
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          color: fgMuted,
        ),
        labelStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          color: fgMuted,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ring,
        ),
        prefixIconColor: fgMuted,
        suffixIconColor: fgMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: ring, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: danger, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: fg,
        side: BorderSide(color: line),
        labelStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        showCheckmark: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: fg,
        unselectedItemColor: fgMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: sunken,
        elevation: 0,
        height: 64,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: line),
        ),
        titleTextStyle: TextStyle(
          fontFamily: displayFontName,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: fg,
        ),
        contentTextStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          height: 1.625,
          color: fgMuted,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: fg,
        contentTextStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          color: fgInverted,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: fg,
        linearTrackColor: sunken,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 2,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? fgInverted : card,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? fg : sunken,
        ),
        trackOutlineColor: WidgetStateProperty.all(line),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: fg,
        unselectedLabelColor: fgMuted,
        indicatorColor: fg,
        dividerColor: line,
        labelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: sansFontName,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: fgSoft,
        textColor: fg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: fg,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: TextStyle(
          fontFamily: sansFontName,
          fontSize: 12,
          color: fgInverted,
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color fg, Color fgMuted) {
    TextStyle display(double size, double lh, double ls, FontWeight w) =>
        TextStyle(
          fontFamily: displayFontName,
          fontSize: size,
          height: lh,
          letterSpacing: ls,
          fontWeight: w,
          color: fg,
        );

    TextStyle sans(
      double size,
      double lh,
      FontWeight w, [
      Color? c,
      double ls = 0,
    ]) => TextStyle(
      fontFamily: sansFontName,
      fontSize: size,
      height: lh,
      fontWeight: w,
      letterSpacing: ls,
      color: c ?? fg,
    );

    return TextTheme(
      displayLarge: display(40, 1.08, -1.0, FontWeight.w400),
      displayMedium: display(34, 1.1, -0.85, FontWeight.w400),
      displaySmall: display(26, 1.12, -0.65, FontWeight.w400),
      headlineLarge: display(24, 1.15, -0.36, FontWeight.w400),
      headlineMedium: display(20, 1.2, -0.3, FontWeight.w400),
      headlineSmall: display(18, 1.375, 0, FontWeight.w400),
      titleLarge: display(18, 1.375, 0, FontWeight.w400),
      titleMedium: sans(15, 1.45, FontWeight.w500),
      titleSmall: sans(14, 1.45, FontWeight.w500),
      bodyLarge: sans(15, 1.625, FontWeight.w400),
      bodyMedium: sans(14, 1.625, FontWeight.w400, fgMuted),
      bodySmall: sans(12, 1.45, FontWeight.w400, fgMuted),
      labelLarge: sans(14, 1.2, FontWeight.w500),
      labelMedium: sans(12, 1.2, FontWeight.w500, fgMuted),
      labelSmall: sans(10, 1.2, FontWeight.w500, fgMuted, 1.6),
    );
  }
}
