import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/app_notice.dart';
import 'premium_controller.dart';

/// What every surface that can buy or restore (paywall, upgrade sheet,
/// Instellingen) shows for a finished purchase or restore. Clears the status
/// afterwards, so each outcome is shown once.
///
/// [onPremium] runs when Premium is on (bought, restored or already there);
/// the paywall uses it to step aside. Returns nothing: the notices are the
/// whole effect.
void showPremiumOutcome(
  BuildContext context,
  WidgetRef ref,
  PremiumState next, {
  required void Function(PremiumAction? action) onPremium,
}) {
  final notifier = ref.read(premiumControllerProvider.notifier);
  switch (next.status) {
    case PurchaseStatus.idle:
    case PurchaseStatus.loading:
      return;
    case PurchaseStatus.success:
      notifier.clearStatus();
      onPremium(next.action);
    case PurchaseStatus.alreadyPremium:
      notifier.clearStatus();
      AppNotice.success(
        context,
        'Je hebt al Premium op dit account. Er is niets afgeschreven.',
        title: 'Premium staat aan',
      );
      onPremium(next.action);
    case PurchaseStatus.needsAccount:
      notifier.clearStatus();
      AppNotice.info(
        context,
        next.action == PremiumAction.restore
            ? 'Log in met je account, dan zetten we je aankopen terug op dat '
                  'account.'
            : 'Maak eerst een gratis account of log in, dan hoort Premium bij '
                  'jou - in de app en op de website.',
        title: 'Account nodig',
      );
      context.push('/login');
    case PurchaseStatus.pending:
      notifier.clearStatus();
      AppNotice.info(context, next.message ?? '', title: 'Even geduld');
    case PurchaseStatus.nothingToRestore:
      notifier.clearStatus();
      AppNotice.info(
        context,
        next.message ?? '',
        title: 'Niets om te herstellen',
      );
    case PurchaseStatus.error:
      notifier.clearStatus();
      if (next.message != null) AppNotice.error(context, next.message);
  }
}
