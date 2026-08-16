import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/purchase_service.dart';
import 'premium_controller.dart';

enum _PremiumPlan { yearly, monthly, lifetime }

/// Headline naming what the player was just stopped from doing.
///
/// A paywall that opens on "Premium" sells a product; one that opens on "je
/// gratis spellen zijn op" answers the question the player actually has.
const Map<String, String> _triggerHeadlines = {
  PaywallTrigger.hostQuotaExhausted: 'Speel onbeperkt samen verder',
  PaywallTrigger.hostQuotaWarning: 'Speel onbeperkt samen verder',
  PaywallTrigger.hostPlayerCap: 'Speel met je hele groep',
  PaywallTrigger.explanationLocked: 'Lees bij elke vraag waarom',
  PaywallTrigger.premiumQuizLocked: 'Ontgrendel alle quizzen',
  PaywallTrigger.direct: 'Kies je plan',
};

const Map<String, String> _triggerLeads = {
  PaywallTrigger.hostQuotaExhausted:
      'Je gratis spellen zijn op. Met Premium host je zoveel spellen als je '
      'wilt, met tot 20 spelers tegelijk. Meedoen met andermans spel blijft '
      'altijd gratis.',
  PaywallTrigger.hostQuotaWarning:
      'Je hebt bijna geen gratis spellen meer. Met Premium host je zoveel '
      'spellen als je wilt, met tot 20 spelers tegelijk.',
  PaywallTrigger.hostPlayerCap:
      'Gratis spelen jullie met vier. Met Premium passen er 20 spelers in een '
      'kamer, genoeg voor een hele jeugdgroep of klas.',
  PaywallTrigger.explanationLocked:
      'Bij elke vraag hoort een uitleg en een bijbelverwijzing. Met Premium '
      'lees je ze allemaal, ook na afloop.',
  PaywallTrigger.premiumQuizLocked:
      'Deze quiz hoort bij de premium collectie. Met Premium speel je alle '
      'quizzen, nu en in de toekomst.',
  PaywallTrigger.direct:
      'Alle plannen geven volledige toegang tot elke premium functie.',
};

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key, this.trigger = PaywallTrigger.direct});

  /// Which surface sent the player here. Recorded on the funnel event and used
  /// to pick the headline.
  final String trigger;

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  _PremiumPlan _selectedPlan = _PremiumPlan.yearly;

  DateTime? _shownAt;
  bool _startedPurchase = false;

  /// Held rather than read from `ref` in [dispose]: reading a provider while
  /// the scope is being torn down throws, and the dismissal event has to
  /// survive exactly that teardown.
  late final Analytics _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = ref.read(analyticsProvider);
    _shownAt = DateTime.now();
    _analytics.track(
      AnalyticsEvents.paywallShown,
      props: {'trigger': widget.trigger, 'surface': 'premium_screen'},
    );
  }

  @override
  void dispose() {
    // Leaving without starting a purchase is the signal the funnel needs: it
    // is the difference between "nobody saw the wall" and "everybody saw it
    // and walked away".
    if (!_startedPurchase) {
      final shownAt = _shownAt;
      _analytics.track(
        AnalyticsEvents.paywallDismissed,
        props: {
          'trigger': widget.trigger,
          'surface': 'premium_screen',
          'secondsVisible': shownAt == null
              ? 0
              : DateTime.now().difference(shownAt).inSeconds,
        },
      );
    }
    super.dispose();
  }

  void _showSuccess(bool isPremium) {
    if (!mounted) return;
    if (isPremium) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Welkom bij Premium'),
          content: const Text(
            'Je hebt nu volledige toegang tot alle premium functies. Veel plezier!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('Sluiten'),
            ),
          ],
        ),
      );
    } else {
      AppNotice.success(context, 'Aankopen hersteld.');
    }
  }

  void _onPurchase() {
    _startedPurchase = true;

    final notifier = ref.read(premiumControllerProvider.notifier);
    switch (_selectedPlan) {
      case _PremiumPlan.yearly:
        notifier.purchaseYearly();
      case _PremiumPlan.monthly:
        notifier.purchaseMonthly();
      case _PremiumPlan.lifetime:
        notifier.purchaseLifetime();
    }
  }

  Future<void> _openLegalUrl(String url) async {
    final uri = Uri.parse(url);
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && mounted) {
      AppNotice.error(
        context,
        const AppError(
          title: 'Link niet geopend',
          message: 'We konden deze pagina niet openen. Probeer het opnieuw.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PremiumState>(premiumControllerProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == PurchaseStatus.success) {
        _showSuccess(next.isPremium);
        ref.read(premiumControllerProvider.notifier).clearStatus();
      } else if (next.status == PurchaseStatus.error &&
          next.errorMessage != null) {
        if (!mounted) return;
        AppNotice.error(context, next.errorMessage);
        ref.read(premiumControllerProvider.notifier).clearStatus();
      }
    });

    final premiumState = ref.watch(premiumControllerProvider);
    final isLoading = premiumState.status == PurchaseStatus.loading;

    final service = ref.read(purchaseServiceProvider);
    final monthlyPackage = service.findMonthlyPackage(premiumState.packages);
    final yearlyPackage = service.findYearlyPackage(premiumState.packages);
    final lifetimePackage = service.findLifetimePackage(premiumState.packages);

    final monthlyPrice = monthlyPackage?.storeProduct.priceString ?? '€5,99';
    final yearlyPrice = yearlyPackage?.storeProduct.priceString ?? '€39,99';
    final lifetimePrice = lifetimePackage?.storeProduct.priceString ?? '€74,99';

    // Read from the store, never assumed: promising a trial the store will not
    // honour is a rejected review and a refund request.
    final trial = PurchaseService.trialOffer(
      _selectedPlan == _PremiumPlan.yearly ? yearlyPackage : monthlyPackage,
    );
    final hasTrial = trial != null && _selectedPlan != _PremiumPlan.lifetime;

    final savings = _savingsPercent(monthlyPrice, yearlyPrice);
    final yearlyPerMonth = _perMonthLabel(yearlyPrice);

    final isSubscription = _selectedPlan != _PremiumPlan.lifetime;
    final selectedPlanDetails = switch (_selectedPlan) {
      _PremiumPlan.yearly =>
        'Abonnementdetails: Bijbelquiz Premium Jaarlijks - $yearlyPrice per jaar.',
      _PremiumPlan.monthly =>
        'Abonnementdetails: Bijbelquiz Premium Maandelijks - $monthlyPrice per maand.',
      _PremiumPlan.lifetime =>
        'Abonnementdetails: Bijbelquiz Premium Levenslang - $lifetimePrice eenmalig.',
    };
    final billingInfoText = isSubscription
        ? 'Abonnementen worden via je App Store-account beheerd en verlengen automatisch, tenzij je minimaal 24 uur voor het einde van de lopende periode opzegt.'
        : 'Levenslang is een eenmalige aankoop via je App Store-account en verlengt niet automatisch.';
    final trialInfoText = hasTrial
        ? 'Je proefperiode van ${trial.label.replaceAll(' gratis', '')} is gratis. '
              'Daarna gaat het abonnement door tenzij je minimaal 24 uur voor '
              'het einde opzegt in je App Store-instellingen.'
        : null;

    final ctaLabel = isLoading
        ? 'Verwerken…'
        : hasTrial
        ? 'Start ${trial.label}'
        : switch (_selectedPlan) {
            _PremiumPlan.yearly => 'Ga verder met Jaarlijks',
            _PremiumPlan.monthly => 'Ga verder met Maandelijks',
            _PremiumPlan.lifetime => 'Ga verder met Levenslang',
          };

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header rail - `border-b border-rule`.
            Container(
              height: 56,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.rule)),
              ),
              padding: const EdgeInsets.only(left: 8, right: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppTheme.inkSoft,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('PREMIUM', style: AppTheme.overline),
                ],
              ),
            ),
            // `<section id="premium" class="bg-ink">` - the site's inverted
            // premium panel, reproduced 1:1.
            const _PremiumInkPanel(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    eyebrow: 'Premium',
                    title:
                        _triggerHeadlines[widget.trigger] ?? 'Kies je plan',
                    description: _triggerLeads[widget.trigger],
                  ),
                  const SizedBox(height: 24),
                  RuleGrid(
                    children: [
                      // Yearly leads: it is the rung that catches the player
                      // who is convinced but not ready to commit for life.
                      _PlanRow(
                        index: '01',
                        title: 'Jaarlijks',
                        subtitle: yearlyPerMonth == null
                            ? 'Laagste prijs per maand'
                            : 'Dat is $yearlyPerMonth per maand',
                        price: yearlyPrice,
                        billingLabel: 'per jaar',
                        badge: savings == null
                            ? 'Aanbevolen'
                            : 'Bespaar $savings%',
                        selected: _selectedPlan == _PremiumPlan.yearly,
                        onTap: () =>
                            setState(() => _selectedPlan = _PremiumPlan.yearly),
                      ),
                      _PlanRow(
                        index: '02',
                        title: 'Maandelijks',
                        subtitle: 'Flexibel opzegbaar, volledige toegang',
                        price: monthlyPrice,
                        billingLabel: 'per maand',
                        selected: _selectedPlan == _PremiumPlan.monthly,
                        onTap: () => setState(
                          () => _selectedPlan = _PremiumPlan.monthly,
                        ),
                      ),
                      _PlanRow(
                        index: '03',
                        title: 'Levenslang',
                        subtitle: 'Eenmalig betalen, altijd premium',
                        price: lifetimePrice,
                        billingLabel: 'eenmalig',
                        selected: _selectedPlan == _PremiumPlan.lifetime,
                        onTap: () => setState(
                          () => _selectedPlan = _PremiumPlan.lifetime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SiteButton(
                    loading: isLoading,
                    label: ctaLabel,
                    trailingIcon: isLoading ? null : Icons.arrow_forward,
                    onPressed: isLoading ? null : _onPurchase,
                  ),
                  if (hasTrial) ...[
                    const SizedBox(height: 10),
                    Text(
                      _selectedPlan == _PremiumPlan.yearly
                          ? 'Daarna $yearlyPrice per jaar. Zeg op wanneer je wilt.'
                          : 'Daarna $monthlyPrice per maand. Zeg op wanneer je wilt.',
                      textAlign: TextAlign.center,
                      style: AppTheme.caption,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // A leader buying for thirty people is not served by a
                  // per-person plan, and is the most valuable person to reach
                  // on this screen.
                  SiteOutlineButton(
                    label: 'Ik heb een groepscode',
                    onPressed: isLoading
                        ? null
                        : () => context.push('/group-license'),
                  ),
                  const SizedBox(height: 12),
                  SiteOutlineButton(
                    label: 'Aankopen herstellen',
                    onPressed: isLoading
                        ? null
                        : () => ref
                              .read(premiumControllerProvider.notifier)
                              .restorePurchases(),
                  ),
                  const SizedBox(height: 28),
                  const RuleLine(),
                  const SizedBox(height: 20),
                  const Text('VOORWAARDEN', style: AppTheme.overline),
                  const SizedBox(height: 12),
                  const Text(
                    'Gebruik "Aankopen herstellen" als je al eerder Premium '
                    'hebt gekocht met hetzelfde account. De app controleert dan '
                    'je eerdere aankopen en activeert Premium opnieuw.',
                    style: AppTheme.caption,
                  ),
                  const SizedBox(height: 10),
                  Text(billingInfoText, style: AppTheme.caption),
                  if (trialInfoText != null) ...[
                    const SizedBox(height: 10),
                    Text(trialInfoText, style: AppTheme.caption),
                  ],
                  const SizedBox(height: 10),
                  Text(selectedPlanDetails, style: AppTheme.caption),
                  const SizedBox(height: 20),
                  const RuleLine(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _LegalLink(
                        label: 'Privacybeleid',
                        onTap: () => _openLegalUrl(AppConfig.privacyPolicyUrl),
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: AppTheme.rule,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      _LegalLink(
                        label: 'Gebruiksvoorwaarden (EULA)',
                        onTap: () => _openLegalUrl(AppConfig.termsOfUseUrl),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pull a number out of a localized store price like "€39,99" or "US$39.99".
///
/// The store decides the currency and the formatting, so anything that does
/// not parse simply means the derived claims below are omitted rather than
/// printed wrong.
double? _parsePrice(String label) {
  final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(label);
  if (match == null) return null;
  final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  return (value != null && value > 0) ? value : null;
}

/// What the yearly plan saves against twelve monthly payments, or null when
/// either price is unreadable or the year plan is not actually cheaper.
int? _savingsPercent(String monthlyLabel, String yearlyLabel) {
  final monthly = _parsePrice(monthlyLabel);
  final yearly = _parsePrice(yearlyLabel);
  if (monthly == null || yearly == null) return null;

  final twelveMonths = monthly * 12;
  if (yearly >= twelveMonths) return null;

  return (((twelveMonths - yearly) / twelveMonths) * 100).round();
}

/// Monthly equivalent of a yearly price, formatted in the Dutch convention.
String? _perMonthLabel(String yearlyLabel) {
  final yearly = _parsePrice(yearlyLabel);
  if (yearly == null) return null;

  final perMonth = (yearly / 12).toStringAsFixed(2).replaceAll('.', ',');
  return '€$perMonth';
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
      ),
    );
  }
}

/// The site's premium block:
///
/// ```html
/// <section id="premium" class="bg-ink">
///   <span class="eyebrow text-ink-inverted/70">Premium</span>
///   <h2 class="font-display text-[26px] leading-[1.12] tracking-[-0.025em]
///              text-ink-inverted">…</h2>
///   <p class="text-[15px] text-ink-inverted/70">…</p>
///   <ul class="border-t border-ink-inverted/15 pt-6">…</ul>
/// </section>
/// ```
class _PremiumInkPanel extends StatelessWidget {
  const _PremiumInkPanel();

  static const List<String> _benefits = [
    'Onbeperkt rooms hosten en tot 20 spelers samen spelen',
    'Uitleg en bijbelverwijzing bij elke vraag, ook na de game',
    'Voortgangsinzichten per boek, streakbescherming en alle premium quizzen',
    'Toegang tot nieuwe seizoenspakketten en thema-quizzen',
  ];

  @override
  Widget build(BuildContext context) {
    const inverted = AppTheme.inkInverted;

    return Container(
      width: double.infinity,
      color: AppTheme.ink,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 1,
                color: inverted.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 10),
              Text(
                'PREMIUM',
                style: AppTheme.eyebrow.copyWith(
                  color: inverted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Speel onbeperkt samen - en verdiep je kennis bij elke vraag.',
            style: TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 26,
              fontWeight: FontWeight.w400,
              height: 1.12,
              letterSpacing: -0.65,
              color: inverted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Met Premium host je multiplayer-rooms tot 20 spelers, krijg je '
            'uitleg en bijbelverwijzingen bij elke vraag, en volg je je '
            'voortgang per boek.',
            style: AppTheme.bodyLead.copyWith(
              color: inverted.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 28),
          Container(height: 1, color: inverted.withValues(alpha: 0.15)),
          const SizedBox(height: 24),
          ..._benefits.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: inverted.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTheme.bodyMuted.copyWith(
                        color: inverted.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plan row inside the hairline grid. Selected state uses a solid ink radio
/// mark - the site never tints a selected row.
class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.billingLabel,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String index;
  final String title;
  final String subtitle;
  final String price;
  final String billingLabel;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.paperSunken : AppTheme.paperRaised,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppTheme.paperSunken,
        splashColor: AppTheme.paperSunken,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  index,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFontName,
                    fontSize: 14,
                    color: selected ? AppTheme.lapis : AppTheme.inkMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.displayBase,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 10),
                          SiteBadge.lapis(badge!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: AppTheme.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: AppTheme.statNumber.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 5),
                  Text(billingLabel.toUpperCase(), style: AppTheme.overline),
                ],
              ),
              const SizedBox(width: 14),
              // Selection mark: square, hairline - matching the rank badge.
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.ink : AppTheme.paperRaised,
                  border: Border.all(
                    color: selected ? AppTheme.ink : AppTheme.ruleStrong,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: AppTheme.inkInverted,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
