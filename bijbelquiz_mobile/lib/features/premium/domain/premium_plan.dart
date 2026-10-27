import 'package:purchases_flutter/purchases_flutter.dart'
    show PackageType, PeriodUnit;

/// The three ways to buy Premium. Same plans, same product ids as the store
/// and the server (`src/lib/revenuecat.ts`), which records the plan on each
/// Payment.
enum PremiumPlan { yearly, monthly, lifetime }

// Product ids must match App Store Connect / Google Play exactly. On Google
// Play a subscription arrives as `product:baseplan`; only the product part is
// compared.
const kRcMonthlyProductId = 'bijbelquiz_premium_monthly';
const kRcYearlyProductId = 'bijbelquiz_premium_yearly';
const kRcLifetimeProductId = 'bijbelquiz_premium_lifetime';

// RevenueCat's standard package ids in the `default` offering.
const kRcMonthlyPackageId = '\$rc_monthly';
const kRcYearlyPackageId = '\$rc_annual';
const kRcLifetimePackageId = '\$rc_lifetime';

/// RevenueCat entitlement identifier (RevenueCat dashboard -> Entitlements).
/// The server reads the same id (`REVENUECAT_PREMIUM_ENTITLEMENT_ID`,
/// default `premium`).
const kRcPremiumEntitlement = 'premium';

extension PremiumPlanIds on PremiumPlan {
  String get productId => switch (this) {
    PremiumPlan.yearly => kRcYearlyProductId,
    PremiumPlan.monthly => kRcMonthlyProductId,
    PremiumPlan.lifetime => kRcLifetimeProductId,
  };

  String get packageId => switch (this) {
    PremiumPlan.yearly => kRcYearlyPackageId,
    PremiumPlan.monthly => kRcMonthlyPackageId,
    PremiumPlan.lifetime => kRcLifetimePackageId,
  };

  /// The label the funnel and the server use: `yearly`, `monthly`, `lifetime`.
  String get label => name;

  bool get isSubscription => this != PremiumPlan.lifetime;
}

/// Plan labels the funnel reports on. Must match `planFromProductId` on the
/// server.
String planLabelForProduct(String productId) {
  final id = productId.toLowerCase().split(':').first;
  if (id.contains('life') || id.contains('levenslang')) return 'lifetime';
  if (id.contains('year') || id.contains('annual') || id.contains('jaar')) {
    return 'yearly';
  }
  return 'monthly';
}

/// Which plan a store package sells, or null when it is none of ours.
///
/// Tries, in order: RevenueCat's package type, the package id, then the
/// store product id. The product id alone is not enough on Google Play, where
/// it carries the base plan (`bijbelquiz_premium_yearly:yearly`).
PremiumPlan? planForPackage({
  PackageType? packageType,
  String? packageId,
  required String productId,
}) {
  switch (packageType) {
    case PackageType.annual:
      return PremiumPlan.yearly;
    case PackageType.monthly:
      return PremiumPlan.monthly;
    case PackageType.lifetime:
      return PremiumPlan.lifetime;
    default:
      break;
  }

  for (final plan in PremiumPlan.values) {
    if (packageId == plan.packageId) return plan;
  }

  final product = productId.toLowerCase().split(':').first;
  for (final plan in PremiumPlan.values) {
    if (product == plan.productId) return plan;
  }
  return null;
}

/// A free introductory period offered by the store.
class TrialOffer {
  const TrialOffer({required this.periodUnit, required this.periodCount});

  final PeriodUnit periodUnit;
  final int periodCount;

  /// Dutch label, e.g. "7 dagen gratis".
  String get label {
    final unit = switch (periodUnit) {
      PeriodUnit.day => periodCount == 1 ? 'dag' : 'dagen',
      PeriodUnit.week => periodCount == 1 ? 'week' : 'weken',
      PeriodUnit.month => periodCount == 1 ? 'maand' : 'maanden',
      PeriodUnit.year => 'jaar',
      PeriodUnit.unknown => 'dagen',
    };
    return '$periodCount $unit gratis';
  }

  @override
  bool operator ==(Object other) =>
      other is TrialOffer &&
      other.periodUnit == periodUnit &&
      other.periodCount == periodCount;

  @override
  int get hashCode => Object.hash(periodUnit, periodCount);
}

/// One plan as the store sells it to this buyer, right now.
class PlanOffer {
  const PlanOffer({
    required this.plan,
    required this.productId,
    required this.priceString,
    this.trial,
    this.handle,
  });

  final PremiumPlan plan;

  /// The store's product id (Play: with base plan).
  final String productId;

  /// The store's localized price, e.g. "€39,99". Never made up by the app.
  final String priceString;

  /// The free trial this buyer gets, or null when there is none or they are
  /// not eligible (any more).
  final TrialOffer? trial;

  /// The SDK object to buy (a RevenueCat `Package`). Opaque to everything
  /// but the purchases gateway.
  final Object? handle;
}

/// What the store (via RevenueCat) says about this customer's Premium.
class StoreCustomer {
  const StoreCustomer({
    this.premiumActive = false,
    this.isTrial = false,
    this.willRenew = false,
    this.expiresAt,
    this.productId,
    this.managementUrl,
    this.isSandbox = false,
  });

  static const none = StoreCustomer();

  /// The `premium` entitlement is active.
  final bool premiumActive;

  /// The active entitlement is in its free trial.
  final bool isTrial;

  /// The subscription renews at [expiresAt] (false after cancelling).
  final bool willRenew;

  /// End of the current period; null for lifetime.
  final DateTime? expiresAt;

  final String? productId;

  /// The store's own "manage subscription" page, when RevenueCat has one.
  final String? managementUrl;

  final bool isSandbox;

  PremiumPlan? get plan => productId == null
      ? null
      : planForPackage(productId: productId!) ??
            switch (planLabelForProduct(productId!)) {
              'yearly' => PremiumPlan.yearly,
              'lifetime' => PremiumPlan.lifetime,
              _ => PremiumPlan.monthly,
            };
}

/// Why a purchase or restore did not complete, independent of the SDK.
enum PurchaseFailureKind {
  /// The buyer closed the store sheet. Not an error.
  cancelled,

  /// Ask to Buy / a pending (e.g. cash) payment: the store will finish it
  /// later and RevenueCat reports it when it does.
  pending,
  alreadyOwned,

  /// The store purchase already belongs to another BijbelQuiz account.
  ownedByOtherAccount,
  network,
  notAllowed,
  notAvailable,
  store,
  notConfigured,
  unknown,
}

class PurchaseFailure implements Exception {
  const PurchaseFailure(this.kind, [this.detail]);

  final PurchaseFailureKind kind;
  final String? detail;

  @override
  String toString() =>
      'PurchaseFailure($kind${detail == null ? '' : ': $detail'})';
}

/// Premium as the server sees it, from every source: the store, the website
/// (Stripe), a lifetime purchase, a group licence or a manual grant.
class ServerPremium {
  const ServerPremium({required this.isPremium, this.source});

  final bool isPremium;

  /// `store`, `stripe`, `lifetime`, `group`, `manual` or null.
  final String? source;

  factory ServerPremium.fromJson(Map<String, dynamic> json) => ServerPremium(
    isPremium: json['isPremium'] as bool? ?? false,
    source: json['premiumSource'] as String?,
  );
}
