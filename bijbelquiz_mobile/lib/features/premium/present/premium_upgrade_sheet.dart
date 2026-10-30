import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import '../data/purchase_service.dart';
import '../domain/plan_pricing.dart';
import 'premium_controller.dart';
import 'premium_status_notices.dart';
import 'widgets/paywall_parts.dart';

/// A compact paywall that opens over whatever the player was doing.
///
/// Exists for one moment in particular: a host presses start with a room full
/// of people and finds their free games are gone. Sending them to a full
/// screen paywall - and then back through the lobby list to find their room
/// again - loses the sale and the evening. This buys and returns in place.
///
/// Returns true when the player came out of it with Premium.
Future<bool> showPremiumUpgradeSheet(
  BuildContext context, {
  required String trigger,
  required String title,
  required String message,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.paper,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        _PremiumUpgradeSheet(trigger: trigger, title: title, message: message),
  );

  return result ?? false;
}

class _PremiumUpgradeSheet extends ConsumerStatefulWidget {
  const _PremiumUpgradeSheet({
    required this.trigger,
    required this.title,
    required this.message,
  });

  final String trigger;
  final String title;
  final String message;

  @override
  ConsumerState<_PremiumUpgradeSheet> createState() =>
      _PremiumUpgradeSheetState();
}

enum _SheetPlan { yearly, monthly }

class _PremiumUpgradeSheetState extends ConsumerState<_PremiumUpgradeSheet> {
  _SheetPlan _plan = _SheetPlan.yearly;
  DateTime? _shownAt;
  bool _startedPurchase = false;

  /// Held rather than read from `ref` in [dispose]: reading a provider during
  /// teardown throws, and the dismissal is the event that matters most here.
  late final Analytics _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = ref.read(analyticsProvider);
    _shownAt = DateTime.now();
    _analytics.track(
      AnalyticsEvents.paywallShown,
      props: {'trigger': widget.trigger, 'surface': 'upgrade_sheet'},
    );
  }

  @override
  void dispose() {
    if (!_startedPurchase) {
      final shownAt = _shownAt;
      _analytics.track(
        AnalyticsEvents.paywallDismissed,
        props: {
          'trigger': widget.trigger,
          'surface': 'upgrade_sheet',
          'secondsVisible': shownAt == null
              ? 0
              : DateTime.now().difference(shownAt).inSeconds,
        },
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PremiumState>(premiumControllerProvider, (previous, next) {
      if (!mounted || next.status == previous?.status) return;
      if (next.status == PurchaseStatus.error ||
          next.status == PurchaseStatus.pending ||
          next.status == PurchaseStatus.needsAccount) {
        setState(() => _startedPurchase = false);
      }
      showPremiumOutcome(
        context,
        ref,
        next,
        onPremium: (_) {
          // Premium changes what the lobby is allowed to do.
          ref.invalidate(profileProvider);
          Navigator.of(context).pop(true);
        },
      );
    });

    final premiumState = ref.watch(premiumControllerProvider);
    final isLoading = premiumState.isBusy;
    final offersLoading = premiumState.offersStatus == OffersStatus.loading;

    final monthlyOffer = premiumState.offerFor(PremiumPlan.monthly);
    final yearlyOffer = premiumState.offerFor(PremiumPlan.yearly);

    // The store's price or nothing: never a made-up amount.
    final monthlyPrice = monthlyOffer?.priceString ?? '-';
    final yearlyPrice = yearlyOffer?.priceString ?? '-';

    final yearlyTrial = yearlyOffer?.trial;
    final monthlyTrial = monthlyOffer?.trial;
    final trial = _plan == _SheetPlan.yearly ? yearlyTrial : monthlyTrial;
    final selectedOffer = _plan == _SheetPlan.yearly
        ? yearlyOffer
        : monthlyOffer;

    final savings = yearlySavingsPercent(monthlyPrice, yearlyPrice);
    // Both plans are also quoted per week, as a highlight under the billed
    // price (which the stores require to stay the most prominent number).
    final yearlyPerWeek = pricePerWeek(yearlyPrice, months: 12);
    final monthlyPerWeek = pricePerWeek(monthlyPrice, months: 1);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.ruleStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 16),
            const PaywallBenefits(),
            // Room for the badge on the top edge of the yearly card.
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PaywallPlanCard(
                    title: 'Jaarlijks',
                    price: yearlyPrice,
                    period: 'per jaar',
                    weekly: yearlyPerWeek,
                    badge:
                        yearlyTrial?.label ??
                        (savings == null ? null : 'Bespaar $savings%'),
                    selected: _plan == _SheetPlan.yearly,
                    onTap: isLoading
                        ? null
                        : () => setState(() => _plan = _SheetPlan.yearly),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PaywallPlanCard(
                    title: 'Maandelijks',
                    price: monthlyPrice,
                    period: 'per maand',
                    weekly: monthlyPerWeek,
                    note: monthlyTrial?.label ?? 'Geen proefperiode',
                    selected: _plan == _SheetPlan.monthly,
                    onTap: isLoading
                        ? null
                        : () => setState(() => _plan = _SheetPlan.monthly),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BqButton(
              label: selectedOffer == null && !offersLoading
                  ? 'Prijzen opnieuw laden'
                  : paywallCtaLabel(trial),
              height: 56,
              fontSize: 17,
              radius: 14,
              loading: isLoading || offersLoading,
              onPressed: isLoading || offersLoading
                  ? null
                  : selectedOffer == null
                  ? () => ref
                        .read(premiumControllerProvider.notifier)
                        .loadOffers()
                  : () {
                      setState(() => _startedPurchase = true);
                      final notifier = ref.read(
                        premiumControllerProvider.notifier,
                      );
                      if (_plan == _SheetPlan.yearly) {
                        notifier.purchaseYearly();
                      } else {
                        notifier.purchaseMonthly();
                      }
                    },
            ),
            const SizedBox(height: 10),
            PaywallReassurance(
              paywallReassuranceText(trial: trial, isSubscription: true),
            ),
            const SizedBox(height: 4),
            Center(
              child: PaywallLink(
                label: 'Alle plannen bekijken',
                onTap: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop(false);
                        context.push('/premium?reden=${widget.trigger}');
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
