import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ─── RevenueCat identifiers ──────────────────────────────────────────────────
// Product IDs must match App Store Connect / Play exactly.
const kRcMonthlyProductId = 'bijbelquiz_premium_monthly';
const kRcYearlyProductId = 'bijbelquiz_premium_yearly';
const kRcLifetimeProductId = 'bijbelquiz_premium_lifetime';
// RevenueCat package IDs are usually stable ($rc_monthly / $rc_annual / ...).
const kRcMonthlyPackageId = '\$rc_monthly';
const kRcYearlyPackageId = '\$rc_annual';
const kRcLifetimePackageId = '\$rc_lifetime';

/// Plan labels the funnel reports on. Must match `PURCHASE_PLANS` on the
/// server, which is what the payment webhook writes.
String planLabelForProduct(String productId) {
  final id = productId.toLowerCase();
  if (id.contains('year') || id.contains('annual') || id.contains('jaar')) {
    return 'yearly';
  }
  if (id.contains('life') || id.contains('levenslang')) return 'lifetime';
  return 'monthly';
}

// RevenueCat entitlement identifier (configured in RC dashboard)
const kRcPremiumEntitlement = 'premium';

// SDK is configured once in main.dart (see RevenueCatConfig).

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

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
      PeriodUnit.year => periodCount == 1 ? 'jaar' : 'jaar',
      PeriodUnit.unknown => 'dagen',
    };
    return '$periodCount $unit gratis';
  }
}

class PurchaseService {
  void _log(String message) {
    assert(() {
      debugPrint('[RevenueCat][PurchaseService] $message');
      return true;
    }());
  }

  /// Returns the current offering packages from RevenueCat.
  ///
  /// Preferred flow for production:
  /// - Configure products in RevenueCat dashboard
  /// - Attach them to an Offering (usually "default")
  /// - Let app fetch offerings dynamically
  Future<List<Package>> getPackages() async {
    if (kIsWeb) return [];
    _log('Fetching offerings...');
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) {
      _log('No current offering found.');
      return [];
    }

    final packages = <Package>[...current.availablePackages];
    _log(
      'Current offering="${current.identifier}" with ${packages.length} package(s).',
    );
    for (final pkg in packages) {
      _log(
        'Package="${pkg.identifier}" product="${pkg.storeProduct.identifier}" price="${pkg.storeProduct.priceString}"',
      );
    }

    // Stable order in the UI: yearly first because it is the plan the paywall
    // recommends, then monthly, then the one-off.
    int rank(String productId) {
      switch (planLabelForProduct(productId)) {
        case 'yearly':
          return 0;
        case 'monthly':
          return 1;
        case 'lifetime':
          return 2;
        default:
          return 99;
      }
    }

    packages.sort(
      (a, b) => rank(
        a.storeProduct.identifier,
      ).compareTo(rank(b.storeProduct.identifier)),
    );

    return packages;
  }

  Package? findMonthlyPackage(List<Package> packages) {
    return _findPackage(
      packages,
      packageId: kRcMonthlyPackageId,
      productId: kRcMonthlyProductId,
    );
  }

  Package? findYearlyPackage(List<Package> packages) {
    return _findPackage(
      packages,
      packageId: kRcYearlyPackageId,
      productId: kRcYearlyProductId,
    );
  }

  Package? findLifetimePackage(List<Package> packages) {
    return _findPackage(
      packages,
      packageId: kRcLifetimePackageId,
      productId: kRcLifetimeProductId,
    );
  }

  Package? _findPackage(
    List<Package> packages, {
    required String packageId,
    required String productId,
  }) {
    for (final pkg in packages) {
      if (pkg.identifier == packageId ||
          pkg.storeProduct.identifier == productId) {
        return pkg;
      }
    }
    return null;
  }

  /// The free trial attached to a package, or null when there is none.
  ///
  /// Read from the store rather than hardcoded: the trial is configured in App
  /// Store Connect, and a paywall that promises one the store will not honour
  /// is a rejected review at best.
  static TrialOffer? trialOffer(Package? package) {
    final intro = package?.storeProduct.introductoryPrice;
    if (intro == null) return null;

    // A discounted intro price is not a free trial, and must not be sold as
    // one.
    if (intro.price > 0) return null;

    return TrialOffer(
      periodUnit: intro.periodUnit,
      periodCount: intro.periodNumberOfUnits,
    );
  }

  /// Purchase a RevenueCat package from current offering.
  /// Returns the updated CustomerInfo on success.
  Future<CustomerInfo> purchasePackage(Package package) async {
    _log(
      'Purchasing package="${package.identifier}" product="${package.storeProduct.identifier}"',
    );
    return Purchases.purchasePackage(package);
  }

  /// Fallback flow for when offering packages are temporarily unavailable.
  Future<CustomerInfo> purchaseByProductId(String productId) async {
    _log('Fallback purchase requested for product="$productId"');
    final products = await Purchases.getProducts([productId]);
    if (products.isEmpty) {
      throw StateError('Store product niet gevonden voor id: $productId');
    }
    final product = products.first;
    _log(
      'Fallback product found id="${product.identifier}" price="${product.priceString}"',
    );
    return Purchases.purchaseStoreProduct(product);
  }

  /// Restore previous purchases (required by App Store guidelines).
  Future<CustomerInfo> restorePurchases() async {
    _log('Restoring purchases...');
    return Purchases.restorePurchases();
  }

  /// Check if the user currently has an active premium entitlement.
  Future<bool> hasPremiumAccess() async {
    if (kIsWeb) return false;
    final info = await Purchases.getCustomerInfo();
    final hasPremium = info.entitlements.active.containsKey(
      kRcPremiumEntitlement,
    );
    _log('hasPremiumAccess=$hasPremium');
    return hasPremium;
  }

  /// Get full CustomerInfo (subscription status, expiry, etc.)
  Future<CustomerInfo> getCustomerInfo() async {
    final info = await Purchases.getCustomerInfo();
    final activeIds = info.entitlements.active.keys.join(', ');
    _log(
      'CustomerInfo active entitlements: ${activeIds.isEmpty ? '(none)' : activeIds}',
    );
    return info;
  }
}
