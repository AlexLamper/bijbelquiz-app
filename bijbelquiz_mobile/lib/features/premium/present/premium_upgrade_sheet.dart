import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../profile/present/profile_provider.dart';
import '../data/purchase_service.dart';
import 'premium_controller.dart';

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
    backgroundColor: AppTheme.paperRaised,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (_) => _PremiumUpgradeSheet(
      trigger: trigger,
      title: title,
      message: message,
    ),
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

    final trial = PurchaseService.trialOffer(
      _plan == _SheetPlan.yearly ? yearlyPackage : monthlyPackage,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: AppTheme.ruleStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('PREMIUM', style: AppTheme.overline),
            const SizedBox(height: 10),
            Text(widget.title, style: AppTheme.displaySmall),
            const SizedBox(height: 8),
            Text(widget.message, style: AppTheme.bodyMuted),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SheetPlanTile(
                    label: 'Per jaar',
                    price: yearlyPrice,
                    caption: 'Laagste maandprijs',
                    selected: _plan == _SheetPlan.yearly,
                    onTap: () => setState(() => _plan = _SheetPlan.yearly),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetPlanTile(
                    label: 'Per maand',
                    price: monthlyPrice,
                    caption: 'Flexibel opzegbaar',
                    selected: _plan == _SheetPlan.monthly,
                    onTap: () => setState(() => _plan = _SheetPlan.monthly),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SiteButton(
              loading: isLoading,
              label: isLoading
                  ? 'Verwerken…'
                  : trial != null
                  ? 'Start ${trial.label}'
                  : 'Word Premium',
              trailingIcon: isLoading ? null : Icons.arrow_forward,
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
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop(false);
                      context.push('/premium?reden=${widget.trigger}');
                    },
              style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
              child: const Text('Alle plannen bekijken'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetPlanTile extends StatelessWidget {
  const _SheetPlanTile({
    required this.label,
    required this.price,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String price;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.lapisTint : AppTheme.paper,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: selected ? AppTheme.lapis : AppTheme.rule,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: AppTheme.overline),
              const SizedBox(height: 8),
              Text(price, style: AppTheme.displaySmall),
              const SizedBox(height: 4),
              Text(caption, style: AppTheme.caption),
            ],
          ),
        ),
      ),
    );
  }
}
