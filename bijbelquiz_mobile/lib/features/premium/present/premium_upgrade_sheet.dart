import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import '../data/purchase_service.dart';
import '../domain/plan_pricing.dart';
import 'premium_controller.dart';
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
      if (!mounted) return;

      if (next.status == PurchaseStatus.success) {
        ref.read(premiumControllerProvider.notifier).clearStatus();
        // Premium changes what the lobby is allowed to do, so both caches go.
        ref.invalidate(profileProvider);
        Navigator.of(context).pop(next.isPremium);
        return;
      }

      if (next.status == PurchaseStatus.error && next.errorMessage != null) {
        AppNotice.error(context, next.errorMessage);
        ref.read(premiumControllerProvider.notifier).clearStatus();
        setState(() => _startedPurchase = false);
      }
    });

    final premiumState = ref.watch(premiumControllerProvider);
    final isLoading = premiumState.status == PurchaseStatus.loading;

    final service = ref.read(purchaseServiceProvider);
    final monthlyPackage = service.findMonthlyPackage(premiumState.packages);
    final yearlyPackage = service.findYearlyPackage(premiumState.packages);

    final monthlyPrice = monthlyPackage?.storeProduct.priceString ?? '€5,99';
    final yearlyPrice = yearlyPackage?.storeProduct.priceString ?? '€39,99';

    final yearlyTrial = PurchaseService.trialOffer(yearlyPackage);
    final monthlyTrial = PurchaseService.trialOffer(monthlyPackage);
    final trial = _plan == _SheetPlan.yearly ? yearlyTrial : monthlyTrial;

    final savings = yearlySavingsPercent(monthlyPrice, yearlyPrice);
    final yearlyPerMonth = monthlyEquivalentOfYearly(yearlyPrice);

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
                    note: yearlyPerMonth == null
                        ? null
                        : '= $yearlyPerMonth per maand',
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
              label: paywallCtaLabel(trial),
              height: 56,
              fontSize: 17,
              radius: 14,
              loading: isLoading,
              onPressed: isLoading
                  ? null
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
