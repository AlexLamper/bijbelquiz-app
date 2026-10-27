import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import '../../quiz/data/free_quiz_limit.dart';
import '../data/purchase_service.dart';
import '../domain/plan_pricing.dart';
import 'premium_controller.dart';
import 'premium_status_notices.dart';
import 'widgets/paywall_parts.dart';

/// Shown in place of a store price until the store has answered. Never a
/// made-up amount: the store owns the price, in the buyer's own currency.
const String _pricePending = '-';

const String _defaultTitle = 'Speel onbeperkt\nmet Premium';

/// Title naming what the player was just stopped from doing.
///
/// A paywall that opens on "Premium" sells a product; one that opens on what
/// the player wanted to do answers the question they actually have.
const Map<String, String> _triggerTitles = {
  PaywallTrigger.freeLimit: 'Je $kFreeQuizLimit gratis quizzen\nzijn gespeeld',
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
  PremiumPlan _selectedPlan = PremiumPlan.yearly;

  DateTime? _shownAt;
  bool _startedPurchase = false;

  /// Premium was already active when the screen opened. Nothing to sell, so
  /// the screen steps aside instead of showing a payment page.
  bool _alreadyPremium = false;

  /// The screen is on its way out; guards against leaving twice.
  bool _leaving = false;

  /// A purchase or restore started here is showing its own outcome, so the
  /// "Premium arrived, step aside" rule waits for it.
  bool _inFlow = false;

  /// Held rather than read from `ref` in [dispose]: reading a provider while
  /// the scope is being torn down throws, and the dismissal event has to
  /// survive exactly that teardown.
  late final Analytics _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = ref.read(analyticsProvider);
    if (hasPremiumAccess(ref)) {
      _alreadyPremium = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _leave();
      });
      return;
    }
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
    if (!_startedPurchase && !_alreadyPremium) {
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
    if (_leaving || !mounted) return;
    _leaving = true;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _showWelcome(PremiumAction? action) {
    if (!mounted) return;
    final restored = action == PremiumAction.restore;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(restored ? 'Premium hersteld' : 'Welkom bij Premium'),
        content: Text(
          restored
              ? 'Je Premium staat weer aan op dit account.'
              : 'Je hebt nu volledige toegang tot alle premium functies, in '
                    'de app en op de website. Veel plezier!',
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
  }

  void _onPremium(PremiumAction? action) {
    if (action == null) {
      _leave();
    } else {
      _showWelcome(action);
    }
  }

  void _onPurchase() {
    _startedPurchase = true;
    _inFlow = true;
    // The controller checks the session and whether the account already has
    // Premium (website, group, lifetime) before the store sheet opens.
    ref.read(premiumControllerProvider.notifier).purchase(_selectedPlan);
  }

  void _onRestore() {
    _startedPurchase = true;
    _inFlow = true;
    ref.read(premiumControllerProvider.notifier).restorePurchases();
  }

  void _select(PremiumPlan plan) => setState(() => _selectedPlan = plan);

  @override
  Widget build(BuildContext context) {
    if (_alreadyPremium) {
      return const Scaffold(backgroundColor: AppTheme.paper);
    }

    ref.listen<PremiumState>(premiumControllerProvider, (prev, next) {
      if (!mounted || next.status == prev?.status) return;
      // The flow ended without Premium (cancelled, failed, pending, needs an
      // account, nothing to restore). After success the welcome dialog owns
      // the exit, so the flag stays.
      final cancelled =
          next.status == PurchaseStatus.idle &&
          prev?.status == PurchaseStatus.loading;
      if (cancelled ||
          next.status == PurchaseStatus.error ||
          next.status == PurchaseStatus.pending ||
          next.status == PurchaseStatus.needsAccount ||
          next.status == PurchaseStatus.nothingToRestore) {
        _inFlow = false;
      }
      showPremiumOutcome(
        context,
        ref,
        next,
        onPremium: (action) => _onPremium(
          next.status == PurchaseStatus.alreadyPremium ? null : action,
        ),
      );
    });

    // Premium can arrive while the wall is open - the profile loading late,
    // a purchase on the website, an Ask to Buy approval. Nothing is left to
    // sell then, so step aside (unless a purchase flow is showing its own
    // outcome).
    final profilePremium =
        ref.watch(profileProvider).asData?.value.isPremium ?? false;
    final premiumState = ref.watch(premiumControllerProvider);
    if ((profilePremium || premiumState.isPremium) && !_inFlow && !_leaving) {
      _alreadyPremium = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _leave());
    }

    final isLoading = premiumState.isBusy;
    final offersLoading = premiumState.offersStatus == OffersStatus.loading;
    final offersUnavailable =
        premiumState.offersStatus == OffersStatus.unavailable;

    final monthlyOffer = premiumState.offerFor(PremiumPlan.monthly);
    final yearlyOffer = premiumState.offerFor(PremiumPlan.yearly);
    final lifetimeOffer = premiumState.offerFor(PremiumPlan.lifetime);

    final monthlyPrice = monthlyOffer?.priceString ?? _pricePending;
    final yearlyPrice = yearlyOffer?.priceString ?? _pricePending;
    final lifetimePrice = lifetimeOffer?.priceString ?? _pricePending;

    // Read from the store, never assumed, and only when this buyer is still
    // eligible: promising a trial the store will not honour is a rejected
    // review and a refund request.
    final yearlyTrial = yearlyOffer?.trial;
    final monthlyTrial = monthlyOffer?.trial;
    final trial = switch (_selectedPlan) {
      PremiumPlan.yearly => yearlyTrial,
      PremiumPlan.monthly => monthlyTrial,
      PremiumPlan.lifetime => null,
    };
    final isSubscription = _selectedPlan.isSubscription;
    final selectedAvailable = premiumState.offerFor(_selectedPlan) != null;

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
                              padding: const EdgeInsets.only(left: 12),
                              onTap: isLoading ? null : _onRestore,
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
                      if (widget.trigger == PaywallTrigger.freeLimit) ...[
                        const SizedBox(height: 6),
                        const Text(
                          'Speel verder met Premium.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 22 / 16,
                            color: AppTheme.inkMuted,
                          ),
                        ),
                      ],
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
                                selected: _selectedPlan == PremiumPlan.yearly,
                                onTap: isLoading
                                    ? null
                                    : () => _select(PremiumPlan.yearly),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PaywallPlanCard(
                                title: 'Maandelijks',
                                price: monthlyPrice,
                                period: 'per maand',
                                note:
                                    monthlyTrial?.label ?? 'Geen proefperiode',
                                selected: _selectedPlan == PremiumPlan.monthly,
                                onTap: isLoading
                                    ? null
                                    : () => _select(PremiumPlan.monthly),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PaywallLifetimeOption(
                        selected: _selectedPlan == PremiumPlan.lifetime,
                        price: lifetimePrice,
                        onTap: isLoading
                            ? null
                            : () => _select(PremiumPlan.lifetime),
                      ),
                      // BqButton keeps 3px above itself for its press travel.
                      SizedBox(
                        height: _selectedPlan == PremiumPlan.lifetime ? 11 : 0,
                      ),
                      BqButton(
                        label: offersUnavailable || !selectedAvailable
                            ? (offersLoading
                                  ? paywallCtaLabel(trial)
                                  : 'Prijzen opnieuw laden')
                            : paywallCtaLabel(trial),
                        height: 56,
                        fontSize: 17,
                        radius: 14,
                        loading: isLoading || offersLoading,
                        onPressed: isLoading || offersLoading
                            ? null
                            : selectedAvailable
                            ? _onPurchase
                            : () => ref
                                  .read(premiumControllerProvider.notifier)
                                  .loadOffers(),
                      ),
                      const SizedBox(height: 10),
                      PaywallReassurance(
                        offersUnavailable ||
                                (!offersLoading && !selectedAvailable)
                            ? 'De ${_storeName()} is nu niet bereikbaar. '
                                  'Controleer je verbinding.'
                            : paywallReassuranceText(
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
                      // Renewal terms quote the store's price, so they wait
                      // for it.
                      if (selectedAvailable)
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
  required PremiumPlan plan,
  required String yearlyPrice,
  required String monthlyPrice,
  required String lifetimePrice,
  required TrialOffer? trial,
}) {
  final store = _storeName();

  if (plan == PremiumPlan.lifetime) {
    return 'Levenslang Premium is een eenmalige aankoop van $lifetimePrice via '
        'je $store-account en verlengt niet automatisch.';
  }

  final details = plan == PremiumPlan.yearly
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

String _storeName() {
  final isApple =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
  return isApple ? 'App Store' : 'Google Play';
}
