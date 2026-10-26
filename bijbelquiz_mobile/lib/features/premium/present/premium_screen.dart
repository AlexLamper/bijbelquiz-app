import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../data/purchase_service.dart';
import '../domain/plan_pricing.dart';
import 'premium_controller.dart';
import 'widgets/paywall_parts.dart';

enum _PremiumPlan { yearly, monthly, lifetime }

const String _defaultTitle = 'Speel onbeperkt\nmet Premium';

/// Title naming what the player was just stopped from doing.
///
/// A paywall that opens on "Premium" sells a product; one that opens on what
/// the player wanted to do answers the question they actually have.
const Map<String, String> _triggerTitles = {
  PaywallTrigger.freeLimit: 'Mooi gespeeld!\nSpeel verder met Premium',
  PaywallTrigger.hostQuotaExhausted: 'Speel onbeperkt\nsamen verder',
  PaywallTrigger.hostQuotaWarning: 'Speel onbeperkt\nsamen verder',
  PaywallTrigger.hostPlayerCap: 'Speel met je\nhele groep',
  PaywallTrigger.explanationLocked: 'Lees bij elke vraag\nwaarom',
  PaywallTrigger.premiumQuizLocked: 'Ontgrendel\nalle quizzen',
  PaywallTrigger.direct: _defaultTitle,
};

/// The full-screen paywall.
///
/// Two variants: the regular one (close button top-left) and the locked one
/// shown after the free quizzes are used up - no close button, and the system
/// back gesture does not dismiss it. Both offer "Herstellen".
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({
    super.key,
    this.trigger = PaywallTrigger.direct,
    this.locked = false,
  });

  /// Which surface sent the player here. Recorded on the funnel event and used
  /// to pick the title.
  final String trigger;

  /// No way out but buying or restoring. Also on whenever [trigger] is
  /// [PaywallTrigger.freeLimit], so `/premium?reden=gratis-limiet` opens the
  /// locked variant without a router change.
  final bool locked;

  bool get isLocked => locked || trigger == PaywallTrigger.freeLimit;

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

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _showSuccess(bool isPremium) {
    if (!mounted) return;
    if (isPremium) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Welkom bij Premium'),
          content: const Text(
            'Je hebt nu volledige toegang tot alle premium functies. Veel plezier!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _leave();
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

  Future<void> _onPurchase() async {
    // A purchase has to land on an account: RevenueCat is linked to the user
    // id at sign-in, and the store webhook grants Premium to that id. Bought
    // signed out, it would hang off an anonymous RevenueCat id that no
    // account can ever be matched to.
    final hasSession = await ref.read(hasSessionProvider.future);
    if (!hasSession) {
      if (!mounted) return;
      AppNotice.info(
        context,
        'Maak eerst een gratis account of log in, dan hoort Premium bij jou.',
        title: 'Account nodig',
      );
      context.push('/login');
      return;
    }

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

  void _select(_PremiumPlan plan) => setState(() => _selectedPlan = plan);

  @override
  Widget build(BuildContext context) {
    ref.listen<PremiumState>(premiumControllerProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == PurchaseStatus.success) {
        _showSuccess(next.isPremium);
        ref.read(premiumControllerProvider.notifier).clearStatus();
      } else if (next.status == PurchaseStatus.error &&
          next.errorMessage != null) {
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
    final yearlyTrial = PurchaseService.trialOffer(yearlyPackage);
    final monthlyTrial = PurchaseService.trialOffer(monthlyPackage);
    final trial = switch (_selectedPlan) {
      _PremiumPlan.yearly => yearlyTrial,
      _PremiumPlan.monthly => monthlyTrial,
      _PremiumPlan.lifetime => null,
    };
    final isSubscription = _selectedPlan != _PremiumPlan.lifetime;

    final savings = yearlySavingsPercent(monthlyPrice, yearlyPrice);
    final yearlyPerMonth = monthlyEquivalentOfYearly(yearlyPrice);

    final locked = widget.isLocked;
    // Once Premium is active the locked wall has done its job.
    final canLeave = !locked || premiumState.isPremium;

    final title = _triggerTitles[widget.trigger] ?? _defaultTitle;

    return PopScope(
      canPop: canLeave,
      child: Scaffold(
        backgroundColor: AppTheme.paper,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            if (!locked) PaywallCloseButton(onTap: _leave),
                            const Spacer(),
                            PaywallLink(
                              label: 'Herstellen',
                              color: AppTheme.inkMuted,
                              onTap: isLoading
                                  ? null
                                  : () => ref
                                        .read(
                                          premiumControllerProvider.notifier,
                                        )
                                        .restorePurchases(),
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTheme.displayFontName,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 33 / 28,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const PaywallPreview(),
                      const SizedBox(height: 14),
                      const PaywallBenefits(),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Room for the badge that sits on the card's top edge.
                      const SizedBox(height: 12),
                      Semantics(
                        label: 'Kies een abonnement',
                        container: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: PaywallPlanCard(
                                title: 'Jaarlijks',
                                price: yearlyPrice,
                                period: 'per jaar',
                                note: yearlyPerMonth == null
                                    ? null
                                    : '= $yearlyPerMonth per maand',
                                badge:
                                    yearlyTrial?.label ??
                                    (savings == null
                                        ? null
                                        : 'Bespaar $savings%'),
                                selected: _selectedPlan == _PremiumPlan.yearly,
                                onTap: isLoading
                                    ? null
                                    : () => _select(_PremiumPlan.yearly),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PaywallPlanCard(
                                title: 'Maandelijks',
                                price: monthlyPrice,
                                period: 'per maand',
                                note: monthlyTrial?.label ?? 'Geen proefperiode',
                                selected:
                                    _selectedPlan == _PremiumPlan.monthly,
                                onTap: isLoading
                                    ? null
                                    : () => _select(_PremiumPlan.monthly),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PaywallLifetimeOption(
                        selected: _selectedPlan == _PremiumPlan.lifetime,
                        price: lifetimePrice,
                        onTap: isLoading
                            ? null
                            : () => _select(_PremiumPlan.lifetime),
                      ),
                      SizedBox(
                        height: _selectedPlan == _PremiumPlan.lifetime ? 14 : 2,
                      ),
                      BqButton(
                        label: paywallCtaLabel(trial),
                        height: 53,
                        fontSize: 17,
                        radius: 14,
                        loading: isLoading,
                        onPressed: isLoading ? null : _onPurchase,
                      ),
                      const SizedBox(height: 10),
                      PaywallReassurance(
                        paywallReassuranceText(
                          trial: trial,
                          isSubscription: isSubscription,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PaywallLink(
                            label: 'Voorwaarden',
                            color: AppTheme.inkMuted,
                            fontSize: 12,
                            link: true,
                            onTap: () => openPaywallUrl(
                              context,
                              AppConfig.termsOfUseUrl,
                            ),
                          ),
                          const SizedBox(width: 2),
                          PaywallLink(
                            label: 'Privacy',
                            color: AppTheme.inkMuted,
                            fontSize: 12,
                            link: true,
                            onTap: () => openPaywallUrl(
                              context,
                              AppConfig.privacyPolicyUrl,
                            ),
                          ),
                          const SizedBox(width: 2),
                          // A leader buying for thirty people is not served by
                          // a per-person plan.
                          PaywallLink(
                            label: 'Groepscode',
                            color: AppTheme.inkMuted,
                            fontSize: 12,
                            onTap: isLoading
                                ? null
                                : () => context.push('/group-license'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _billingTerms(
                          plan: _selectedPlan,
                          yearlyPrice: yearlyPrice,
                          monthlyPrice: monthlyPrice,
                          lifetimePrice: lifetimePrice,
                          trial: trial,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 16 / 11,
                          color: AppTheme.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The store's renewal terms for the chosen plan. Required next to a
/// subscription offer, and kept below the fold so it informs without
/// shouting.
String _billingTerms({
  required _PremiumPlan plan,
  required String yearlyPrice,
  required String monthlyPrice,
  required String lifetimePrice,
  required TrialOffer? trial,
}) {
  final isApple =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
  final store = isApple ? 'App Store' : 'Google Play';

  if (plan == _PremiumPlan.lifetime) {
    return 'Levenslang Premium is een eenmalige aankoop van $lifetimePrice via '
        'je $store-account en verlengt niet automatisch.';
  }

  final details = plan == _PremiumPlan.yearly
      ? 'BijbelQuiz Premium Jaarlijks: $yearlyPrice per jaar.'
      : 'BijbelQuiz Premium Maandelijks: $monthlyPrice per maand.';
  final trialLine = trial == null
      ? ''
      : ' Na een gratis proefperiode van '
            '${trial.label.replaceAll(' gratis', '')} gaat het abonnement in.';

  return '$details$trialLine Het abonnement loopt via je $store-account en '
      'verlengt automatisch, tenzij je minimaal 24 uur voor het einde van de '
      'lopende periode opzegt.';
}
