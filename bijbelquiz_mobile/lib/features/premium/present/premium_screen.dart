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
import '../domain/plan_pricing.dart';
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

    final savings = yearlySavingsPercent(monthlyPrice, yearlyPrice);
    final yearlyPerMonth = monthlyEquivalentOfYearly(yearlyPrice);

    // Every plan is also quoted per week. Three billing rhythms cannot be
    // weighed against each other in their own periods, and the week is the
    // unit a buyer already prices small things in.
    final yearlyPerWeek = pricePerWeek(yearlyPrice, months: 12);
    final monthlyPerWeek = pricePerWeek(monthlyPrice, months: 1);
    final lifetimePerWeek = lifetimePricePerWeek(lifetimePrice);

    final isSubscription = _selectedPlan != _PremiumPlan.lifetime;

    final selectedTitle = switch (_selectedPlan) {
      _PremiumPlan.yearly => 'Jaarlijks',
      _PremiumPlan.monthly => 'Maandelijks',
      _PremiumPlan.lifetime => 'Levenslang',
    };
    final selectedPrice = switch (_selectedPlan) {
      _PremiumPlan.yearly => yearlyPrice,
      _PremiumPlan.monthly => monthlyPrice,
      _PremiumPlan.lifetime => lifetimePrice,
    };
    final selectedBilling = switch (_selectedPlan) {
      _PremiumPlan.yearly => 'per jaar',
      _PremiumPlan.monthly => 'per maand',
      _PremiumPlan.lifetime => 'eenmalig',
    };
    final selectedPerWeek = switch (_selectedPlan) {
      _PremiumPlan.yearly => yearlyPerWeek,
      _PremiumPlan.monthly => monthlyPerWeek,
      _PremiumPlan.lifetime => lifetimePerWeek,
    };

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    eyebrow: 'Premium',
                    title: _triggerHeadlines[widget.trigger] ?? 'Kies je plan',
                    description: _triggerLeads[widget.trigger],
                  ),
                  const SizedBox(height: 24),
                  // The saving is the most persuasive number on the screen, so
                  // it is said out loud once rather than only as a chip on one
                  // row.
                  if (savings != null) ...[
                    _SavingsBanner(
                      savings: savings,
                      yearlyPrice: yearlyPrice,
                      monthlyPrice: monthlyPrice,
                      yearlyPerWeek: yearlyPerWeek,
                    ),
                    const SizedBox(height: 20),
                  ],
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
                        perWeek: yearlyPerWeek,
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
                        perWeek: monthlyPerWeek,
                        selected: _selectedPlan == _PremiumPlan.monthly,
                        onTap: () => setState(
                          () => _selectedPlan = _PremiumPlan.monthly,
                        ),
                      ),
                      _PlanRow(
                        index: '03',
                        title: 'Levenslang',
                        subtitle: lifetimePerWeek == null
                            ? 'Eenmalig betalen, altijd premium'
                            : 'Eenmalig betalen - per week gerekend over '
                                  '$lifetimeHorizonYears jaar',
                        price: lifetimePrice,
                        billingLabel: 'eenmalig',
                        perWeek: lifetimePerWeek,
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
                  const SizedBox(height: 24),
                  // What is about to be bought, not a second copy of the
                  // promise list above: the number, when it is taken, and how
                  // to stop it.
                  _OrderSummary(
                    planTitle: selectedTitle,
                    price: selectedPrice,
                    billingLabel: selectedBilling,
                    perWeek: selectedPerWeek,
                    isSubscription: isSubscription,
                    trialLabel: hasTrial ? trial.label : null,
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
    this.perWeek,
    this.badge,
  });

  final String index;
  final String title;
  final String subtitle;
  final String price;
  final String billingLabel;
  final bool selected;
  final VoidCallback onTap;

  /// Per-week equivalent, when the store price could be read. Null falls back
  /// to quoting the billed amount alone rather than printing a guess.
  final String? perWeek;
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
                    // Wraps rather than truncates: a badge is the reason to
                    // pick this row, so it drops to its own line before the
                    // plan name loses characters.
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(title, style: AppTheme.displayBase),
                        if (badge != null) SiteBadge.lapis(badge!),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: AppTheme.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // The per-week figure leads and the amount actually charged sits
              // under it - never the other way around, and never without it.
              // Bounded so the price column cannot squeeze the plan name off
              // the row on a narrow phone.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 116),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: perWeek == null
                      ? [
                          Text(
                            price,
                            style: AppTheme.statNumber.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            billingLabel.toUpperCase(),
                            style: AppTheme.overline,
                          ),
                        ]
                      : [
                          Text(
                            perWeek!,
                            style: AppTheme.statNumber.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'PER WEEK',
                            textAlign: TextAlign.right,
                            style: AppTheme.overline.copyWith(
                              color: AppTheme.lapis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$price $billingLabel',
                            textAlign: TextAlign.right,
                            style: AppTheme.caption,
                          ),
                        ],
                ),
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

/// The year plan's saving, said in a full sentence above the ladder.
class _SavingsBanner extends StatelessWidget {
  const _SavingsBanner({
    required this.savings,
    required this.yearlyPrice,
    required this.monthlyPrice,
    required this.yearlyPerWeek,
  });

  final int savings;
  final String yearlyPrice;
  final String monthlyPrice;
  final String? yearlyPerWeek;

  @override
  Widget build(BuildContext context) {
    final perWeek = yearlyPerWeek;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.lapisTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.lapis.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiteBadge.lapis('Bespaar $savings%'),
          const SizedBox(height: 10),
          Text(
            'Het jaarplan kost $yearlyPrice in plaats van $monthlyPrice per '
            'maand'
            '${perWeek == null ? '' : ' - $perWeek per week'}.',
            style: AppTheme.bodyMuted.copyWith(color: AppTheme.ink),
          ),
        ],
      ),
    );
  }
}

/// What the selected plan actually costs, when it is taken, and how it ends.
///
/// The ladder sells; this settles. It repeats no benefit - by the time a buyer
/// reads it they have decided, and what they need is the number and the exit.
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.planTitle,
    required this.price,
    required this.billingLabel,
    required this.perWeek,
    required this.isSubscription,
    required this.trialLabel,
  });

  final String planTitle;
  final String price;
  final String billingLabel;
  final String? perWeek;
  final bool isSubscription;

  /// "14 dagen gratis" when the store offers an introductory free period on
  /// the selected plan; null means the first charge is today.
  final String? trialLabel;

  @override
  Widget build(BuildContext context) {
    final trial = trialLabel;
    final week = perWeek;

    return AppCard(
      borderColor: AppTheme.lapis.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('JOUW KEUZE', style: AppTheme.overline),
          const SizedBox(height: 10),
          Text(
            'Premium ${planTitle.toLowerCase()}',
            style: AppTheme.displayBase,
          ),
          const SizedBox(height: 16),
          const RuleLine(),
          const SizedBox(height: 14),
          if (week != null) ...[
            _SummaryRow(label: 'Per week', value: week, emphasised: true),
            const SizedBox(height: 12),
          ],
          _SummaryRow(
            label: trial == null ? 'Je betaalt' : 'Na de proefperiode',
            value: '$price $billingLabel',
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Vandaag', value: trial ?? price),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Verlenging',
            value: isSubscription ? 'Automatisch, $billingLabel' : 'Geen',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Opzeggen',
            value: isSubscription ? 'Wanneer je wilt' : 'Niet nodig',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: AppTheme.caption)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: emphasised
                ? AppTheme.displayBase
                : AppTheme.bodyStrong.copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
