import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/errors/app_error.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';
import '../../data/admin_models.dart';

/// Shared building blocks for the Beheer screens. Everything here sits on
/// the 2.0 look: canvas page, white cards with a hairline border, Fredoka
/// titles, Nunito UI, colour only as a small accent.

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

class AdminFormat {
  const AdminFormat._();

  static const List<String> _months = [
    'jan',
    'feb',
    'mrt',
    'apr',
    'mei',
    'jun',
    'jul',
    'aug',
    'sep',
    'okt',
    'nov',
    'dec',
  ];

  /// 12345 -> "12.345".
  static String number(num? value) {
    if (value == null) return '-';
    final negative = value < 0;
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '${negative ? '-' : ''}$buffer';
  }

  /// Cents to "€ 12,34" (or "USD 12,34" for other currencies).
  static String money(int? cents, [String currency = 'eur']) {
    if (cents == null) return '-';
    final negative = cents < 0;
    final abs = cents.abs();
    final whole = number(abs ~/ 100);
    final frac = (abs % 100).toString().padLeft(2, '0');
    final code = currency.toLowerCase();
    final symbol = switch (code) {
      'eur' => '€',
      'usd' => '\$',
      'gbp' => '£',
      _ => code.toUpperCase(),
    };
    return '${negative ? '-' : ''}$symbol $whole,$frac';
  }

  /// 0.1234 or 12.34 -> "12%". Values above 1 are already percentages.
  static String percent(num? value, {bool fraction = false}) {
    if (value == null) return '-';
    final p = fraction ? value * 100 : value;
    if (p > 0 && p < 1) return '${p.toStringAsFixed(1).replaceAll('.', ',')}%';
    return '${p.round()}%';
  }

  /// "27 okt 2026".
  static String date(DateTime? value) {
    if (value == null) return '-';
    final d = value.toLocal();
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// "27 okt 2026, 14:05".
  static String dateTime(DateTime? value) {
    if (value == null) return '-';
    final d = value.toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${date(d)}, $hh:$mm';
  }

  /// "vandaag", "gisteren", "3 dagen geleden", or the date beyond a month.
  static String relative(DateTime? value, {DateTime? now}) {
    if (value == null) return 'nooit';
    final ref = now ?? DateTime.now();
    final diff = ref.difference(value.toLocal());
    if (diff.isNegative) return date(value);
    if (diff.inMinutes < 1) return 'zojuist';
    if (diff.inHours < 1) return '${diff.inMinutes} min geleden';
    if (diff.inDays < 1) return '${diff.inHours} uur geleden';
    if (diff.inDays == 1) return 'gisteren';
    if (diff.inDays < 30) return '${diff.inDays} dagen geleden';
    return date(value);
  }

  /// Remaining time until [until]: "nog 12 dagen", "verlopen".
  static String remaining(DateTime? until, {DateTime? now}) {
    if (until == null) return 'geen einddatum';
    final ref = now ?? DateTime.now();
    final diff = until.difference(ref);
    if (diff.isNegative) return 'verlopen';
    if (diff.inDays >= 365 * 50) return 'levenslang';
    if (diff.inDays >= 1) return 'nog ${diff.inDays} dagen';
    if (diff.inHours >= 1) return 'nog ${diff.inHours} uur';
    return 'nog minder dan een uur';
  }
}

// ---------------------------------------------------------------------------
// Labels for server enums
// ---------------------------------------------------------------------------

class AdminLabels {
  const AdminLabels._();

  static String platform(String key) => switch (key) {
    'web_desktop' || 'webDesktop' || 'desktop' => 'Web (desktop)',
    'web_mobile' || 'webMobile' || 'mobile_web' => 'Web (mobiel)',
    'web' => 'Website',
    'ios' => 'iOS-app',
    'android' => 'Android-app',
    'app' => 'App',
    'unknown' || '' => 'Onbekend',
    _ => key,
  };

  static String method(String key) => switch (key) {
    'password' || 'email' || 'credentials' => 'E-mail',
    'google' => 'Google',
    'apple' => 'Apple',
    'unknown' || '' => 'Onbekend',
    _ => key,
  };

  static String premiumSource(String key) => switch (key) {
    'stripe' => 'Stripe (web)',
    'store' => 'App Store / Play',
    'appstore' || 'app_store' => 'App Store',
    'playstore' || 'play_store' => 'Google Play',
    'lifetime' => 'Levenslang',
    'group' => 'Groepslicentie',
    'manual' || 'granted' || 'grant' => 'Handmatig gegeven',
    'none' || 'free' => 'Geen',
    _ => key,
  };

  static String quizStatus(String key) => switch (key) {
    'pending' => 'Wacht op keuring',
    'approved' => 'Goedgekeurd',
    'published' => 'Gepubliceerd',
    'rejected' => 'Afgekeurd',
    'draft' => 'Concept',
    'unpublished' => 'Offline',
    _ => key,
  };

  static String paymentStatus(String key) => switch (key) {
    'completed' || 'paid' || 'succeeded' => 'Betaald',
    'pending' => 'In behandeling',
    'failed' => 'Mislukt',
    'refunded' => 'Terugbetaald',
    'partially_refunded' => 'Deels terugbetaald',
    'canceled' || 'cancelled' => 'Geannuleerd',
    'disputed' => 'Betwist',
    _ => key,
  };

  static String provider(String key) => switch (key) {
    'stripe' => 'Stripe',
    'revenuecat' || 'store' => 'Store',
    'app_store' || 'appstore' || 'ios' => 'App Store',
    'play_store' || 'playstore' || 'android' => 'Google Play',
    'manual' => 'Handmatig',
    _ => key,
  };

  /// Colour pair (background, foreground) for a status pill.
  static (Color, Color) tone(String status) => switch (status) {
    'ok' ||
    'completed' ||
    'paid' ||
    'succeeded' ||
    'approved' ||
    'published' ||
    'active' => (AppTheme.positiveTint, AppTheme.positiveText),
    'fail' ||
    'failed' ||
    'rejected' ||
    'disputed' ||
    'revoked' => (AppTheme.coralTint, AppTheme.vermilion),
    'warn' || 'pending' || 'refunded' || 'partially_refunded' => (
      AppTheme.goldTint,
      AppTheme.goldText,
    ),
    _ => (AppTheme.paperSunken, AppTheme.inkSoft),
  };
}

/// Fixed colour per platform so the split reads the same on every screen.
Color adminPlatformColor(String key) => switch (key) {
  'web_desktop' || 'webDesktop' || 'desktop' || 'web' => AppTheme.lapis,
  'web_mobile' || 'webMobile' || 'mobile_web' => const Color(0xFF8AA0C8),
  'ios' => AppTheme.ink,
  'android' => AppTheme.positive,
  'app' => AppTheme.coral,
  _ => AppTheme.inkFaint,
};

/// Colour per Premium source / revenue source.
Color adminSourceColor(String key) => switch (key) {
  'stripe' => AppTheme.lapis,
  'store' || 'revenuecat' => AppTheme.coral,
  'appstore' || 'app_store' || 'ios' => AppTheme.ink,
  'playstore' || 'play_store' || 'android' => AppTheme.positive,
  'lifetime' => AppTheme.gold,
  'group' => const Color(0xFF8AA0C8),
  'manual' || 'granted' || 'grant' => AppTheme.goldDeep,
  _ => AppTheme.inkFaint,
};

// ---------------------------------------------------------------------------
// Layout pieces
// ---------------------------------------------------------------------------

/// Section heading above a card: Nunito 800 17 with an optional caption.
class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle(this.title, {super.key, this.caption, this.trailing});

  final String title;
  final String? caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: AppTheme.displaySmall),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(caption!, style: AppTheme.caption),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// One figure in an [AdminStatGrid].
class AdminStat {
  const AdminStat(this.label, this.value, {this.hint, this.accent});

  final String label;
  final String value;
  final String? hint;

  /// Small coloured dot before the label.
  final Color? accent;
}

/// White card with figures in a two-column grid separated by soft rules.
class AdminStatGrid extends StatelessWidget {
  const AdminStatGrid({super.key, required this.stats, this.columns = 2});

  final List<AdminStat> stats;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += columns) {
      if (i > 0) {
        rows.add(
          const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
        );
      }
      final cells = <Widget>[];
      for (var c = 0; c < columns; c++) {
        if (c > 0) {
          cells.add(const VerticalDivider(width: 1, color: AppTheme.ruleSoft));
        }
        final index = i + c;
        cells.add(
          Expanded(
            child: index < stats.length
                ? _StatCell(stat: stats[index])
                : const SizedBox.shrink(),
          ),
        );
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }
    return BqCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});

  final AdminStat stat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.statNumber.copyWith(fontSize: 22, height: 1.15),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              if (stat.accent != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: stat.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  stat.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption,
                ),
              ),
            ],
          ),
          if (stat.hint != null) ...[
            const SizedBox(height: 2),
            Text(
              stat.hint!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.caption.copyWith(
                fontSize: 12,
                color: AppTheme.inkFaint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One part of an [AdminSplitCard].
class AdminSlice {
  const AdminSlice({
    required this.label,
    required this.value,
    required this.color,
    this.detail,
  });

  final String label;
  final num value;
  final Color color;

  /// Shown under the label, e.g. a secondary figure.
  final String? detail;
}

/// A stacked bar (plain widgets, no chart package) with a legend: label,
/// count and share per slice. Empty slices stay in the legend at 0.
class AdminSplitCard extends StatelessWidget {
  const AdminSplitCard({
    super.key,
    required this.slices,
    this.title,
    this.valueFormat,
    this.emptyText = 'Nog geen gegevens.',
    this.footer,
  });

  final String? title;
  final List<AdminSlice> slices;
  final String Function(num value)? valueFormat;
  final String emptyText;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<num>(0, (sum, s) => sum + (s.value > 0 ? s.value : 0));
    final fmt = valueFormat ?? (num v) => AdminFormat.number(v);
    return BqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTheme.displayBase),
            const SizedBox(height: 12),
          ],
          AdminStackedBar(slices: slices),
          const SizedBox(height: 12),
          if (total <= 0)
            Text(emptyText, style: AppTheme.caption)
          else
            for (final s in slices)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodyStrong.copyWith(fontSize: 14),
                          ),
                          if (s.detail != null)
                            Text(
                              s.detail!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.caption.copyWith(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fmt(s.value),
                      style: AppTheme.bodyStrong.copyWith(
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        AdminFormat.percent(
                          total > 0 ? (s.value / total) * 100 : 0,
                        ),
                        textAlign: TextAlign.right,
                        style: AppTheme.caption.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          if (footer != null) ...[const SizedBox(height: 8), footer!],
        ],
      ),
    );
  }
}

/// The bar itself: one rounded track, slices proportional to their value.
class AdminStackedBar extends StatelessWidget {
  const AdminStackedBar({super.key, required this.slices, this.height = 14});

  final List<AdminSlice> slices;
  final double height;

  @override
  Widget build(BuildContext context) {
    final parts = slices.where((s) => s.value > 0).toList();
    final total = parts.fold<num>(0, (sum, s) => sum + s.value);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: total <= 0
            ? const ColoredBox(color: AppTheme.ruleSoft)
            : Row(
                children: [
                  for (var i = 0; i < parts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Expanded(
                      // At least 1 so a tiny slice is still visible.
                      flex: ((parts[i].value / total) * 1000).round().clamp(
                        1,
                        1000,
                      ),
                      child: ColoredBox(color: parts[i].color),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

/// A row of horizontal bars for comparing a few values (e.g. 1/7/30 days).
class AdminBarList extends StatelessWidget {
  const AdminBarList({super.key, required this.slices, this.valueFormat});

  final List<AdminSlice> slices;
  final String Function(num value)? valueFormat;

  @override
  Widget build(BuildContext context) {
    final max = slices.fold<num>(0, (m, s) => s.value > m ? s.value : m);
    final fmt = valueFormat ?? (num v) => AdminFormat.number(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 104,
                  child: Text(
                    s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BqProgressBar(
                    value: max > 0 ? s.value / max : 0,
                    color: s.color,
                    height: 10,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 56,
                  child: Text(
                    fmt(s.value),
                    textAlign: TextAlign.right,
                    style: AppTheme.bodyStrong.copyWith(
                      fontSize: 14,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Label / value rows in a white card.
class AdminKvCard extends StatelessWidget {
  const AdminKvCard({super.key, required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return BqListCard(
      children: [
        for (final (label, value) in rows) AdminKvRow(label: label, value: value),
      ],
    );
  }
}

class AdminKvRow extends StatelessWidget {
  const AdminKvRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(label, style: AppTheme.bodyMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTheme.bodyStrong.copyWith(
                fontSize: 14,
                color: valueColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small status pill.
class AdminStatusPill extends StatelessWidget {
  const AdminStatusPill({super.key, required this.label, required this.status});

  final String label;

  /// Picks the tint via [AdminLabels.tone].
  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = AdminLabels.tone(status);
    return BqPill(
      label: label,
      background: bg,
      foreground: fg,
      height: 22,
      fontSize: 11,
    );
  }
}

/// A muted note in a white card - used for empty sections.
class AdminEmptyCard extends StatelessWidget {
  const AdminEmptyCard(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return BqCard(child: Text(text, style: AppTheme.bodyMuted));
  }
}

// ---------------------------------------------------------------------------
// Section switcher
// ---------------------------------------------------------------------------

/// Horizontally scrolling pill tabs (Overzicht, Gebruikers, ...).
class AdminSegmentedControl extends StatelessWidget {
  const AdminSegmentedControl({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AdminChip(
              label: labels[i],
              selected: i == selected,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pill chip: white with border, lapis when selected.
class AdminChip extends StatelessWidget {
  const AdminChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppTheme.lapis : AppTheme.paperRaised,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? AppTheme.lapis : AppTheme.rule),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: compact ? 32 : 38,
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w800,
                color: selected ? AppTheme.inkInverted : AppTheme.inkSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / errors
// ---------------------------------------------------------------------------

/// Grey placeholder block that pulses softly.
class AdminSkeletonBox extends StatefulWidget {
  const AdminSkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = AppTheme.radiusSm,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<AdminSkeletonBox> createState() => _AdminSkeletonBoxState();
}

class _AdminSkeletonBoxState extends State<AdminSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(_controller),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: AppTheme.ruleSoft,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A page of skeleton cards, scrollable so pull to refresh still works.
class AdminSkeletonList extends StatelessWidget {
  const AdminSkeletonList({super.key, this.cards = 4, this.rows = 3});

  final int cards;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        for (var c = 0; c < cards; c++) ...[
          const AdminSkeletonBox(height: 18, width: 140),
          const SizedBox(height: 10),
          BqCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var r = 0; r < rows; r++) ...[
                  if (r > 0) const SizedBox(height: 12),
                  AdminSkeletonBox(
                    height: 14,
                    width: r.isEven ? double.infinity : 180,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

/// Full-area error with a retry button. A missing endpoint (older server)
/// becomes "Werk de server bij" instead of a scary error.
class AdminErrorView extends StatelessWidget {
  const AdminErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.scrollable = true,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final (icon, title, message) = describeAdminError(error);
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: BqCard(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BqIconTile(
              size: 48,
              radius: 14,
              background: AppTheme.paperSunken,
              child: Icon(icon, color: AppTheme.inkMuted, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.displayTitle,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 18),
            BqButton(
              label: 'Opnieuw proberen',
              style: BqButtonStyle.secondary,
              height: 46,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
    if (!scrollable) return body;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [body],
    );
  }
}

/// (icon, title, message) for an error thrown by the admin repository.
(IconData, String, String) describeAdminError(Object error) {
  if (error is AdminEndpointMissing) {
    return (
      Icons.system_update_alt,
      'Werk de server bij',
      'Deze server kent ${error.what} nog niet. Zet de nieuwste versie van de '
          'website live en ververs dan.',
    );
  }
  if (error is AdminApiException) {
    if (error.statusCode == 403) {
      return (
        Icons.lock_outline,
        'Geen toegang',
        'Dit account is geen beheerder.',
      );
    }
    if (error.statusCode == 401) {
      return (
        Icons.lock_outline,
        'Opnieuw inloggen',
        'Je sessie is verlopen. Log opnieuw in.',
      );
    }
    return (Icons.error_outline, 'Er ging iets mis', error.message);
  }
  if (error is DioException) {
    final mapped = AppError.from(error.error ?? error.message ?? error);
    return (mapped.icon, mapped.title, mapped.message);
  }
  final mapped = AppError.from(error);
  return (mapped.icon, mapped.title, mapped.message);
}
