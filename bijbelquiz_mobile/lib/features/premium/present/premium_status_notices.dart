import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/app_notice.dart';
import 'premium_controller.dart';
import '../../../l10n/tr.dart';

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
        tr.alreadyPremium,
        title: tr.premiumOn,
      );
      onPremium(next.action);
    case PurchaseStatus.needsAccount:
      notifier.clearStatus();
      AppNotice.info(
        context,
        next.action == PremiumAction.restore
            ? tr.restoreSignIn
            : tr.needAccountForPremium,
        title: tr.accountNeeded,
      );
      context.push('/login');
    case PurchaseStatus.pending:
      notifier.clearStatus();
      AppNotice.info(context, next.message ?? '', title: tr.pleaseWait);
    case PurchaseStatus.nothingToRestore:
      notifier.clearStatus();
      AppNotice.info(
        context,
        next.message ?? '',
        title: tr.nothingToRestore,
      );
    case PurchaseStatus.error:
      notifier.clearStatus();
      if (next.message != null) AppNotice.error(context, next.message);
  }
}
