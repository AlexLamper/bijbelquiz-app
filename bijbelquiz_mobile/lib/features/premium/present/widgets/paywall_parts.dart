import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/errors/app_error.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_notice.dart';
import '../../../../core/ui/bq.dart';
import '../../../quiz/data/free_quiz_limit.dart';
import '../../data/purchase_service.dart';
import '../../data/trial_reminder.dart';
import '../../domain/plan_pricing.dart' show lifetimeHorizonYears;

/// Building blocks shared by the paywall screen, the upgrade sheet and the
/// Premium intro: the explanatory "Quizzen" card, the benefit list with solid
/// green checks, the plan cards and the small print links.

const List<String> kPaywallBenefits = [
  'Alle quizzen, zo vaak je wilt',
  'Uitleg bij elk antwoord',
  'Je antwoorden terugkijken na elke quiz',
];

const BoxShadow _floatShadow = BoxShadow(
  color: Color(0x1A1B1A18),
  blurRadius: 20,
  offset: Offset(0, 10),
);

const String _checkSvg =
    '<svg viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M5 12.5l4.5 4.5L19 7"/></svg>';

const String _lockSvg =
    '<svg viewBox="0 0 24 24" fill="none" stroke="#8A877F" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>';

const String _crownSvg =
    '<svg viewBox="0 0 24 24" fill="#FFFFFF" stroke="#3D2C05" stroke-width="1.8" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M3 18L5 7l5 5 2-7 2 7 5-5 2 11z"/></svg>';

const String _shieldSvg =
    '<svg viewBox="0 0 24 24" fill="none" stroke="#3F6B4F" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M12 3l7 3v6c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6z"/><path d="M9 12l2 2 4-4"/></svg>';

double _deg(double degrees) => degrees * math.pi / 180;

// ---------------------------------------------------------------------------
// Explanatory visual
// ---------------------------------------------------------------------------

/// The tilted "Quizzen" card: one free book, two locked ones, and a gold
/// "Met Premium alles open" pill. Drawn at 84% and slightly transparent so it
/// explains without competing with the plans.
class PaywallPreview extends StatelessWidget {
  const PaywallPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label:
          'Gratis speel je $kFreeQuizLimit quizzen. Met Premium gaan alle '
          'bijbelboeken open, ook Psalmen en Openbaring.',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 200,
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: 236,
            maxHeight: 236,
            child: Opacity(
              opacity: 0.88,
              child: Transform.scale(
                scale: 0.84,
                alignment: Alignment.topCenter,
                child: const _PreviewStack(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewStack extends StatelessWidget {
  const _PreviewStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 236,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 208,
                height: 208,
                decoration: const BoxDecoration(
                  color: AppTheme.lapisSoft,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.translate(
                offset: const Offset(-6, 0),
                child: Transform.rotate(
                  angle: _deg(-2),
                  child: const _QuizListCard(),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: Transform.rotate(
              angle: _deg(3),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F1B1A18),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(_crownSvg, width: 16, height: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Met Premium alles open',
                      style: TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.goldInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizListCard extends StatelessWidget {
  const _QuizListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.rule),
        boxShadow: const [_floatShadow],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text(
              'Quizzen',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.inkMuted,
              ),
            ),
          ),
          _BookRow(
            abbreviation: 'Gen',
            title: 'Genesis',
            count: '12 quizzen',
            tileColor: AppTheme.positiveTint,
            tileText: AppTheme.positive,
            free: true,
          ),
          _BookRow(
            abbreviation: 'Ps',
            title: 'Psalmen',
            count: '15 quizzen',
            tileColor: AppTheme.lapisTint,
            tileText: AppTheme.lapis,
          ),
          _BookRow(
            abbreviation: 'Opb',
            title: 'Openbaring',
            count: '9 quizzen',
            tileColor: AppTheme.coralTint,
            tileText: AppTheme.vermilion,
            last: true,
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({
    required this.abbreviation,
    required this.title,
    required this.count,
    required this.tileColor,
    required this.tileText,
    this.free = false,
    this.last = false,
  });

  final String abbreviation;
  final String title;
  final String count;
  final Color tileColor;
  final Color tileText;
  final bool free;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.ruleSoft)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              abbreviation,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: tileText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                Text(
                  count,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: free ? AppTheme.positiveTint : AppTheme.goldTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!free) ...[
                  SvgPicture.string(_lockSvg, width: 13, height: 13),
                  const SizedBox(width: 4),
                ],
                Text(
                  free ? 'Gratis' : 'Premium',
                  style: TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: free ? AppTheme.positive : AppTheme.goldText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Benefits
// ---------------------------------------------------------------------------

/// Solid green circle with a white check.
class PaywallCheck extends StatelessWidget {
  const PaywallCheck({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppTheme.positive,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.string(
        _checkSvg,
        width: size * 0.54,
        height: size * 0.54,
      ),
    );
  }
}

/// A centred block of benefits, each behind a solid green check.
class PaywallBenefits extends StatelessWidget {
  const PaywallBenefits({super.key, this.items = kPaywallBenefits});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PaywallCheck(),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 20 / 15,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plans
// ---------------------------------------------------------------------------

/// One plan in the two-up plan grid. Selected: 2px lapis border and a lapis
/// plan name. An optional badge sits on the top edge.
class PaywallPlanCard extends StatelessWidget {
  const PaywallPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.note,
    this.badge,
    this.weekly,
  });

  final String title;
  final String price;
  final String period;
  final String? note;
  final String? badge;

  /// The plan's per-week equivalent ("€0,77"), shown as a blue highlight under
  /// the billed price. Null when the store price cannot be read as a number.
  ///
  /// Deliberately smaller than [price]: App Store (3.1.2) and Google Play both
  /// require the amount that is actually billed to be the most prominent price
  /// on a subscription offer, and reject paywalls that lead with a breakdown.
  /// The tinted pill makes the week the first thing the eye catches without
  /// making it the biggest number.
  final String? weekly;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badgeText = badge;
    final noteText = note;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      onTap: onTap,
      label: [
        title,
        '$price $period',
        if (weekly != null) '$weekly per week',
        if (noteText != null) noteText,
        if (badgeText != null) badgeText.toLowerCase(),
      ].join(', '),
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        // The card takes the full width its grid cell gives it.
        fit: StackFit.passthrough,
        children: [
          Material(
            color: AppTheme.paperRaised,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              side: selected
                  ? const BorderSide(color: AppTheme.lapis, width: 2)
                  : const BorderSide(color: AppTheme.rule),
            ),
            child: InkWell(
              onTap: onTap,
              highlightColor: AppTheme.ruleSoft.withValues(alpha: 0.6),
              splashColor: AppTheme.ruleSoft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 122),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: selected ? AppTheme.lapis : AppTheme.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          maxLines: 1,
                          style: const TextStyle(
                            fontFamily: AppTheme.sansFontName,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        period,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.inkSoft,
                        ),
                      ),
                      if (weekly != null) ...[
                        const SizedBox(height: 6),
                        PaywallWeeklyChip(amount: weekly!),
                      ],
                      if (noteText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          noteText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTheme.sansFontName,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.inkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (badgeText != null)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.lapis,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Text(
                    badgeText.toUpperCase(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.44,
                      color: AppTheme.inkInverted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "€0,77 per week" on a lapis pill: the per-week equivalent of a plan, in
/// the brand blue of the selected card rather than a second accent colour.
class PaywallWeeklyChip extends StatelessWidget {
  const PaywallWeeklyChip({super.key, required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.lapisTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.lapisSoft),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$amount per week',
          maxLines: 1,
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppTheme.lapis,
          ),
        ),
      ),
    );
  }
}

/// "Of eenmalig: levenslang Premium". A link while another plan is chosen;
/// once chosen it turns into a selected row that names the one-off price.
class PaywallLifetimeOption extends StatelessWidget {
  const PaywallLifetimeOption({
    super.key,
    required this.selected,
    required this.price,
    required this.onTap,
    this.weekly,
  });

  final bool selected;
  final String price;
  final VoidCallback? onTap;

  /// The one-off price spread over [lifetimeHorizonYears] years, per week.
  final String? weekly;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return Center(
        child: PaywallLink(
          label: 'Of eenmalig: levenslang Premium',
          onTap: onTap,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        button: true,
        selected: true,
        inMutuallyExclusiveGroup: true,
        label: [
          'Levenslang Premium, $price eenmalig',
          if (weekly != null)
            '$weekly per week over $lifetimeHorizonYears jaar',
        ].join(', '),
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.paperRaised,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.lapis, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Levenslang Premium',
                      style: TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.lapis,
                      ),
                    ),
                    Text(
                      '$price eenmalig',
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.inkSoft,
                      ),
                    ),
                    if (weekly != null)
                      Text(
                        '$weekly per week over $lifetimeHorizonYears jaar',
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.lapis,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppTheme.lapis,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.string(_checkSvg, width: 13, height: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small print
// ---------------------------------------------------------------------------

/// Text-only link with a 44px tap target.
class PaywallLink extends StatelessWidget {
  const PaywallLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppTheme.lapis,
    this.fontSize = 14,
    this.link = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  /// Opens a web page rather than acting in the app.
  final bool link;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !link,
      link: link,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: onTap == null ? color.withValues(alpha: 0.5) : color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shield + one reassuring line under the call to action.
class PaywallReassurance extends StatelessWidget {
  const PaywallReassurance(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.string(_shieldSvg, width: 14, height: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTheme.caption,
          ),
        ),
      ],
    );
  }
}

/// The reassurance line for the chosen plan.
///
/// With a trial: nothing is charged today, and the reminder day is named only
/// when [TrialReminder] can actually send one before the trial ends.
String paywallReassuranceText({
  required TrialOffer? trial,
  required bool isSubscription,
}) {
  if (trial != null) {
    final day = trialReminderDay(trialLengthInDays(trial));
    return day == null
        ? 'Vandaag betaal je niets.'
        : 'Vandaag betaal je niets. Herinnering op dag $day.';
  }
  return isSubscription
      ? 'Zeg op wanneer je wilt.'
      : 'Eenmalig betalen, geen abonnement.';
}

/// Call-to-action label: a trial is offered by name, anything else starts
/// Premium straight away.
String paywallCtaLabel(TrialOffer? trial) =>
    trial == null ? 'Start Premium' : 'Probeer ${trial.label}';

/// Opens a legal page in the browser, with a notice when that fails.
Future<void> openPaywallUrl(BuildContext context, String url) async {
  final didLaunch = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!didLaunch && context.mounted) {
    AppNotice.error(
      context,
      const AppError(
        title: 'Link niet geopend',
        message: 'We konden deze pagina niet openen. Probeer het opnieuw.',
      ),
    );
  }
}

/// The 40px close circle used on paywalls and the intro.
class PaywallCloseButton extends StatelessWidget {
  const PaywallCloseButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BqCircleButton(
      icon: BqIcons.close,
      label: 'Sluiten',
      iconColor: AppTheme.inkMuted,
      onTap: onTap,
    );
  }
}
