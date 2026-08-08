import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/purchase_service.dart';
import 'premium_controller.dart';

enum _PremiumPlan { monthly, lifetime }

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  _PremiumPlan _selectedPlan = _PremiumPlan.monthly;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aankopen hersteld.')));
    }
  }

  void _onPurchase() {
    final notifier = ref.read(premiumControllerProvider.notifier);
    if (_selectedPlan == _PremiumPlan.monthly) {
      notifier.purchaseMonthly();
    } else {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon link niet openen. Probeer opnieuw.')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.destructive,
          ),
        );
        ref.read(premiumControllerProvider.notifier).clearStatus();
      }
    });

    final premiumState = ref.watch(premiumControllerProvider);
    final isLoading = premiumState.status == PurchaseStatus.loading;

    final service = ref.read(purchaseServiceProvider);
    final monthlyPackage = service.findMonthlyPackage(premiumState.packages);
    final lifetimePackage = service.findLifetimePackage(premiumState.packages);

    final monthlyPrice = monthlyPackage?.storeProduct.priceString ?? '€5,99';
    final lifetimePrice = lifetimePackage?.storeProduct.priceString ?? '€74,99';
    final isMonthlyPlan = _selectedPlan == _PremiumPlan.monthly;
    final selectedPlanDetails = isMonthlyPlan
        ? 'Abonnementdetails: Bijbelquiz Premium Maandelijks - $monthlyPrice per maand.'
        : 'Abonnementdetails: Bijbelquiz Premium Levenslang - $lifetimePrice eenmalig.';
    final billingInfoText = isMonthlyPlan
        ? 'Abonnementen worden via je App Store-account beheerd en verlengen automatisch, tenzij je minimaal 24 uur voor het einde van de lopende periode opzegt.'
        : 'Levenslang is een eenmalige aankoop via je App Store-account en verlengt niet automatisch.';

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header rail — `border-b border-rule`.
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
            // `<section id="premium" class="bg-ink">` — the site's inverted
            // premium panel, reproduced 1:1.
            const _PremiumInkPanel(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    eyebrow: 'Abonnement',
                    title: 'Kies je plan',
                    description:
                        'Beide plannen geven volledige toegang tot alle '
                        'premium functies.',
                  ),
                  const SizedBox(height: 24),
                  RuleGrid(
                    children: [
                      _PlanRow(
                        index: '01',
                        title: 'Maandelijks',
                        subtitle: 'Flexibel opzegbaar, volledige toegang',
                        price: monthlyPrice,
                        billingLabel: 'per maand',
                        badge: 'Aanbevolen',
                        selected: _selectedPlan == _PremiumPlan.monthly,
                        onTap: () => setState(
                          () => _selectedPlan = _PremiumPlan.monthly,
                        ),
                      ),
                      _PlanRow(
                        index: '02',
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
                    label: isLoading
                        ? 'Verwerken…'
                        : 'Ga verder met ${isMonthlyPlan ? 'Maandelijks' : 'Levenslang'}',
                    trailingIcon: isLoading ? null : Icons.arrow_forward,
                    onPressed: isLoading ? null : _onPurchase,
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
            'Speel onbeperkt samen — en verdiep je kennis bij elke vraag.',
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
/// mark — the site never tints a selected row.
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
              // Selection mark: square, hairline — matching the rank badge.
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
